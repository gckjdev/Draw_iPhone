//
//  DrawFeed.m
//  Draw
//
//  Created by  on 12-8-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DrawFeed.h"
#import "Draw.h"
#import "ShareImageManager.h"
#import "GameNetworkConstants.h"
#import "PPConfigManager.h"
#import "FeedManager.h"
#import "Draw.pb-c.h"
#import "GameBasic.pb-c.h"
#import "ContestManager.h"

@implementation DrawFeed

- (void)setTimeList:(NSArray *)feedTimesList
{
    if ([feedTimesList count] !=0 ) {
        NSMutableSet *set = [[NSMutableSet alloc] init];
        for (PBFeedTimes *pbFeedTimes in feedTimesList) {
            FeedTimes *feedTimes = [FeedTimes feedTimesWithPbFeedTimes:pbFeedTimes];
            [set addObject:feedTimes];
        }            
        self.timesSet = set;
        [set release];
    }    
}



- (id)initWithPBFeed:(PBFeed *)pbFeed
{
    self = [super initWithPBFeed:pbFeed];
    if (self) {
        //set times info
        [self setTimeList:pbFeed.feedTimesList];

        if ([pbFeed hasDrawData]) {
            self.pbDrawData = [pbFeed.drawData data];
        }

        //set draw info
        self.wordText = pbFeed.opusWord;
        self.drawImageUrl = pbFeed.opusImage;
//        [self initDrawInfo:pbFeed.opusImage data:nil];
        self.deviceType = pbFeed.deviceType;
        self.opusDesc = pbFeed.opusDesc;
        self.drawDataUrl = pbFeed.drawDataUrl;
        self.contestId = pbFeed.contestId;
    
        if ([pbFeed hasLearnDraw]) {
            self.learnDraw = pbFeed.learnDraw;    
        }
        
        PPDebug(@"<DrawFeed> id(%@) user(%@, %@) text(%@)", pbFeed.feedId, pbFeed.userId, pbFeed.nickName, self.wordText);
        
    }
    return self;
}


#define KEY_WORD_TEXT @"WORD_TEXT"
#define KEY_DRAW @"DRAW"
#define KEY_IMAGE @"IMAGE"
#define KEY_TIMES @"TIMES"
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.wordText = [aDecoder decodeObjectForKey:KEY_WORD_TEXT];
        self.drawData = [aDecoder decodeObjectForKey:KEY_DRAW];
        self.drawImageUrl = [aDecoder decodeObjectForKey:KEY_IMAGE];
        self.timesSet = [aDecoder decodeObjectForKey:KEY_TIMES];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.wordText forKey:KEY_WORD_TEXT];
    [aCoder encodeObject:self.drawData forKey:KEY_DRAW];
    [aCoder encodeObject:self.drawImageUrl forKey:KEY_IMAGE];
    [aCoder encodeObject:self.timesSet forKey:KEY_TIMES];
}


#define MAX_DRAW_DATA_SIZE 1024*1024*10

- (void)parseDrawData
{
    @synchronized(self){ // add lock here to make it as safe call        
        if (self.drawData == nil && self.pbDrawData != nil) {
            NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
            
            PPDebug(@"<parseDrawData> start to parse DrawData......");
            int start = time(0);
            
            // refactor by using C lib        
            Game__PBDraw* pbDrawC = NULL;    
            int dataLen = [self.pbDrawData length];
            if (dataLen > 0){
                uint8_t* buf = malloc(dataLen);
                if (buf != NULL){
                    
                    // TODO PBDRAWC to be optimized since this will duplicate data , double size of memory
                    [self.pbDrawData getBytes:buf length:dataLen];
                    pbDrawC = game__pbdraw__unpack(NULL, dataLen, buf);
                    free(buf);
                    
                    Draw* drawData = [[Draw alloc] initWithPBDrawC:pbDrawC];
                    self.drawData = drawData;
                    
                    game__pbdraw__free_unpacked(pbDrawC, NULL);
                    [drawData release];
                }
            }

            
            int end = time(0);
            PPDebug(@"<parseDrawData> parse draw data complete, take %d seconds", end - start);
            
            [pool drain];
        }
    }

}

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
{
    self = [super init];
    if (self) {
        self.feedId = feedId;
        self.feedUser = [FeedUser feedUserWithUserId:userId 
                                            nickName:nickName 
                                              avatar:avatar 
                                              gender:gender
                                           signature:signature
                                                 vip:vip];
        self.wordText = wordText;
        self.contestId = contestId;
        [self setTimeList:timesArray];
        self.drawImageUrl = drawImageUrl;
        
//        PPDebug(@"<DrawFeed> id(%@) user(%@, %@) text(%@)", feedId, userId, nickName, wordText);
    }
    return self;
}

- (void)updateDesc
{
    NSString *kCreateDesc = NSLS(@"kDrawDesc");
    NSString *kCreateDescNoName = NSLS(@"kDrawDescNoWord");
    
    if ([self isDrawCategory] == NO){
        kCreateDesc = NSLS(@"kCreateDesc");
        kCreateDescNoName = NSLS(@"kCreateDescNoName");
    }
    
    if ([self isMyOpus]) {
        self.desc = [NSString stringWithFormat:kCreateDesc, self.wordText];      
    }else if ([self hasGuessed]) {
        self.desc = [NSString stringWithFormat:kCreateDesc, self.wordText];      
    }else{
        self.desc = [NSString stringWithFormat:kCreateDescNoName, self.wordText];      
    }
}

- (BOOL)isMyOpus
{
    UserManager *defaultManager  = [UserManager defaultManager];
    return [defaultManager isMe:self.author.userId];
}

- (BOOL)showAnswer
{
    if ([self isMyOpus]) {
        return YES;
    }
    if ([self hasGuessed])
    {
        return YES;
    }
    if ([self isContestFeed]) {
        return YES;
    }
    return NO;
}


- (BOOL) hasGuessed
{
    UserManager *defaultManager  = [UserManager defaultManager];
    return [defaultManager hasGuessOpus:self.feedId];    
}

- (FeedUser *)author
{
    return self.feedUser;
}
- (void)incTimesForType:(NSInteger)type
{
    for (FeedTimes *feedTimes in self.timesSet) {
        if (feedTimes.type == type) {
            feedTimes.times ++;
        }
    }
}

- (void)decTimesForType:(NSInteger)type
{
    for (FeedTimes *feedTimes in self.timesSet) {
        if (feedTimes.type == type) {
            feedTimes.times --;
        }
    }    
}
- (NSInteger)timesForType:(NSInteger)type
{
    for (FeedTimes *feedTimes in self.timesSet) {
        if (feedTimes.type == type) {
            return MAX(feedTimes.times, 0);
        }
    }
    return 0;
}

- (void)incGuessTimes
{
    [self incTimesForType:FeedTimesTypeGuess];
}
- (void)incCorrectTimes
{
    [self incTimesForType:FeedTimesTypeCorrect];    
}

- (void)incPlayTimes
{
    [self incTimesForType:FeedTimesTypePlay];
}

- (NSInteger)guessTimes
{
    return [self timesForType:FeedTimesTypeGuess];
}
- (NSInteger)matchTimes
{
    return [self timesForType:FeedTimesTypeMatch];    
}
- (NSInteger)correctTimes
{
    return [self timesForType:FeedTimesTypeCorrect];    
}

- (NSInteger)commentTimes
{
    return [self timesForType:FeedTimesTypeComment];    
}

- (NSInteger)saveTimes
{
    return [self timesForType:FeedTimesTypeSave];
}
- (NSInteger)flowerTimes
{
    return [self timesForType:FeedTimesTypeFlower];
}
- (NSInteger)tomatoTimes
{
    return [self timesForType:FeedTimesTypeTomato];
}
- (NSInteger)contestCommentTimes
{
    if ([self isContestFeed]) {
        return [self timesForType:FeedTimesTypeContestComment];
    }
    return 0;
}

- (NSInteger)playTimes
{
    return [self timesForType:FeedTimesTypePlay];
}


- (ActionType)actionType
{
    BOOL isMyOpus = [self isMyOpus];
    UserManager *userManager = [UserManager defaultManager];
    if (isMyOpus) {
        return ActionTypeHidden;
    }
    
    if ([self isOpusType]) {
        if ([userManager hasGuessOpus:self.feedId]) {
            return ActionTypeChallenge;
        }else{
            return ActionTypeGuess;
        }
    }
    return ActionTypeHidden;
}

- (void)setTimes:(NSInteger)times forType:(FeedTimesType)type
{
    for (FeedTimes *feedTime in _timesSet) {
        if (feedTime.type == type) {
            feedTime.times = times;
            return;
        }
    }
}

- (void)updateTimesWithType:(FeedTimesType)type 
                        key:(NSString *)key 
                     inDict:(NSDictionary *)dict
{
    NSNumber *times = [dict objectForKey:key];
    [self setTimes:times.integerValue forType:type];
}

- (void)updateFeedTimesFromDict:(NSDictionary *)dict
{
    [self updateTimesWithType:FeedTimesTypeComment key:PARA_COMMENT_TIMES inDict:dict];
    [self updateTimesWithType:FeedTimesTypeGuess key:PARA_GUESS_TIMES inDict:dict];
    [self updateTimesWithType:FeedTimesTypeCorrect key:PARA_CORRECT_TIMES inDict:dict];
    [self updateTimesWithType:FeedTimesTypeFlower key:PARA_FLOWER_TIMES inDict:dict];
    [self updateTimesWithType:FeedTimesTypeTomato key:PARA_TOMATO_TIMES inDict:dict];
    [self updateTimesWithType:FeedTimesTypeSave key:PARA_SAVE_TIMES inDict:dict];
    [self updateTimesWithType:FeedTimesTypePlay key:PARA_PLAY_TIMES inDict:dict];
}


- (BOOL)isContestFeed
{
//    return self.feedType == FeedTypeDrawToContest;

    return [self.contestId length] > 0;
}

//user action limit 

#define FLOWER_PREFIX @"flower"
#define TOMATO_PREFIX @"tomato"
#define SAVE_PREFIX @"save"

- (NSString *)flowerKey
{
    NSString *key = [NSString stringWithFormat:@"%@_%@",FLOWER_PREFIX,self.feedId];
    return key;
}
- (NSString *)tomatoKey
{
    NSString *key = [NSString stringWithFormat:@"%@_%@",TOMATO_PREFIX,self.feedId];
    return key;
}
- (NSString *)saveKey
{
    NSString *key = [NSString stringWithFormat:@"%@_%@",SAVE_PREFIX,self.feedId];
    return key;
}

- (NSInteger)actionTimesForKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *number = [defaults objectForKey:key];
    return number.intValue;
}

- (void)increaseActionTimes:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int value = [self actionTimesForKey:key];
    NSNumber *number = [NSNumber numberWithInt:++value];
    [defaults setObject:number forKey:key];
    [defaults synchronize];
}

- (void)decreaseLocalFlowerTimes
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    int value = [self actionTimesForKey:self.flowerKey];
    NSNumber *number = [NSNumber numberWithInt:--value];
    [defaults setObject:number forKey:self.flowerKey];
    [defaults synchronize];
}
- (void)increaseLocalFlowerTimes
{
    [self increaseActionTimes:self.flowerKey];
}
- (void)increaseLocalTomatoTimes
{
    [self increaseActionTimes:self.tomatoKey];
}
- (void)increaseSaveTimes
{
    [self increaseActionTimes:self.saveKey];
}

- (NSInteger)localFlowerTimes
{
    int value = [self actionTimesForKey:self.flowerKey];
    return value;
}
- (NSInteger)localTomatoTimes
{
    return [self actionTimesForKey:self.tomatoKey];    
}
- (NSInteger)localSaveTimes
{
    return [self actionTimesForKey:self.saveKey];
}

- (NSInteger)itemLimit
{
    if ([self.contestId length] > 0){
        Contest* contest = [[ContestManager defaultManager] ongoingContestById:self.contestId];
        if (contest == nil){
            return 0;
        }
        else{
            return [contest maxFlowerPerOpus];
        }
        
    }
    else{
        return [PPConfigManager numberOfItemCanUsedOnNormalOpus];
    }
}

- (NSInteger)saveLimit
{
    return 10;
}

- (BOOL)canSendFlower
{
//    PPDebug(@"<canSendFlower> local flower times(%d) VS limit(%d)", [self localFlowerTimes], self.itemLimit);
    return [self localFlowerTimes] < self.itemLimit;
}

- (BOOL)canThrowTomato
{
    return [self localTomatoTimes] < self.itemLimit;
}

- (BOOL)canSave
{
    return [self localSaveTimes] < self.saveLimit;
}



#define IMAGE_SUFFIX @".jpg"
#define THUMB_IMAGE_SUFFIX @"_m.jpg"

- (NSURL *)thumbURL
{
    NSString *url =  self.drawImageUrl;
    if (![self.drawImageUrl hasSuffix:THUMB_IMAGE_SUFFIX] && [self.drawImageUrl hasSuffix:IMAGE_SUFFIX]) {
        NSUInteger loc = [self.drawImageUrl rangeOfString:IMAGE_SUFFIX].location;
        if (loc != NSNotFound) {
            url = [self.drawImageUrl substringToIndex:loc];
            url = [url stringByAppendingString:THUMB_IMAGE_SUFFIX];
            
        }
    }
    return [NSURL URLWithString:url];
}

- (NSURL *)largeImageURL
{
    NSString *url =  self.drawImageUrl;
    if ([self.drawImageUrl hasSuffix:THUMB_IMAGE_SUFFIX]) {
        NSUInteger loc = [self.drawImageUrl rangeOfString:THUMB_IMAGE_SUFFIX].location;
        if (loc != NSNotFound) {
            url = [self.drawImageUrl substringToIndex:loc];
            url = [url stringByAppendingString:IMAGE_SUFFIX];
        }
    }
    return [NSURL URLWithString:url];
}

//- (BOOL)hasDrawActions
//{
//    return [self.pbDraw.drawDataList count] != 0;
//}

- (void)dealloc
{
//    PPDebug(@"%@ dealloc", [self description]);
    PPRelease(_contestId);
    PPRelease(_pbDrawData);
    PPRelease(_drawImage);    
    PPRelease(_drawData);
    PPRelease(_wordText);    
    PPRelease(_drawImageUrl);
    PPRelease(_timesSet);    
    PPRelease(_largeImage);
    PPRelease(_opusDesc);
    PPRelease(_feedUser);
    PPRelease(_learnDraw);
    [super dealloc];
}


@end
