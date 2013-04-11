//
//  LearnDrawManager.m
//  Draw
//
//  Created by gamy on 13-4-11.
//
//

#import "LearnDrawManager.h"

@implementation LearnDrawManager

SYNTHESIZE_SINGLETON_FOR_CLASS(LearnDrawManager)

#define KEY_BOUGHT_LEARNDRAW_LIST @"KEY_BOUGHT_LEARNDRAW_LIST"

- (id)init
{
    self = [super init];
    if (self) {
        self.boughtList = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_BOUGHT_LEARNDRAW_LIST];
    }
    return self;
}

- (void)updateBoughtList:(NSArray *)list
{
    self.boughtList = list;
    if ([list count] != 0) {
        [[NSUserDefaults standardUserDefaults] setObject:list forKey:KEY_BOUGHT_LEARNDRAW_LIST];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}



- (void)dealloc
{
    PPRelease(_boughtList);
    [super dealloc];
}

@end
