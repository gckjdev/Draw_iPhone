//
//  UserStatusService.h
//  Draw
//
//  Created by  on 12-7-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommonService.h"

enum {
    
    USER_STATUS_ONLINE = 0,
    USER_STATUS_OFFLINE    
};

@interface UserStatusService : CommonService
{
    
}

@property (nonatomic, retain) NSTimer *timer;

+ (UserStatusService*)defaultService;

- (void)start;
- (void)stop;


@end
