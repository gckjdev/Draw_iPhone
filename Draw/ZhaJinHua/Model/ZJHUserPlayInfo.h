//
//  ZJHUserPlayInfo.h
//  Draw
//
//  Created by 王 小涛 on 12-10-24.
//
//

#import <Foundation/Foundation.h>
#import "ZhaJinHua.pb.h"
#import "Poker.h"
#import "ReplacedPoker.h"

#define ZJH_NUM_POKER_PER_USER 3

@interface ZJHUserPlayInfo : NSObject

@property (readonly, copy, nonatomic) NSString *userId;
@property (retain, nonatomic) NSMutableArray *pokers;
@property (assign, nonatomic) PBZJHCardType cardType;
@property (assign, nonatomic) int totalBet;
@property (assign, nonatomic) BOOL isAutoBet;
@property (assign, nonatomic) PBZJHUserAction lastAction;

@property (assign, nonatomic) BOOL alreadCheckCard;
@property (assign, nonatomic) BOOL alreadFoldCard;
@property (assign, nonatomic) BOOL alreadShowCard;
@property (assign, nonatomic) BOOL alreadCompareLose;
@property (assign, nonatomic) int compareAward;
@property (assign, nonatomic) int resultAward;
@property (retain, nonatomic) NSMutableArray *replacedPokers;

+ (ZJHUserPlayInfo *)fromPBZJHUserPlayInfo:(PBZJHUserPlayInfo *)pbZJHUserPlayInfo;

- (void)changePoker:(int)oldCardId
           newPoker:(PBPoker *)poker;
- (void)setPokersFaceUp:(NSArray *)pokerIds;
- (Poker *)poker:(int)pokerId;
- (int)betCount;

- (BOOL)hasShield;

- (BOOL)canAutoBet;
- (BOOL)canCheckCard;
- (BOOL)canFoldCard;
- (BOOL)canShowCard:(int)cardId;
- (BOOL)canCompareCard;
- (BOOL)canChangeCard:(int)cardId;
- (BOOL)canBeCompared;


- (NSString *)cardTypeString;
- (int)changeCardTimes;

@end
