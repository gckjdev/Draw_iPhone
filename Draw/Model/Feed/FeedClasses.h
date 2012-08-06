//
//  FeedClasses.h
//  Draw
//
//  Created by  on 12-8-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeedUser : NSObject
{
    NSString *_userId;
    NSString *_nickName;
    NSString *_avatar;
    BOOL _gender;
}

@property(nonatomic, retain)NSString *userId;
@property(nonatomic, retain)NSString *nickName;
@property(nonatomic, retain)NSString *avatar;
@property(nonatomic, assign)BOOL gender;

- (id)initWithUserId:(NSString *)userId 
            nickName:(NSString *)nickName 
              avatar:(NSString *)avatar 
              gender:(BOOL)gender;

+ (FeedUser *)feedUserWithUserId:(NSString *)userId 
            nickName:(NSString *)nickName 
              avatar:(NSString *)avatar 
              gender:(BOOL)gender;


@end

@interface FeedTimes : NSObject
{
    NSInteger _type;
    NSInteger _times;
}
@property(nonatomic, assign)NSInteger type;
@property(nonatomic, assign)NSInteger times;

- (id)initWithType:(NSInteger)type times:(NSInteger)times;
+ (FeedTimes *)feedTimesWithType:(NSInteger)type times:(NSInteger)times;

@end


