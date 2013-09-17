//
//  UserDeviceService.h
//  Draw
//
//  Created by qqn_pipi on 13-7-12.
//
//

#import <Foundation/Foundation.h>
#import "UserService.h"

@interface UserDeviceService : NSObject

+ (UserDeviceService*)defaultService;

- (void)uploadUserDeviceInfo:(BOOL)forceUpload;

- (void)removeUserDevice:(UpdateUserResultBlock)resultBlock;

@end
