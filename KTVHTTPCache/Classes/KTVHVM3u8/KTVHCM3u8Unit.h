//
//  KTVHCM3u8Model.h
//  KTVHTTPCache
//
//  Created by shixiaoda on 2018/1/10.
//  Copyright © 2018年 Single. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KTVHCM3u8UnitItem : NSObject <NSCoding>
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic) NSTimeInterval offset;
@property (nonatomic, copy) NSString *URIString;
@end

typedef NSString *(^KTVHCM3u8URLFilterBlock)(NSString *originalUrlstring);



@interface KTVHCM3u8Unit : NSObject <NSCoding>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@property (nonatomic, copy) NSString *URLString;
@property (nonatomic, copy) NSString * uniqueIdentifier;

@property (nonatomic, copy) NSString *originalText;
@property (nonatomic, copy) NSString *proxyText;

@property (nonatomic, strong) KTVHCM3u8UnitItem *currentUnitItem;
@property (nonatomic, strong) NSMutableDictionary <NSString *,KTVHCM3u8UnitItem *> *segmentList;

- (instancetype)initWithContentOfURL:(NSString *)URLString error:(NSError **)error;

- (BOOL)generateProxyM3u8ToPath:(NSString *)path proxyURLStringBlock:(KTVHCM3u8URLFilterBlock)block error:(NSError *)error;
@end
