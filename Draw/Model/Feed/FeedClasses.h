//
//  FeedClasses.h
//  Draw
//
//  Created by  on 12-8-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeedUser : NSObject<NSCoding>
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
@property(nonatomic, retain)NSString *signature;

- (id)initWithUserId:(NSString *)userId 
            nickName:(NSString *)nickName 
              avatar:(NSString *)avatar 
              gender:(BOOL)gender
           signature:(NSString*)signature;

+ (FeedUser *)feedUserWithUserId:(NSString *)userId 
                        nickName:(NSString *)nickName
                          avatar:(NSString *)avatar
                          gender:(BOOL)gender
                       signature:(NSString*)signature;

- (NSString *)genderString;
@end

typedef enum{
    FeedTimesTypeMatch = 1, //
    FeedTimesTypeGuess = 2,
    FeedTimesTypeCorrect = 3,
    FeedTimesTypeComment = 4,
    FeedTimesTypeFlower = 5,
    FeedTimesTypeTomato = 6,//
    FeedTimesTypeSave = 7
}FeedTimesType;



@class PBFeedTimes;
@interface FeedTimes : NSObject<NSCoding>
{
    NSInteger _type;
    NSInteger _times;
}
@property(nonatomic, assign)NSInteger type;
@property(nonatomic, assign)NSInteger times;

- (id)initWithPbFeedTimes:(PBFeedTimes *)pbFeedTimes;
- (id)initWithType:(NSInteger)type times:(NSInteger)times;

+ (FeedTimes *)feedTimesWithPbFeedTimes:(PBFeedTimes *)pbFeedTimes;
+ (FeedTimes *)feedTimesWithType:(NSInteger)type times:(NSInteger)times;

@end


