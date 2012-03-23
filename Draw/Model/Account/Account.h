//
//  Account.h
//  Draw
//
//  Created by  on 12-3-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Account : NSObject<NSCoding>
{
    NSNumber *_balance;
}
@property(nonatomic, assign)NSNumber *balance;

+ (Account *)defaultAccount;
+ (Account *)accountWithBalance:(NSInteger)balance;
@end
