//
//  KTVHCM3u8Model.m
//  KTVHTTPCache
//
//  Created by shixiaoda on 2018/1/10.
//  Copyright © 2018年 Single. All rights reserved.
//

#import "KTVHCM3u8Unit.h"
#import "KTVHCM3u8Tags.h"
#import "YYModel.h"
#import "KTVHCURLTools.h"

@implementation KTVHCM3u8UnitItem

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{ @"duration" : @"DURATION",
              @"URIString" : @"URI" };
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self yy_modelEncodeWithCoder:aCoder];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self yy_modelInitWithCoder:aDecoder];
}

@end

@interface KTVHCM3u8Unit ()
@property (nonatomic, copy) NSString *originalText;
@property (nonatomic, copy) NSString *proxyText;
@property (nonatomic, strong) NSData *proxyTextData;
@property (nonatomic, strong) NSData *originalTextData;

@property (nonatomic, strong) NSRecursiveLock * coreLock;
@end

@implementation KTVHCM3u8Unit

- (instancetype)initWithContentOfURL:(NSString *)URLString error:(NSError **)error
{
    if (self = [super init]) {
        self.URLString = URLString;
        self.uniqueIdentifier = [KTVHCURLTools uniqueIdentifierWithURLString:URLString];
        
        NSString *string = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:URLString] encoding:NSUTF8StringEncoding error:error];
        
        self.originalText = string;
        self.originalTextData = [self.originalText dataUsingEncoding:NSUTF8StringEncoding];
        [self prepare];
    }
    
    return self;
}

- (void)prepare
{
    self.coreLock = [[NSRecursiveLock alloc] init];
    self.segmentList = [[NSMutableDictionary alloc] init];
    self.cachedList = [NSMutableArray array];
    
    NSRange segmentRange = [self.originalText rangeOfString:M3U8_EXTINF];
    NSString *remainingSegments = self.originalText;
    NSTimeInterval offset = 0;
    
    while (NSNotFound != segmentRange.location) {
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        //        if (self.originalURL) {
        //            [params setObject:self.originalURL forKey:M3U8_URL];
        //        }
        //
        //        if (self.baseURL) {
        //            [params setObject:self.baseURL forKey:M3U8_BASE_URL];
        //        }
        
        // Read the EXTINF number between #EXTINF: and the comma
        NSRange commaRange = [remainingSegments rangeOfString:@","];
        NSRange valueRange = NSMakeRange(segmentRange.location + 8, commaRange.location - (segmentRange.location + 8));
        if (commaRange.location == NSNotFound || valueRange.location > remainingSegments.length -1)
            break;
        
        NSString *value = [remainingSegments substringWithRange:valueRange];
        [params setValue:value forKey:M3U8_EXTINF_DURATION];
        
        // ignore the #EXTINF line
        remainingSegments = [remainingSegments substringFromIndex:segmentRange.location];
        NSRange extinfoLFRange = [remainingSegments rangeOfString:@"\n"];
        remainingSegments = [remainingSegments substringFromIndex:extinfoLFRange.location + 1];
        
        // Read the segment link, and ignore line start with # && blank line
        while (1) {
            NSRange lfRange = [remainingSegments rangeOfString:@"\n"];
            NSString *line = [remainingSegments substringWithRange:NSMakeRange(0, lfRange.location)];
            line = [line stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            remainingSegments = [remainingSegments substringFromIndex:lfRange.location + 1];
            
            if ([line characterAtIndex:0] != '#' && 0 != line.length) {
                // remove the CR character '\r'
                unichar lastChar = [line characterAtIndex:line.length - 1];
                if (lastChar == '\r') {
                    line = [line substringToIndex:line.length - 1];
                }
                
                [params setValue:line forKey:M3U8_EXTINF_URI];
                break;
            }
        }
        
        KTVHCM3u8UnitItem *segment = [KTVHCM3u8UnitItem yy_modelWithJSON:params];
        segment.offset = offset;
        offset += segment.duration;
        if (segment) {
            [self.segmentList setObject:segment forKey:segment.URIString];
        }
        
        segmentRange = [remainingSegments rangeOfString:M3U8_EXTINF];
    }
}

- (BOOL)proxySegmentURLStringWithBlock:(KTVHCM3u8URLFilterBlock)block
{
    self.proxyText = self.originalText;
    for (NSString *URLString in self.segmentList) {
        NSString *proxyURLString = block(URLString);
        self.proxyText = [self.proxyText stringByReplacingOccurrencesOfString:URLString withString:proxyURLString];
    }
    self.proxyTextData = [self.proxyText dataUsingEncoding:NSUTF8StringEncoding];
    return YES;
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
//    [self yy_modelEncodeWithCoder:aCoder];
    [aCoder encodeObject:self.URLString forKey:@"URLString"];
    [aCoder encodeObject:self.uniqueIdentifier forKey:@"uniqueIdentifier"];
    [aCoder encodeObject:self.originalTextData forKey:@"originalTextData"];
//    [aCoder encodeObject:self.proxyText forKey:@"proxyText"];
    [aCoder encodeBool:self.isFinishCache forKey:@"isFinishCache"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
//    return [self yy_modelInitWithCoder:aDecoder];
    if (self = [super init]) {
        _URLString = [aDecoder decodeObjectForKey:@"URLString"];
        _uniqueIdentifier = [aDecoder decodeObjectForKey:@"uniqueIdentifier"];
        _originalTextData = [aDecoder decodeObjectForKey:@"originalTextData"];
        _originalText = [[NSString alloc] initWithData:_originalTextData encoding:NSUTF8StringEncoding];
        _isFinishCache = [aDecoder decodeBoolForKey:@"isFinishCache"];
        
        [self prepare];
    }
    return self;
}

#pragma mark - NSLocking

- (void)lock
{
    [self.coreLock lock];
//    for (KTVHCDataUnitItem * obj in self.unitItems) {
//        [obj lock];
//    }
}

- (void)unlock
{
//    for (KTVHCDataUnitItem * obj in self.unitItems) {
//        [obj unlock];
//    }
    [self.coreLock unlock];
}
@end
