//
//  UserDeviceService.m
//  Draw
//
//  Created by qqn_pipi on 13-7-12.
//
//

#import "UserDeviceService.h"

@implementation UserDeviceService

static UserDeviceService* _defaultUserService;

+ (UserDeviceService*)defaultService
{
    if (_defaultUserService == nil)
        _defaultUserService = [[UserDeviceService alloc] init];
    
    return _defaultUserService;
}

@end
