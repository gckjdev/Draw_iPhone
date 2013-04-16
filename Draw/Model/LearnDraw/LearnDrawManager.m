//
//  LearnDrawManager.m
//  Draw
//
//  Created by gamy on 13-4-11.
//
//

#import "LearnDrawManager.h"

@interface LearnDrawManager()
{
    NSMutableSet *_boughtSet;
}

@end

@implementation LearnDrawManager

SYNTHESIZE_SINGLETON_FOR_CLASS(LearnDrawManager)

#define KEY_BOUGHT_LEARNDRAW_LIST @"KEY_BOUGHT_LEARNDRAW_LIST"

- (id)init
{
    self = [super init];
    if (self) {
        NSArray *list = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_BOUGHT_LEARNDRAW_LIST];
        _boughtSet = [[NSMutableSet set] retain];
        if ([list count] != 0) {
            [_boughtSet addObjectsFromArray:list];
        }
    }
    return self;
}

- (NSSet *)boughtDrawIdSet
{
    return _boughtSet;
}


- (void)updateLocalSet
{
    NSMutableArray *list = [NSMutableArray arrayWithCapacity:[_boughtSet count]];
    for (NSString *value in _boughtSet) {
        [list addObject:value];
    }
    if ([list count] != 0) {
        [[NSUserDefaults standardUserDefaults] setObject:_boughtSet forKey:KEY_BOUGHT_LEARNDRAW_LIST];
        [[NSUserDefaults standardUserDefaults] synchronize];        
    }
}

- (void)addBoughtOpusId:(NSString *)opusId
{
    if ([opusId length] != 0) {
        [_boughtSet addObject:opusId];
        [self updateLocalSet];        
    }
}

- (BOOL)hasBoughtDraw:(NSString *)drawId
{
    return [self.boughtDrawIdSet containsObject:drawId];
}

- (void)updateBoughtList:(NSArray *)list
{
    if ([list count] != 0) {
        [_boughtSet addObjectsFromArray:list];
        [self updateLocalSet];
    }
}



- (void)dealloc
{
    PPRelease(_boughtSet);
    [super dealloc];
}

@end
