//
//  GameSessionUser.h
//  Draw
//
//  Created by  on 12-3-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PBGameUser;
@class PBSNSUser;

@interface GameSessionUser : NSObject

@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) NSString *nickName;
@property (nonatomic, retain) NSString *userAvatar;
@property (nonatomic, assign) BOOL gender;
@property (nonatomic, retain) NSArray *snsUserData;
@property (nonatomic, retain) NSString *location;
@property (assign, nonatomic) int level;


+ (GameSessionUser*)fromPBUser:(PBGameUser*)pbUser;
- (BOOL)isBindSina;
- (BOOL)isBindQQ;
- (BOOL)isBindFacebook;


@end
