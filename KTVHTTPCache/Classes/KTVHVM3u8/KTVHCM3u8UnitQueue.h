//
//  KTVHCM3u8UnitQueue.h
//  KTVHTTPCache
//
//  Created by shixiaoda on 2018/1/10.
//  Copyright © 2018年 Single. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTVHCM3u8Unit.h"

@interface KTVHCM3u8UnitQueue : NSObject

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)unitQueueWithArchiverPath:(NSString *)archiverPath;

- (NSArray <KTVHCM3u8Unit *> *)allUnits;
- (KTVHCM3u8Unit *)unitWithUniqueIdentifier:(NSString *)uniqueIdentifier;

- (KTVHCM3u8Unit *)unitWithTSURLString:(NSString *)tsURLString;

- (void)putUnit:(KTVHCM3u8Unit *)unit;
- (void)popUnit:(KTVHCM3u8Unit *)unit;

- (void)archive;

@end
