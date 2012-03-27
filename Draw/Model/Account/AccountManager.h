//
//  AccountManager.h
//  Draw
//
//  Created by  on 12-3-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserAccount;
@interface AccountManager : NSObject
{

}
+ (AccountManager *)defaultManager;


@end

extern AccountManager* GlobalGetAccountManager();
