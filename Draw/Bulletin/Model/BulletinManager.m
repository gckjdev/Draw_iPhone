//
//  BulletinManager.m
//  Draw
//
//  Created by Kira on 12-12-17.
//
//

#import "BulletinManager.h"
#import "SynthesizeSingleton.h"
#import "NSMutableArray+Stack.h"
#import "Bulletin.h"




@implementation BulletinManager
SYNTHESIZE_SINGLETON_FOR_CLASS(BulletinManager)

- (void)dealloc
{
    [_bulletinStack release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        _bulletinStack = [[NSMutableArray alloc] initWithCapacity:MAX_CACHE_BULLETIN_COUNT];
        [self loadLocalBulletinList];
    }
    return self;
}

- (NSString*)latestBulletinId
{
    return [(Bulletin*)[_bulletinStack peek] bulletinId];
}

- (void)saveBulletinList:(NSArray*)bulletinList
{
    for (Bulletin* bulletin in bulletinList) {
        PPDebug(@"<test>pushing bullitin %@",bulletin.date);
        [self pushBulletin:bulletin];
    }
    [self saveBulletins];
}

- (void)pushBulletin:(Bulletin*)bulletin
{
    [_bulletinStack push:bulletin];
    while (_bulletinStack.count > MAX_CACHE_BULLETIN_COUNT) {
        [_bulletinStack removeObjectAtIndex:0];
    }
}

- (NSArray*)bulletins
{
    return _bulletinStack;
}

- (void)readAllBulletins
{
    for (Bulletin* bulletin in _bulletinStack) {
        bulletin.hasRead = YES;
    }
    [self saveBulletins];
}

- (NSInteger)unreadBulletinCount
{
    int count = 0;
    for (Bulletin* bulletin in _bulletinStack) {
        if (!bulletin.hasRead) {
            count++;
        }
    }
    return count;
}

#define BULLETIN_LIST_KEY @"bulletinList"
- (NSArray *)loadLocalBulletinList
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:BULLETIN_LIST_KEY];
    if (data) {
        [_bulletinStack setArray:[NSKeyedUnarchiver unarchiveObjectWithData:data]];
        PPDebug(@"get Local bulletin list, count = %d", [_bulletinStack count]);
        return _bulletinStack;
    }
    PPDebug(@"get Local bulletin list = nil");
    return nil;
}

- (void)saveBulletins
{
    NSData* reData = [NSKeyedArchiver archivedDataWithRootObject:_bulletinStack];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:reData forKey:BULLETIN_LIST_KEY];
    [defaults synchronize];
    PPDebug(@"save boardList!, new board count = %d",[_bulletinStack count]);
}


@end
