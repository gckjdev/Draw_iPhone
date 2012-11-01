//
//  Poker.h
//  Draw
//
//  Created by 王 小涛 on 12-10-24.
//
//

#import <Foundation/Foundation.h>
#import "ZhaJinHua.pb.h"

@interface Poker : NSObject

@property (readonly, nonatomic) int pokerId;
@property (readonly, nonatomic) PBPokerRank rank;
@property (readonly, nonatomic) PBPokerSuit suit;
@property (readonly, nonatomic) BOOL faceUp;

+ (Poker *)pokerFromPBPoker:(PBPoker *)pbPoker;

// for test
+ (Poker *)pokerWithPokerId:(int)pokerId
                       rank:(PBPokerRank)rank
                       suit:(PBPokerSuit)suit
                     faceUp:(BOOL)faceUp;

- (void)setFaceUp;

@end
