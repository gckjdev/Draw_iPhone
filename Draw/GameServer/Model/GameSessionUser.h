//
//  GameSessionUser.h
//  Draw
//
//  Created by  on 12-3-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PBGameUser;

@interface GameSessionUser : NSObject

@property (nonatomic, retain) NSString *userId;
@property (nonatomic, retain) NSString *nickName;
@property (nonatomic, retain) NSString *userAvatar;

+ (GameSessionUser*)fromPBUser:(PBGameUser*)pbUser;

@end
