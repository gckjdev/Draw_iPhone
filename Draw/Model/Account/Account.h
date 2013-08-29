//
//  Account.h
//  Draw
//
//  Created by  on 12-3-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum  {
    CheckInType = 1,
    PurchaseType = 2,
    BuyItemType = 3,
    DrawRewardType = 4,
    GuessRewardType = 5,
    ShareWeiboReward = 6,
    ShareAppReward = 7,
    YoumiAppReward = 8,
    LmAppReward = 9,
    
    EscapeType = 10,
    ChangeRoomType = 11,
    FollowReward = 12,
    LevelUpAward = 13,
    
    BuyAnswer = 14,
    
    AwardCoinType = 10001,
    DirectAwardCoinType = 10002,
    
    RefundForVerifyReceiptFailure = 21,
    
    LiarDiceWinType = 200,
    LiarDiceFleeType = 201,
    LiarDiceDailyAward = 202,
    
    MoneyTreeAward = 203,
    
    BBSReward = 300,
    
    SuperUserCharge = 400,
    
    ChargeAsAGift = 420,
    
    ChargeViaBuyPurseItem = 430,
    ChargeViaAlipay = 431,
    
    ChargeLearnDraw = 450,
    
    DeductInHappyGuessMode = 460,
    DeductInGeniusGuessMode = 470,
    DeductInContestGuessMode = 480
    
}BalanceSourceType;

@interface UserAccount : NSObject
{
    NSNumber *_balance;
}
@property(nonatomic, assign)NSNumber *balance;

@end
