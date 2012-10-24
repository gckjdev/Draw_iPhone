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
@property (readonly, nonatomic) int rank;
@property (readonly, nonatomic) int suit;
@property (readonly, nonatomic) BOOL faceUp;

+ (Poker *)pokerFromPBPoker:(PBPoker *)pbPoker;
- (void)setFaceUp;

@end
