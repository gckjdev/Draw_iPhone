//
//  UserStatusService.h
//  Draw
//
//  Created by  on 12-7-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonService.h"

@interface UserStatusService : CommonService

+ (UserStatusService*)defaultService;

- (void)reportStatusOnline;
- (void)reportStatusOffline;

@end
