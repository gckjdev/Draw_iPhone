//
//  DrawFeed.h
//  Draw
//
//  Created by  on 12-8-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Feed.h"

typedef enum{
    ActionTypeHidden = 0,
    ActionTypeOneMore = 1,
    ActionTypeGuess = 2,
    ActionTypeCorrect = 3,
    ActionTypeChallenge = 4
}ActionType;

@class PBLearnDraw;
@interface DrawFeed : Feed<NSCoding>
{
    Draw *_drawData;
    UIImage *_drawImage;
    NSString *_wordText;
    NSString *_drawImageUrl;
    NSSet *_timesSet;
    UIImage *_largeImage;
    PBDraw *_pbDraw;
    DeviceType _deviceType;
}

@property (nonatomic, retain) UIImage *drawImage;
@property (nonatomic, retain) UIImage *largeImage;
@property (nonatomic, retain) NSString *wordText;
@property (nonatomic, retain) Draw *drawData;
@property (nonatomic, retain) NSString *drawImageUrl; // __attribute__((deprecated));
@property (nonatomic, retain) NSSet *timesSet;
@property (nonatomic, retain) NSData *pbDrawData;
@property (nonatomic, assign) DeviceType deviceType;
@property (nonatomic, retain) NSString *opusDesc;
@property (nonatomic, retain) NSString *contestId;
@property (nonatomic, retain) NSString *drawDataUrl;
@property (nonatomic, retain) PBLearnDraw *learnDraw;

- (NSURL *)thumbURL;
- (NSURL *)largeImageURL;

- (id)initWithFeedId:(NSString *)feedId
              userId:(NSString *)userId 
            nickName:(NSString *)nickName 
              avatar:(NSString *)avatar 
              gender:(BOOL)gender
           signature:(NSString *)signature
                 vip:(int)vip
        drawImageUrl:(NSString *)drawImageUrl 
              pbDraw:(PBDraw *)pbDraw 
            wordText:(NSString *)wordText
           contestId:(NSString *)contestId
          timesArray:(NSArray *)timesArray;


- (void)parseDrawData;
- (BOOL)isMyOpus;
- (BOOL)hasGuessed;
- (void)incGuessTimes;
- (void)incCorrectTimes;
- (void)incPlayTimes;

- (void)updateFeedTimesFromDict:(NSDictionary *)dict;
- (void)setTimes:(NSInteger)times forType:(FeedTimesType)type;

- (void)incTimesForType:(NSInteger)type;
- (void)decTimesForType:(NSInteger)type;

- (NSInteger)guessTimes;
- (NSInteger)matchTimes;
- (NSInteger)commentTimes;
- (NSInteger)saveTimes;
- (NSInteger)correctTimes;
- (NSInteger)flowerTimes;
- (NSInteger)tomatoTimes;
- (NSInteger)playTimes;

- (NSInteger)contestCommentTimes;
- (ActionType)actionType;


- (BOOL)isContestFeed;

- (void)decreaseLocalFlowerTimes;

- (void)increaseLocalFlowerTimes;
- (void)increaseLocalTomatoTimes;
- (void)increaseSaveTimes;


- (NSInteger)itemLimit;
- (NSInteger)saveLimit;

//user action limit
- (BOOL)canSendFlower;
- (BOOL)canThrowTomato;
- (BOOL)canSave;

- (NSArray*)opusClassInfoList;

@end
