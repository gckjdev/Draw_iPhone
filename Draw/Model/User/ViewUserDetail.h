//
//  ViewUserDetail.h
//  Draw
//
//  Created by Kira on 13-3-18.
//
//

#import <Foundation/Foundation.h>
#import "UserDetailProtocol.h"

@interface ViewUserDetail : NSObject<UserDetailProtocol>



+ (ViewUserDetail*)viewUserDetailWithUserId:(NSString*)userId
                                     avatar:(NSString*)avatar
                                   nickName:(NSString*)nickName;
@end
