//
//  Account.h
//  Draw
//
//  Created by  on 12-3-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserAccount : NSObject<NSCoding>
{
    NSNumber *_balance;
}
@property(nonatomic, assign)NSNumber *balance;

+ (UserAccount *)defaultAccount;
+ (UserAccount *)accountWithBalance:(NSInteger)balance;
@end
