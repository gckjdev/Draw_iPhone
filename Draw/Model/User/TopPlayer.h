//
//  TopPlayer.h
//  Draw
//
//  Created by  on 12-9-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TopPlayer : NSObject
{
    NSString *_userId;
    NSString *_nickName;
    NSString *_avatar;
    NSInteger _level;
    long _exp;
    NSInteger _opusCount;
    BOOL _gender;
}

@property(nonatomic, retain)NSString *userId;
@property(nonatomic, retain)NSString *nickName;
@property(nonatomic, retain)NSString *avatar;
@property(nonatomic, assign)NSInteger level;
@property(nonatomic, assign)long exp;
@property(nonatomic, assign)BOOL gender;
@property(nonatomic, assign)NSInteger opusCount;

- (id)initWithDict:(NSDictionary *)dict;
@end
