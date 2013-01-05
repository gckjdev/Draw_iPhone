//
//  DrawColorManager.m
//  Draw
//
//  Created by gamy on 13-1-5.
//
//

#import "DrawColorManager.h"

@implementation DrawColorManager

#define RECENT_COLOR_LIST_KEY @"RecentColorList"

- (NSArray *)getRecentColorList
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:RECENT_COLOR_LIST_KEY];
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return array;
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

@end
