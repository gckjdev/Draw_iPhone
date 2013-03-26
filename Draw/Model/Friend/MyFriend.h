//
//  MyFriend.h
//  Draw
//
//  Created by  on 12-10-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


//public static final int RELATION_FRIEND = 3;
//public static final int RELATION_FAN = 2;
//public static final int RELATION_FOLLOW = 1;

typedef enum{
    RelationTypeSelf = -1,
    RelationTypeNo = 0,
    RelationTypeFollow = 1,
    RelationTypeFan = 2,
    RelationTypeFriend = 3,
    RelationTypeBlack = 4,
}RelationType;


@interface MyFriend : NSObject
{
    NSString *_friendUserId;
    NSString *_nickName;
    NSString *_avatar;
    NSString *_gender;
    NSString *_sinaId;
    NSString *_qqId;
    NSString *_facebookId;
    NSString *_sinaNick;
    NSString *_qqNick;
    NSString *_facebookNick;
    NSDate   *_createDate;
    NSDate   *_lastModifiedDate;
    NSString *_location;
    
    NSInteger _level;
    NSInteger _type;
    NSInteger _onlineStatus;
    long _coins;
    RelationType _relation;
    
}
@property (nonatomic, retain) NSString * friendUserId;
@property (nonatomic, retain) NSString * nickName;
@property (nonatomic, retain) NSString * avatar;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * sinaId;
@property (nonatomic, retain) NSString * qqId;
@property (nonatomic, retain) NSString * facebookId;
@property (nonatomic, retain) NSString * sinaNick;
@property (nonatomic, retain) NSString * qqNick;
@property (nonatomic, retain) NSString * facebookNick;
@property (nonatomic, retain) NSDate   * createDate;
@property (nonatomic, retain) NSDate   * lastModifiedDate;
@property (nonatomic, retain) NSString * location;

@property (nonatomic, assign) NSInteger level;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, assign) NSInteger onlineStatus;
@property (nonatomic, assign) long coins;
@property (nonatomic, assign) RelationType relation;

- (id)initWithDict:(NSDictionary *)dict;
+ (id)friendWithDict:(NSDictionary *)dict;

- (id)initWithFid:(NSString *)fid 
         nickName:(NSString *)nickName
           avatar:(NSString *)avatar
           gender:(NSString *)gender 
            level:(NSInteger)level;

+ (id)friendWithFid:(NSString *)fid 
         nickName:(NSString *)nickName
           avatar:(NSString *)avatar
           gender:(NSString *)gender     
            level:(NSInteger)level;

+ (id)myself;

- (NSString *)friendNick;
- (BOOL)hasFollow;
- (BOOL)isMyFan;
- (BOOL)isMale;
- (BOOL)isSinaUser;
- (BOOL)isQQUser;
- (BOOL)isFacebookUser;
- (NSString *)genderDesc;
- (BOOL)hasBlack;

+ (BOOL)hasFollow:(RelationType)type;
+ (BOOL)hasBlack:(RelationType)type;
+ (BOOL)isMyFan:(RelationType)type;
@end
