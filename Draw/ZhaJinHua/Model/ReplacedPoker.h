//
//  ReplacedPoker.h
//  Draw
//
//  Created by 王 小涛 on 12-12-4.
//
//

#import <Foundation/Foundation.h>
#import "Poker.h"

@interface ReplacedPoker : NSObject

@property (retain, nonatomic) Poker *oldPoker;
@property (retain, nonatomic) Poker *newPoker;

+ (ReplacedPoker *)replacedPokerWithOldPoker:(Poker *)oldPoker
                                    newPoker:(Poker *)newPoker;

@end
