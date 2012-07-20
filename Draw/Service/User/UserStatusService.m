//
//  UserStatusService.m
//  Draw
//
//  Created by  on 12-7-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UserStatusService.h"

@implementation UserStatusService

UserStatusService* _defaultService;

+ (UserStatusService*)defaultService
{
    if (_defaultService == nil)
        _defaultService = [[UserStatusService alloc] init];
    
    return _defaultService;
}

- (void)reportStatusOnline
{
    
}

- (void)reportStatusOffline
{
    
}

@end
