//
//  KTVHCM3u8Model.h
//  KTVHTTPCache
//
//  Created by shixiaoda on 2018/1/10.
//  Copyright © 2018年 Single. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KTVHCM3u8UnitItem : NSObject <NSCoding>
@property (nonatomic, copy) NSString *URIString;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) NSTimeInterval offset;
@end

typedef NSString * (^KTVHCM3u8URLFilterBlock)(NSString *originalUrlstring);

@interface KTVHCM3u8Unit : NSObject <NSCoding,NSLocking>

+ (instancetype) new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, copy) NSString *URLString;
@property (nonatomic, copy) NSString *uniqueIdentifier;

@property (nonatomic, strong, readonly) NSData *proxyTextData;
@property (nonatomic, strong, readonly) NSData *originalTextData;

@property (nonatomic, strong) KTVHCM3u8UnitItem *currentUnitItem;
@property (nonatomic, strong) NSMutableDictionary<NSString *, KTVHCM3u8UnitItem *> *segmentList;
@property (nonatomic, strong) NSMutableArray <NSString *> *cachedList;
@property (nonatomic, assign) BOOL isFinishCache;

- (instancetype)initWithContentOfURL:(NSString *)URLString error:(NSError **)error;

- (BOOL)proxySegmentURLStringWithBlock:(KTVHCM3u8URLFilterBlock)block;
@end
