//
//  UserNumberService.m
//  Draw
//
//  Created by qqn_pipi on 13-7-24.
//
//

#import "UserNumberService.h"

@implementation UserNumberService

static UserNumberService* _defaultUserService;

+ (UserNumberService*)defaultService
{
    if (_defaultUserService == nil)
        _defaultUserService = [[UserNumberService alloc] init];
    
    return _defaultUserService;
}



@end
