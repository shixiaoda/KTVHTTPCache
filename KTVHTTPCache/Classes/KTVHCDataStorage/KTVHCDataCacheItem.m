//
//  KTVHCDataCacheItem.m
//  KTVHTTPCache
//
//  Created by Single on 2017/8/13.
//  Copyright © 2017年 Single. All rights reserved.
//

#import "KTVHCDataCacheItem.h"
#import "KTVHCDataPrivate.h"


@interface KTVHCDataCacheItem ()


@property (nonatomic, copy) NSString * URLString;
@property (nonatomic, assign) long long totalLength;
@property (nonatomic, assign) long long cacheLength;
@property (nonatomic, assign) NSTimeInterval totalDuration;
@property (nonatomic, assign) NSTimeInterval totalCacheDuration;
@property (nonatomic, copy) NSArray <KTVHCDataCacheItemZone *> * zones;


@end


@implementation KTVHCDataCacheItem


+ (instancetype)itemWithURLString:(NSString *)URLString
                      totalLength:(long long)totalLength
                      cacheLength:(long long)cacheLength
                    totalDuration:(NSTimeInterval)totalDuration
               totalCacheDuration:(NSTimeInterval)totalCacheDuration
                            zones:(NSArray <KTVHCDataCacheItemZone *> *)zones
{
    return [[self alloc] initWithURLString:URLString
                               totalLength:totalLength
                               cacheLength:cacheLength
                             totalDuration:totalDuration
                        totalCacheDuration:totalCacheDuration
                                     zones:zones];
}

- (instancetype)initWithURLString:(NSString *)URLString
                      totalLength:(long long)totalLength
                      cacheLength:(long long)cacheLength
                    totalDuration:(NSTimeInterval)totalDuration
               totalCacheDuration:(NSTimeInterval)totalCacheDuration
                            zones:(NSArray <KTVHCDataCacheItemZone *> *)zones
{
    if (self = [super init])
    {
        self.URLString = URLString;
        self.totalLength = totalLength;
        self.cacheLength = cacheLength;
        self.totalDuration = totalDuration;
        self.totalCacheDuration = totalCacheDuration;
        self.zones = zones;
    }
    return self;
}

- (BOOL)isFinishCache
{
    if (self.totalDuration > 0) {
        return self.totalDuration == self.totalCacheDuration;
    } else {
        if (self.totalLength > 0) {
            return self.totalLength == self.cacheLength;
        } else {
            return NO;
        }
    }
}

- (void)deleteAllCacheItem
{
    
}

@end
