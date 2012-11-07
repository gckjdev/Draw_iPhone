//
//  SNSUser.h
//  Draw
//
//  Created by 王 小涛 on 12-11-7.
//
//

#import <Foundation/Foundation.h>
#import "GameBasic.pb.h"

@interface SNSUser : NSObject

@property (retain, nonatomic) NSString *userId;
@property (assign, nonatomic) int type;
@property (retain, nonatomic) NSString *nickName;
@property (retain, nonatomic) NSString *accessToken;
@property (retain, nonatomic) NSString *accessTokenSecret;

+ (SNSUser *)fromPBSNSUser:(PBSNSUser *)pbSNSUser;

@end
