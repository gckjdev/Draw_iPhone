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

@property (retain, nonatomic) PBGameUser* pbUser;

- (id)initWithUserId:(NSString*)userId
              avatar:(NSString*)avatar
            nickName:(NSString*)nickName;
+ (ViewUserDetail*)viewUserDetailWithUserId:(NSString*)userId
                                     avatar:(NSString*)avatar
                                   nickName:(NSString*)nickName;

@end
