//
//  Feed.h
//  Draw
//
//  Created by  on 12-6-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FeedClasses.h"
#import "PPDebug.h"
#import "GameMessage.pb.h"
#import "GameBasic.pb.h"
#import "LocaleUtils.h"
#import "ItemType.h"

typedef enum{
    
	FeedTypeUnknow = 0,
	FeedTypeDraw = 1,
	FeedTypeGuess = 2,
	FeedTypeComment = 3, 
	FeedTypeRepost = 4,
    FeedTypeDrawToUser = 5,
    
	FeedTypeFlower = ItemTypeFlower,
	FeedTypeTomato = ItemTypeTomato,
    FeedTypeOnlyComment = 8,
    FeedTypeDrawToContest = 9
    
    
}FeedType;



typedef enum {
    OPusStatusNormal = 0, 
    OPusStatusDelete = 1 
}OpusStatus;



@class Draw;
@class PBFeed;
@class PBDraw;

@interface Feed : NSObject
{
    
    NSString *_feedId;    
    FeedType _feedType;    
    NSDate *_createDate;
    FeedUser *_feedUser;
    OpusStatus _opusStatus;
    NSString *_desc;
}

@property (nonatomic, retain) NSString *feedId;
@property (nonatomic, retain) NSString *desc;
@property (nonatomic, assign) FeedType feedType;
@property (nonatomic, assign) OpusStatus opusStatus;
@property (nonatomic, retain) NSDate *createDate;
@property (nonatomic, retain) FeedUser *feedUser;

- (id)initWithPBFeed:(PBFeed *)pbFeed;

- (id)initWithFeedId:(NSString *)feedId 
            feedType:(FeedType)feedType 
          opusStatus:(OpusStatus)status 
          createData:(NSDate *)createDate 
            feedUser:(FeedUser*)feedUser;

- (BOOL)showAnswer;
- (BOOL)isMyFeed;
- (BOOL)isDrawType;
- (BOOL)isGuessType;
- (BOOL)isCommentType; 
//- (void)parseDrawData;

//should override
- (void)updateDesc;
- (FeedUser *)author;
@end
