//
//  ZJHUserPlayInfo.m
//  Draw
//
//  Created by 王 小涛 on 12-10-24.
//
//

#import "ZJHUserPlayInfo.h"

#define ZJH_MAX_NUM_CHANGE_CARD 3

@interface ZJHUserPlayInfo ()
@property (readwrite, copy, nonatomic) NSString *userId;

@end

@implementation ZJHUserPlayInfo
@synthesize userId = _userId;
@synthesize pokers = _pokers;
@synthesize cardType = _cardType;
@synthesize totalBet = _totalBet;
@synthesize isAutoBet = _isAutoBet;
@synthesize lastAction = _lastAction;

@synthesize alreadCheckCard = _alreadCheckCard;
@synthesize alreadFoldCard = _alreadFoldCard;
@synthesize alreadShowCard = _alreadShowCard;
@synthesize alreadCompareLose = _alreadCompareLose;



#pragma mark - Life cycle

- (void)dealloc
{
    [_userId release];
    [_pokers release];
    [_replacedPokers release];
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
        
        self.alreadCheckCard = pbZJHUserPlayInfo.alreadCheckCard;
        self.alreadFoldCard = pbZJHUserPlayInfo.alreadFoldCard;
        self.alreadShowCard = pbZJHUserPlayInfo.alreadShowCard;
        self.alreadCompareLose = pbZJHUserPlayInfo.alreadCompareLose;
        self.replacedPokers = [NSMutableArray array];
//        self.compareAward = 0;
//        self.resultAward = 0;
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

- (BOOL)canAutoBet
{
    if (_alreadFoldCard || _alreadCompareLose) {
        return NO;
    }
    
    return YES;
}



- (BOOL)canCheckCard
{
    if (_alreadCheckCard || _alreadFoldCard || _alreadCompareLose) {
        return NO;
    }else {
        return YES;
    }
}

- (BOOL)canFoldCard
{
    if (_alreadFoldCard || _alreadCompareLose) {
        return NO;
    }else {
        return YES;
    }
}

- (BOOL)canShowCard:(int)cardId
{
    Poker *poker = [self poker:cardId];
    if(poker != nil)
    {
        return !poker.faceUp;
    }else {
        return NO;
    }
}

- (BOOL)canCompareCard
{
    if (_alreadFoldCard || _alreadCompareLose) {
        return NO;
    }
    
    return YES;
}

- (BOOL)canChangeCard:(int)cardId
{
    if ([[self poker:cardId] faceUp] == YES) {
        return NO;
    }
    
    if ([self lastAction] == PBZJHUserActionChangeCard) {
        return NO;
    }
    
    if (!_alreadCheckCard || _alreadFoldCard || _alreadCompareLose) {
        return NO;
    }
    
    if ([self changeCardTimes] >= ZJH_MAX_NUM_CHANGE_CARD) {
        return NO;
    }
    
    return YES;
}

- (BOOL)canBeCompared
{
    if (_alreadFoldCard || _alreadCompareLose) {
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
    if (_alreadFoldCard || _alreadCompareLose) {
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

- (NSMutableArray *)pokersFormPBPokers:(NSArray *)pbPokers
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
            return NSLS(@"kCardTypeHighCard");
            break;
            
        case PBZJHCardTypePair:
            return NSLS(@"kCardTypePair");
            break;
            
        case PBZJHCardTypeStraight:
            return NSLS(@"kCardTypeStraight");
            break;
            
        case PBZJHCardTypeFlush:
            return NSLS(@"kCardTypeFlush");
            break;
            
        case PBZJHCardTypeStraightFlush:
            return NSLS(@"kCardTypeStraightFlush");
            break;
            
        case PBZJHCardTypeThreeOfAKind:
            return NSLS(@"kCardTypeThreeOfAKind");
            break;
            
        case PBZJHCardTypeSpecial:
            return NSLS(@"kCardTypeSpecial");
            break;
            
        case PBZJHCardTypeUnknow:
            return NSLS(@"kCardTypeUnknow");
            break;
            
        default:
            return @"";
            break;
    }
}

- (void)changePoker:(int)oldCardId
           newPoker:(PBPoker *)newPoker
{
    Poker *oldPoker = [self poker:oldCardId];
    if (oldPoker != nil){
        [_replacedPokers addObject:[ReplacedPoker replacedPokerWithOldPoker:oldPoker newPoker:[Poker pokerFromPBPoker:newPoker]]];
        [_pokers removeObject:oldPoker];
        [_pokers addObject:[Poker pokerFromPBPoker:newPoker]];
    }
}

- (int)changeCardTimes
{
    return [_replacedPokers count];
}

@end
