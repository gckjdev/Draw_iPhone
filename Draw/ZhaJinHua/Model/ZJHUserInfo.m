//
//  ZJHUserInfo.m
//  Draw
//
//  Created by 王 小涛 on 12-10-24.
//
//

#import "ZJHUserInfo.h"

@interface ZJHUserInfo ()
@property (readwrite, copy, nonatomic) NSString *userId;

@end

@implementation ZJHUserInfo

@synthesize userId = _userId;
@synthesize pokers = _pokers;
@synthesize cardType = _cardType;
@synthesize totalBet = _totalBet;
@synthesize isAutoBet = _isAutoBet;
@synthesize lastAction = _lastAction;

@synthesize alreadCheckCard = _alreadCheckCard;
@synthesize alreadFoldCard = _alreadFoldCard;
@synthesize alreadShowCard = _alreadShowCard;

#pragma mark - Life cycle

- (void)dealloc
{
    [_userId release];
    [_pokers release];
    [super dealloc];
}

- (id)initWithPBZJHUserInfo:(PBZJHUserInfo *)pbZJHUserInfo
{
    if (self = [super init]) {
        self.userId = pbZJHUserInfo.userId;
        self.pokers = [self pokersFormPBPokers:pbZJHUserInfo.pokersList];
        self.cardType = pbZJHUserInfo.cardType;
        self.totalBet = pbZJHUserInfo.totalBet;
        self.isAutoBet = pbZJHUserInfo.isAutoBet;
        self.lastAction = pbZJHUserInfo.lastAction;
        
        self.alreadCheckCard = FALSE;
        self.alreadFoldCard = FALSE;
        self.alreadShowCard = FALSE;
        self.alreadLose = FALSE;
    }
    
    return self;
}

+ (ZJHUserInfo *)userInfoFromPBZJHUserInfo:(PBZJHUserInfo *)pbZJHUserInfo
{
    return [[[ZJHUserInfo alloc] initWithPBZJHUserInfo:pbZJHUserInfo] autorelease];
}

#pragma make - Publik methods

- (void)setPokerFaceUp:(int)pokerId
{
    Poker *poker = [self poker:pokerId];
    [poker setFaceUp];
}

- (int)betCount
{
    if (!_alreadCheckCard) {
        return 1;
    }
    
    if ([[self faceUpPokers] count] == [_pokers count]) {
        return 1;
    }
    
    return 2;
}

- (BOOL)canBeCompare
{
    if (_alreadFoldCard || _alreadLose) {
        return NO;
    }
    
    if (_lastAction == PBZJHUserActionShowCard
        && [[self faceUpPokers] count] < [_pokers count]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)hasShield
{
    if (_alreadFoldCard || _alreadLose) {
        return NO;
    }
    
    if (_lastAction == PBZJHUserActionShowCard
        && [[self faceUpPokers] count] < [_pokers count]) {
        return YES;
    }
    
    return NO;
}

#pragma make - Private methods

- (Poker *)poker:(int)pokerId
{
    for (Poker *poker in _pokers) {
        if (poker.pokerId == pokerId) {
            return poker;
        }
    }
    
    return nil;
}

- (NSArray *)pokersFormPBPokers:(NSArray *)pbPokers
{
    if ([pbPokers count] < ZJH_NUM_POKER_PER_USER) {
        PPDebug(@"WARNNING: pbPokers count less than %d", ZJH_NUM_POKER_PER_USER);
        return nil;
    }
    
    NSMutableArray *pokers = [NSMutableArray arrayWithCapacity:ZJH_NUM_POKER_PER_USER];
    
    for (int i = 0; i < ZJH_NUM_POKER_PER_USER; i ++) {
        [pokers addObject:[Poker pokerFromPBPoker:[pbPokers objectAtIndex:i]]];
    }
    
    return pokers;
}

- (NSArray *)faceUpPokers
{
    NSMutableArray *pokers = [NSMutableArray arrayWithCapacity:[_pokers count]];
    
    for (Poker *poker in _pokers) {
        if (poker.faceUp == TRUE) {
            [pokers addObject:poker];
        }
    }
    
    return pokers;
}

@end
