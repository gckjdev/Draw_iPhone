//
//  FeedManager.m
//  Draw
//
//  Created by  on 12-6-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FeedManager.h"
#import "PPDebug.h"
#import "UserManager.h"
#import "Draw.h"
#import "FileUtil.h"

FeedManager *_staticFeedManager = nil;

#define FeedKeyMy @"FeedKeyMy"
#define FeedKeyAll @"FeedKeyAll"
#define FeedKeyHot @"FeedKeyHot"

@implementation FeedManager




+ (NSString *)userNameForFeed:(Feed *)feed
{
    if ([[UserManager defaultManager] isMe:feed.userId]) {
        return NSLS(@"Me");
    }else{
        return [feed nickName];
    }
}
+ (NSString *)targetNameForFeed:(Feed *)feed
{
    if ([[UserManager defaultManager] isMe:feed.targetUid]) {
        return NSLS(@"Me");
    }else if([[feed targetNickName] length] != 0){
        return [feed targetNickName];
    }
    return NSLS(@"kHisFriend");
}


//get name
+ (NSString *)opusCreatorForFeed:(Feed *)feed
{
    NSString *userId = feed.authorId;
    if ([[UserManager defaultManager] isMe:userId]) {
        return NSLS(@"Me");
    }else{
        return feed.authorNick;
    }
}


+ (ActionType)actionTypeForFeed:(Feed *)feed
{
//    BOOL hasGuess = [feed hasGuessed];
    BOOL isMyOpus = [feed isMyOpus];
    
    UserManager *userManager = [UserManager defaultManager];
    if (isMyOpus) {
        return ActionTypeHidden;
    }
    
    if ([feed isDrawType]) {
        if ([userManager hasGuessOpus:feed.feedId]) {
//            return ActionTypeCorrect;
            return ActionTypeChallenge;
        }
        return ActionTypeGuess;
    }else if(feed.feedType == FeedTypeGuess)
    {
        if ([userManager hasGuessOpus:feed.opusId]) {
//            return ActionTypeCorrect;
            return ActionTypeChallenge;
        }else{
            return ActionTypeGuess;
        }
        
//        if ([userManager isMe:feed.drawData.userId]) {
//            return ActionTypeOneMore;
//        }else{
//            return ActionTypeGuess;
//        }
    }
    return ActionTypeHidden;
}

+ (FeedActionDescType)feedActionDescFor:(Feed *)feed
{

    BOOL hasGuessed = [feed hasGuessed];
    hasGuessed |= [feed isMyOpus];
    
    
    if (feed.feedType == FeedTypeDraw) {
        if (hasGuessed) {
            return FeedActionDescDrawed;
        }
        
        //I draw
        if ([[UserManager defaultManager] isMe:feed.userId]) {
            return FeedActionDescDrawed;
        }else{
            return FeedActionDescDrawedNoWord;            
        }
        
    }else if(feed.feedType == FeedTypeDrawToUser)
    {
        if (hasGuessed) {
            return FeedActionDescDrawedToUser;
        }
        
        //I draw
        if ([[UserManager defaultManager] isMe:feed.userId]) {
            return FeedActionDescDrawedToUser;
        }else{
            return FeedActionDescDrawedToUserNoWord;            
        }
        
    }
    else if (feed.feedType == FeedTypeGuess){
        
        if (hasGuessed) {
            if (feed.isCorrect) {
                return FeedActionDescGuessed;                
            }else{
                return FeedActionDescTried;
            }

        }
        //Guess right
        if (feed.isCorrect) {
            //if I Guessed
            if ([[UserManager defaultManager] isMe:feed.userId]) {
                return FeedActionDescGuessed;
            }else{
                return FeedActionDescGuessedNoWord;            
            }
        }else{
            return FeedActionDescTriedNoWord;
        }
    }
    return FeedActionDescNo;
}


- (void)addListForKey:(NSString *)key
{
    NSMutableArray *list = [NSMutableArray array];
    [_dataMap setObject:list forKey:key];
}


- (NSString *)keyForType:(FeedListType )type
{
    if (type == FeedListTypeMy) {
        return FeedKeyMy;
    }
    if (type == FeedListTypeAll) {
        return FeedKeyAll;
    }
    if (type == FeedListTypeHot) {
        return FeedKeyHot;
    }
    return nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        _dataMap = [[NSMutableDictionary alloc] init];
        [self addListForKey:FeedKeyMy];
        [self addListForKey:FeedKeyAll];
        [self addListForKey:FeedKeyHot];
    }
    return self;
}

- (void)dealloc
{
    PPRelease(_dataMap);
    [super dealloc];
}


- (void)cleanData
{
    [_dataMap removeAllObjects];
}

+ (FeedManager *)defaultManager
{
    if (_staticFeedManager == nil) {
        _staticFeedManager = [[FeedManager alloc] init];
    }
    return _staticFeedManager;
}

- (NSMutableArray *)feedListForType:(FeedListType)type
{
    NSString *key = [self keyForType:type];
    if (key) {
        return [_dataMap objectForKey:key];
    }
    return nil;
}
- (void)setFeedList:(NSMutableArray *)feedList forType:(FeedListType)type
{
    NSString *key = [self keyForType:type];
    if (key) {
        if (feedList) {
            [_dataMap setObject:feedList forKey:key];            
        }else{
            //if the list is nil;
            NSMutableArray *list = [self feedListForType:type];
            [list removeAllObjects];
        }
    }
}
- (void)addFeedList:(NSArray *)feedList forType:(FeedListType)type
{
    if ([feedList count] == 0) {
        return;
    }
    NSMutableArray *list = [self feedListForType:type];
    if (list) {
        [list addObjectsFromArray:feedList];
    }
}

#pragma mark - save and get local data.

#define TEMP_FEED_DRAW_DIR @"feed_data"


+ (NSString *)constructDataPath:(NSString *)feedId
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    if (!paths || [paths count] == 0) {
        NSLog(@"Document directory not found!");
        return nil;
    }
    NSString *dir = [paths objectAtIndex:0];
    
    dir = [dir stringByAppendingPathComponent:TEMP_FEED_DRAW_DIR];
    BOOL flag = [FileUtil createDir:dir];
    if (flag == NO) {
        PPDebug(@"<FeedManager> create dir fail. dir = %@",dir);
    }
    NSString *uniquePath=[dir stringByAppendingPathComponent:feedId];
    NSLog(@"construct path = %@",uniquePath);
    return uniquePath;
}


+ (Draw *)localDrawDataForFeedId:(NSString *)feedId
{
    PPDebug(@"<FeedManager> get data, data file name = %@", feedId);
    if ([feedId length] == 0) {
        return nil;
    }
    NSString *uniquePath = [FeedManager constructDataPath:feedId];
    if (uniquePath == nil) {
        return nil;
    }
    NSData *data = [NSData dataWithContentsOfFile:uniquePath];
    if (data == nil) {
        return nil;
    }
    Draw* draw = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return draw;

}
+ (void)saveDrawData:(Draw *)drawData 
          withFeedId:(NSString *)feedId 
                asyn:(BOOL)asyn
{
    if (drawData == nil || [feedId length] == 0) {
        return;
    }
    void (^handleBlock)()= ^(){
        NSString *uniquePath = [FeedManager constructDataPath:feedId];
        if (uniquePath == nil) {
            return;
        }
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:drawData];    
        BOOL result=[data writeToFile:uniquePath atomically:YES];
        PPDebug(@"<FeedManager> asyn save draw data to path:%@ result:%d , canRead:%d", uniquePath, result, [[NSFileManager defaultManager] fileExistsAtPath:uniquePath]);
    };
    
    if (asyn) {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
        if (queue == NULL){
            return;
        }
        dispatch_async(queue, handleBlock);        
    }else{
        handleBlock();
    }
}

+ (BOOL)isDrawDataExsit:(NSString *)feedId
{
    NSString *uniquePath = [FeedManager constructDataPath:feedId];    
    return [[NSFileManager defaultManager] fileExistsAtPath:uniquePath];
}

@end
