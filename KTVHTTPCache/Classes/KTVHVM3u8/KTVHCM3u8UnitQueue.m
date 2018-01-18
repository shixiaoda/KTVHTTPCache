//
//  KTVHCM3u8UnitQueue.m
//  KTVHTTPCache
//
//  Created by shixiaoda on 2018/1/10.
//  Copyright © 2018年 Single. All rights reserved.
//

#import "KTVHCM3u8UnitQueue.h"
#import "KTVHCLog.h"

@interface KTVHCM3u8UnitQueue ()


@property (nonatomic, copy) NSString * archiverPath;
@property (nonatomic, strong) NSMutableArray <KTVHCM3u8Unit *> * unitArray;


@end


@implementation KTVHCM3u8UnitQueue


+ (instancetype)unitQueueWithArchiverPath:(NSString *)archiverPath
{
    return [[self alloc] initWithArchiverPath:archiverPath];
}

- (instancetype)initWithArchiverPath:(NSString *)archiverPath
{
    if (self = [super init])
    {
        self.archiverPath = archiverPath;
        self.unitArray = [NSKeyedUnarchiver unarchiveObjectWithFile:self.archiverPath];
        if (!self.unitArray) {
            self.unitArray = [NSMutableArray array];
        }
        KTVHCLogDataUnitQueue(@"init unit count, %lu", self.unitArray.count);
    }
    return self;
}


- (NSArray <KTVHCM3u8Unit *> *)allUnits
{
    if (self.unitArray.count <= 0) {
        return nil;
    }
    
    NSArray <KTVHCM3u8Unit *> * units = [self.unitArray copy];
    return units;
}

- (KTVHCM3u8Unit *)unitWithUniqueIdentifier:(NSString *)uniqueIdentifier;
{
    if (uniqueIdentifier.length <= 0) {
        return nil;
    }
    
    KTVHCM3u8Unit * unit = nil;
    for (KTVHCM3u8Unit * obj in self.unitArray)
    {
        if ([obj.uniqueIdentifier isEqualToString:uniqueIdentifier]) {
            unit = obj;
            break;
        }
    }
    return unit;
}

- (KTVHCM3u8Unit *)unitWithTSURLString:(NSString *)tsURLString
{
    if (tsURLString.length <= 0) {
        return nil;
    }
    
    KTVHCM3u8Unit * unit = nil;
    for (KTVHCM3u8Unit * obj in self.unitArray)
    {
        KTVHCM3u8UnitItem* currentUnitItem = [obj.segmentList objectForKey:tsURLString];
        
        if (currentUnitItem) {
            unit = obj;
            unit.currentUnitItem = currentUnitItem;
            break;
        }
        else {
            currentUnitItem = [obj.segmentList objectForKey:[tsURLString lastPathComponent]];
            if (currentUnitItem) {
                unit = obj;
                unit.currentUnitItem = currentUnitItem;
                break;
            }
        }
    }
    return unit;
}

- (void)putUnit:(KTVHCM3u8Unit *)unit
{
    if (!unit) {
        return;
    }
    
    if (![self.unitArray containsObject:unit]) {
        [self.unitArray addObject:unit];
    }
}

- (void)popUnit:(KTVHCM3u8Unit *)unit
{
    if (!unit) {
        return;
    }
    
    if ([self.unitArray containsObject:unit]) {
        [self.unitArray removeObject:unit];
    }
}

- (void)archive
{
    KTVHCLogDataUnitQueue(@"archive begin, %lu", self.unitArray.count);
    
    [NSKeyedArchiver archiveRootObject:self.unitArray toFile:self.archiverPath];
    
    KTVHCLogDataUnitQueue(@"archive end, %lu", self.unitArray.count);
}

@end
