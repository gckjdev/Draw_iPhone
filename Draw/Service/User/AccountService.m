//
//  AccountService.m
//  Draw
//
//  Created by  on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AccountService.h"

@implementation AccountService

static AccountService* _defaultAccountService;

+ (AccountService*)defaultService
{
    if (_defaultAccountService == nil)
        _defaultAccountService = [[AccountService alloc] init];
    
    return _defaultAccountService;
}



@end
