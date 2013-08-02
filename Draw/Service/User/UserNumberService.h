//
//  UserNumberService.h
//  Draw
//
//  Created by qqn_pipi on 13-7-24.
//
//

#import <Foundation/Foundation.h>
#import "CommonService.h"

typedef void(^UserNumberServiceResultBlock)(int resultCode, NSString* number);


@interface UserNumberService : CommonService

+ (UserNumberService*)defaultService;

- (void)getAndRegisterNumber:(UserNumberServiceResultBlock)block;
- (void)getOneNumber:(UserNumberServiceResultBlock)block;
- (void)takeUserNumber:(NSString*)number block:(UserNumberServiceResultBlock)block;
- (void)loginUser:(NSString*)number password:(NSString*)password block:(UserNumberServiceResultBlock)block;

- (void)askForLogout;

@end
