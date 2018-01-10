//
//  KTVHCHTTPServer.h
//  KTVHTTPCache
//
//  Created by Single on 2017/8/10.
//  Copyright © 2017年 Single. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HTTPServer;

@interface KTVHCHTTPServer : NSObject


+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)server;

@property (nonatomic, assign, readonly) BOOL running;
@property (nonatomic, strong) HTTPServer * coreHTTPServer;

- (void)start:(NSError **)error;
- (void)stop;

- (NSString *)URLStringWithOriginalURLString:(NSString *)URLString;


@end
