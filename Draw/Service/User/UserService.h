//
//  UserService.h
//  Draw
//
//  Created by  on 12-3-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonService.h"

@class PPViewController;

@protocol UserServiceDelegate <NSObject>

- (void)didUserRegistered:(int)resultCode;

@end

@interface UserService : CommonService

+ (UserService*)defaultService;

- (void)registerUser:(NSString*)email 
            password:(NSString*)password 
      viewController:(PPViewController<UserServiceDelegate>*)viewController;

@end
