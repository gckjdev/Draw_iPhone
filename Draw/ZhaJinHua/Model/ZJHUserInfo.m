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
@synthesize userState = _userState;
@synthesize canBeCompared = _canBeCompared;

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
        self.userState = pbZJHUserInfo.userState;
        self.canBeCompared = pbZJHUserInfo.canBeCompared;
    }
    
    return self;
}

+ (ZJHUserInfo *)userInfoFromPBZJHUserInfo:(PBZJHUserInfo *)pbZJHUserInfo
{
    return [[[ZJHUserInfo alloc] initWithPBZJHUserInfo:pbZJHUserInfo] autorelease];
}

#pragma make - Publik methods

- (void)reset
{
    self.pokers = nil;
    self.cardType = PBZJHCardTypeUnknow;
    self.totalBet = 0;
    self.isAutoBet = FALSE;
    self.userState = PBZJHUserStateDefault;
    self.canBeCompared = FALSE;
}

- (void)setPokerFaceUp:(int)pokerId
{
    Poker *poker = [self poker:pokerId];
    [poker setFaceUp];
}

- (int)betCount
{
    if (_userState != PBZJHUserStateCheckCard) {
        return 1;
    }
    
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
    if (pbPokers == nil) {
        return nil;
    }
    
    NSMutableArray *pokers = [NSMutableArray arrayWithCapacity:[pbPokers count]];
    
    for (int i = 0; i < [pbPokers count]; i ++) {
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
