//
//  ZJHUserInfo.h
//  Draw
//
//  Created by 王 小涛 on 12-10-24.
//
//

#import <Foundation/Foundation.h>
#import "ZhaJinHua.pb.h"

@interface ZJHUserInfo : NSObject

@property (copy, nonatomic) NSString *userId;
@property (retain, nonatomic) NSArray *pokers;
@property (assign, nonatomic) 


message PBPoker{
optional int32 pokerId = 1;                                 // 扑克Id
required PBPokerRank rank= 2;                             // 扑克点数
required PBPokerSuit suit= 3;                             // 扑克花色
optional bool faceUp = 5 [default = false];               // 牌面是否朝上
}

message PBZJHUserInfo{
    required string userId = 1;       // 用户Id
    repeated PBPoker pokers = 2;      // 用户的扑克牌
    
    optional PBZJHCardType type = 3  [default=ZJH_CARD_TYPE_HIGH_CARD];     // 牌类型
    
    optional int32 userBet = 5;                                           // 用户下的总注
    optional bool isCallingStation = 6 [default = false];                 // 是否跟到底
    optional PBZJHUserState state = 7 [default = ZJH_STATE_DEFAULT];        // 用户最近的状态
    optional bool canBeCompared = 8 [default = true];                     // 能否被比牌
}

@end
