//
//  DrawColorManager.m
//  Draw
//
//  Created by gamy on 13-1-5.
//
//

#import "DrawColorManager.h"
#import "SynthesizeSingleton.h"
#import "ColorGroup.h"
//#import "ItemManager.h"
#import "AccountService.h"

@interface DrawColorManager()
{
    
}

@property(nonatomic, retain) NSMutableArray *colorList;
@property(nonatomic, retain) NSMutableArray *ownColorList;

@end

#define RECENT_COLOR_LIST_KEY @"RecentColorList"
#define DEFAULT_COLOR_COUNT 10
#define CONST_COLOR_COUNT 2

@implementation DrawColorManager


SYNTHESIZE_SINGLETON_FOR_CLASS(DrawColorManager)

- (void)updateColorList
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:RECENT_COLOR_LIST_KEY];
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if ([array count] < DEFAULT_COLOR_COUNT) {
        array = nil;
        self.colorList = [NSMutableArray arrayWithCapacity:DEFAULT_COLOR_COUNT];

        DrawColor *color = [DrawColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1.0];
        [self.colorList addObject:color];
        color = [DrawColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0];
        [self.colorList addObject:color];
        color = [DrawColor colorWithRed:127/255.0 green:130/255.0 blue:133/255.0 alpha:1.0];
        [self.colorList addObject:color];
        color = [DrawColor colorWithRed:252/255.0 green:0/255.0 blue:7/255.0 alpha:1.0];
        [self.colorList addObject:color];
        color = [DrawColor colorWithRed:0/255.0 green:19/255.0 blue:255/255.0 alpha:1.0];
        [self.colorList addObject:color];
        color = [DrawColor colorWithRed:255/255.0 green:254/255.0 blue:10/255.0 alpha:1.0];
        [self.colorList addObject:color];
        color = [DrawColor colorWithRed:241/255.0 green:0/255.0 blue:110/255.0 alpha:1.0];
        [self.colorList addObject:color];
        color = [DrawColor colorWithRed:46/255.0 green:201/255.0 blue:254/255.0 alpha:1.0];
        [self.colorList addObject:color];
        
        //TODO add two more colors
        color = [DrawColor greenColor];
        [self.colorList addObject:color];
        color = [DrawColor orangeColor];
        [self.colorList addObject:color];
    }else{
        self.colorList = [NSMutableArray arrayWithArray:array];
    }
}

- (void)updateBoughtColorList
{
    self.ownColorList = [NSMutableArray array];
    
    for (NSInteger i = GRADUAL_START; i < GRADUAL_END; ++ i) {
        if ([[AccountService defaultService] hasEnoughItemAmount:i amount:1]) {
            NSArray *list = [ColorGroup colorListForGroupId:i];
            if([list count] != 0){
                [self.ownColorList addObjectsFromArray:list];
            }
        }
    }

    for (NSInteger i = PACKAGE_START; i < PACKAGE_END; ++ i) {
        if ([[AccountService defaultService] hasEnoughItemAmount:i amount:1]) {
            NSArray *list = [ColorGroup colorListForGroupId:i];
            if([list count] != 0){
                [self.ownColorList addObjectsFromArray:list];
            }
        }
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        [self updateColorList];
        [self updateBoughtColorList];
    }
    return self;
}

- (void)dealloc
{
    PPRelease(_colorList);
    PPRelease(_ownColorList);
    [super dealloc];
}



- (NSArray *)recentColorList
{
    return self.colorList;
}

- (void)setRecentColorList:(NSArray *)list
{
    if ([list count] != 0) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:list];
        [defaults setObject:data forKey:RECENT_COLOR_LIST_KEY];
        [defaults synchronize];
    }
}

- (void)updateColorListWithColor:(DrawColor *)color
{
    NSUInteger index = [self.colorList indexOfObject:color];
    if (index == NSNotFound || index >= DEFAULT_COLOR_COUNT){
        [self.colorList removeLastObject];
    }else if(index >= CONST_COLOR_COUNT){
        [self.colorList removeObjectAtIndex:index];
    }else{
        return;
    }
    [self.colorList insertObject:color atIndex:CONST_COLOR_COUNT];
}

- (void)syncRecentList
{
    if ([self.colorList count] != 0) {
        [self setRecentColorList:self.colorList];
    }
}

- (void)addBoughtColorList:(NSArray *)list
{
    [self.ownColorList addObjectsFromArray:list];
}

- (NSArray *)boughtColorList
{
    return self.ownColorList;
}

- (NSArray *)boughtColorListWithOffset:(NSUInteger)offset limit:(NSUInteger)limit
{
    NSUInteger count = [self.ownColorList count];
    if (offset >= count ) {
        return nil;
    }
    count = MIN(limit, count - offset);
    NSRange range = NSMakeRange(offset, count);
    return [self.ownColorList subarrayWithRange:range];
}
@end