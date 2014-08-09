//
//  UserNumberService.h
//  Draw
//
//  Created by qqn_pipi on 13-7-24.
//
//

#import <Foundation/Foundation.h>
#import "CommonService.h"
#import "UserManager.h"
#import "UserService.h"

#define CHECK_AND_LOGIN(showInView)\
if(![[UserService defaultService] isRegistered])\
{\
    [[UserService defaultService] checkAndAskLogin:showInView];\
    return;\
}


typedef void(^UserNumberServiceResultBlock)(int resultCode, NSString* number);


@interface UserNumberService : CommonService

+ (UserNumberService*)defaultService;

- (void)getAndRegisterNumber:(UserNumberServiceResultBlock)block;
- (void)getOneNumber:(UserNumberServiceResultBlock)block;
- (void)shakeOneNumber:(UserNumberServiceResultBlock)block;
- (void)takeUserNumber:(NSString*)number block:(UserNumberServiceResultBlock)block;
- (void)loginUser:(NSString*)number password:(NSString*)password block:(UserNumberServiceResultBlock)block;
- (void)loginUser:(NSString*)number encodedPassword:(NSString*)password block:(UserNumberServiceResultBlock)block;
- (void)registerNewUserNumber:(UserNumberServiceResultBlock)block;

- (void)askForLogout;

@end
