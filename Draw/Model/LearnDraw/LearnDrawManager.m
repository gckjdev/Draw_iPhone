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

#define KEY_BOUGHT_LEARNDRAW_SET @"KEY_BOUGHT_LEARNDRAW_SET"

- (id)init
{
    self = [super init];
    if (self) {
        _boughtSet = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_BOUGHT_LEARNDRAW_SET];
        if (_boughtSet == nil) {
            _boughtSet = [NSMutableSet set];
        }
        [_boughtSet retain];
    }
    return self;
}

- (NSSet *)boughtDrawIdSet
{
    return _boughtSet;
}


- (void)updateLocalSet
{
    [[NSUserDefaults standardUserDefaults] setObject:_boughtSet forKey:KEY_BOUGHT_LEARNDRAW_SET];
    [[NSUserDefaults standardUserDefaults] synchronize];    
}

- (void)addBoughtOpusId:(NSString *)opusId
{
    if ([opusId length] != 0) {
        [_boughtSet addObject:_boughtSet];
        [self updateLocalSet];        
    }
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
