//
//  CommonGameUser.m
//  Draw
//
//  Created by 王 小涛 on 12-11-7.
//
//

#import "CommonGameUser.h"
//#import "SNSUser.h"

@implementation CommonGameUser

#pragma mark - life cycle.

- (void)dealloc
{
    [_userId release];
    [_nickName release];
    [_avatar release];
    [_snsUsers release];
    [_city release];
    [_attributes release];
    [super dealloc];
}

- (id)initWithPBGameUser:(PBGameUser *)pbGameUser
{
    if (self = [super init]) {
        self.userId = pbGameUser.userId;
        self.nickName = pbGameUser.nickName;
        self.avatar = pbGameUser.avatar;
        self.gender = pbGameUser.gender;
        
        self.snsUsers = pbGameUser.snsUsersList;
        
        self.city = pbGameUser.location;
        self.seatId = pbGameUser.seatId;
        self.attributes = [self attributesFromKeyValuePairs:pbGameUser.attributesList];
    }
    
    return self;
}

+ (CommonGameUser *)fromPBGameUser:(PBGameUser *)pbGameUser
{
    return [[[CommonGameUser alloc] initWithPBGameUser:pbGameUser] autorelease];
}

#pragma mark - pravite methods.

//- (NSArray *)snsUsersFromPBSNSUsersList:(NSArray *)pbSnsUsersList
//{
//    NSMutableArray *snsUsers = [NSMutableArray array];
//    for (PBSNSUser *pbSnsUser in snsUsersList) {
//        [snsUsers addObject:[SNSUser fromPBSNSUser:pbSnsUser]];
//    }
//}

- (NSDictionary *)attributesFromKeyValuePairs:(NSArray *)keyValuePairs
{
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    for (PBKeyValue *keyValue in keyValuePairs) {
        [attributes setObject:keyValue.value forKey:keyValue.name];
    }
    
    return attributes;
}


@end
