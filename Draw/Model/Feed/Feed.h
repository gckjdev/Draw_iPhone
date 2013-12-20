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
#import "Opus.pb.h"

typedef enum{
    
	FeedTypeUnknow = 0,
	FeedTypeDraw = PBOpusTypeDraw,
	FeedTypeGuess = PBOpusTypeGuess,
	FeedTypeComment = PBOpusTypeComment,
	FeedTypeRepost = PBOpusTypeRepost,
    FeedTypeDrawToUser = PBOpusTypeDrawToUser,
    
	FeedTypeFlower = ItemTypeFlower,
	FeedTypeTomato = ItemTypeTomato,
    FeedTypeOnlyComment = PBOpusTypeComment,
    FeedTypeDrawToContest = PBOpusTypeDrawContest,
    
    FeedTypeContestComment = 105,
    FeedTypeSing = PBOpusTypeSing,
    FeedTypeSingToUser = PBOpusTypeSingToUser,
    FeedTypeSingContest = PBOpusTypeSingContest,

}FeedType;

typedef enum{
    CommentTypeNO = 0,
    CommentTypeGuess = 2,
    CommentTypeComment = 3,
    CommentTypeFlower = 6,
    CommentTypeTomato = 7,
    CommentTypeSave = 8,
    CommentTypeContestComment = 105,
    
    CommentTypePlay = 200
    
} CommentType;

typedef enum {
    OPusStatusNormal = 0, 
    OPusStatusDelete = 1 
} OpusStatus;


#define IS_OPUS_ACTION(type)          (type == FeedTypeComment || \
                                        type == FeedTypeContestComment || \
                                        type == FeedTypeFlower || \
                                        type == FeedTimesTypeTomato || \
                                        type ==FeedTypeGuess)

#define IS_OPUS_COMMENT_ACTION(type)  (type == FeedTypeComment || type == FeedTypeContestComment)


@class Draw;
@class PBFeed;
@class PBDraw;

@interface Feed : NSObject<NSCoding>
{
    
    NSString *_feedId;
    FeedType _feedType;
    NSDate *_createDate;
    FeedUser *_feedUser;
    OpusStatus _opusStatus;
    NSString *_desc;
}

@property (nonatomic, copy) NSString *feedId;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, assign) FeedType feedType;
@property (nonatomic, assign) OpusStatus opusStatus;
@property (nonatomic, retain) NSDate *createDate;
@property (nonatomic, retain) FeedUser *feedUser;
@property (nonatomic, retain) PBFeed *pbFeed;
@property (assign, nonatomic) PBOpusCategoryType categoryType;

- (id)initWithPBFeed:(PBFeed *)pbFeed;

- (id)initWithFeedId:(NSString *)feedId 
            feedType:(FeedType)feedType 
          opusStatus:(OpusStatus)status 
          createData:(NSDate *)createDate 
            feedUser:(FeedUser*)feedUser;

- (BOOL)showAnswer;
- (BOOL)isMyFeed;
- (BOOL)isOpusType;
- (BOOL)isGuessType;
- (BOOL)isCommentType;

- (BOOL)isDrawCategory;
- (BOOL)isSingCategory;

//- (void)parseDrawData;

//should override
- (void)updateDesc;
- (FeedUser *)author;
- (NSString*)displayText;

@end



