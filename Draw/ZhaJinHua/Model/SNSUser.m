//
//  SNSUser.m
//  Draw
//
//  Created by 王 小涛 on 12-11-7.
//
//

#import "SNSUser.h"

@implementation SNSUser

#pragma mark - life cycle

- (void)dealloc
{
    [_userId release];
    [_nickName release];
    [_accessToken release];
    [_accessTokenSecret release];
    [super dealloc];
}

- (id)initWithPBSNSUser:(PBSNSUser *)pbSNSUser
{
    if (self = [super init]) {
        self.userId = pbSNSUser.userId;
        self.type = pbSNSUser.type;
        self.nickName = pbSNSUser.nickName;
        self.accessToken = pbSNSUser.accessToken;
        self.accessTokenSecret = pbSNSUser.accessTokenSecret;
    }
    
    return self;
}

+ (SNSUser *)fromPBSNSUser:(PBSNSUser *)pbSNSUser
{
    return [[[SNSUser alloc] initWithPBSNSUser:pbSNSUser] autorelease];
}


@end
