//
//  ZJHUserPlayInfo.m
//  Draw
//
//  Created by 王 小涛 on 12-10-24.
//
//

#import "ZJHUserPlayInfo.h"

@interface ZJHUserPlayInfo ()
@property (readwrite, copy, nonatomic) NSString *userId;

@end

@implementation ZJHUserPlayInfo
@synthesize userId = _userId;
@synthesize pokers = _pokers;
@synthesize cardType = _cardType;
@synthesize totalBet = _totalBet;
@synthesize isAutoBet = _isAutoBet;
@synthesize autoBetCount = _autoBetCount;
@synthesize lastAction = _lastAction;

@synthesize alreadCheckCard = _alreadCheckCard;
@synthesize alreadFoldCard = _alreadFoldCard;
@synthesize alreadShowCard = _alreadShowCard;
@synthesize alreadLose = _alreadLose;



#pragma mark - Life cycle

- (void)dealloc
{
    [_userId release];
    [_pokers release];
    [super dealloc];
}

- (id)initWithPBZJHUserPlayInfo:(PBZJHUserPlayInfo *)pbZJHUserPlayInfo
{
    if (self = [super init]) {
        self.userId = pbZJHUserPlayInfo.userId;
        self.pokers = [self pokersFormPBPokers:pbZJHUserPlayInfo.pokers.pokersList];
        self.cardType = pbZJHUserPlayInfo.pokers.cardType;
        self.totalBet = pbZJHUserPlayInfo.totalBet;
        self.isAutoBet = pbZJHUserPlayInfo.isAutoBet;
        self.lastAction = pbZJHUserPlayInfo.lastAction;
        
        self.alreadCheckCard = FALSE;
        self.alreadFoldCard = FALSE;
        self.alreadShowCard = FALSE;
        self.alreadLose = FALSE;
    }
    
    return self;
}

+ (ZJHUserPlayInfo *)fromPBZJHUserPlayInfo:(PBZJHUserPlayInfo *)pbZJHUserPlayInfo
{
    return [[[ZJHUserPlayInfo alloc] initWithPBZJHUserPlayInfo:pbZJHUserPlayInfo] autorelease];
}

#pragma make - Publik methods

- (void)setPokersFaceUp:(NSArray *)pokerIds
{
    for (NSNumber *pokerId in pokerIds) {
        [self setPokerFaceUp:pokerId.intValue];
    }
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

- (BOOL)canCompareCard
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

- (BOOL)canCheckCard
{
    if (_alreadCheckCard || _alreadFoldCard || _alreadLose) {
        return NO;
    }else {
        return YES;
    }
}

- (BOOL)canFoldCard
{
    if (_alreadFoldCard || _alreadLose) {
        return NO;
    }else {
        return YES;
    }
}

- (BOOL)canShowCard:(int)cardId
{
    for (Poker *poker in _pokers) {
        if (cardId == poker.pokerId) {
            return !poker.faceUp;
        }
    }
    
    return NO;
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

- (void)setPokerFaceUp:(int)pokerId
{
    Poker *poker = [self poker:pokerId];
    [poker setFaceUp];
}

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

- (NSString *)cardTypeString
{
    switch (_cardType) {
        case PBZJHCardTypeHighCard:
            return @"kCardTypeHighCard";
            break;
            
        case PBZJHCardTypePair:
            return @"kCardTypePair";
            break;
            
        case PBZJHCardTypeStraight:
            return @"kCardTypeStraight";
            break;
            
        case PBZJHCardTypeFlush:
            return @"kCardTypeFlush";
            break;
            
        case PBZJHCardTypeStraightFlush:
            return @"kCardTypeStraightFlush";
            break;
            
        case PBZJHCardTypeThreeOfAKind:
            return @"kCardTypeThreeOfAKind";
            break;
            
        case PBZJHCardTypeSpecial:
            return @"kCardTypeSpecial";
            break;
            
        case PBZJHCardTypeUnknow:
            return @"kCardTypeUnknow";
            break;
            
        default:
            return @"";
            break;
    }
}

@end
