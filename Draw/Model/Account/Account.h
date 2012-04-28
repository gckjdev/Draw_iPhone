//
//  Account.h
//  Draw
//
//  Created by  on 12-3-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum  {
    CheckInType = 1, // 
    PurchaseType = 2,
    BuyItemType = 3,
    DrawRewardType = 4,
    GuessRewardType = 5,
    ShareWeiboReward = 6,
    ShareAppReward = 7,
    
    EscapeType = 10,
    ChangeRoomType = 11,
    
    RefundForVerifyReceiptFailure = 21
    
}BalanceSourceType;

@interface UserAccount : NSObject
{
    NSNumber *_balance;
}
@property(nonatomic, assign)NSNumber *balance;

//+ (UserAccount *)defaultAccount;
//+ (UserAccount *)accountWithBalance:(NSInteger)balance;
//- (NSInteger)intBalanceValue;
@end
