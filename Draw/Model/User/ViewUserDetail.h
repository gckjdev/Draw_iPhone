//
//  ViewUserDetail.h
//  Draw
//
//  Created by Kira on 13-3-18.
//
//

#import <Foundation/Foundation.h>
#import "UserDetailProtocol.h"
#import "FeedService.h"

@interface ViewUserDetail : NSObject<UserDetailProtocol, FeedServiceDelegate>


@property (assign, nonatomic) RelationType relation;

+ (ViewUserDetail*)viewUserDetailWithUserId:(NSString*)userId
                                     avatar:(NSString*)avatar
                                   nickName:(NSString*)nickName;


@end
