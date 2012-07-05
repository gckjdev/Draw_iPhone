//
//  Feed.h
//  Draw
//
//  Created by  on 12-6-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum{
    
	FeedTypeUnknow = 0,
	FeedTypeDraw = 1,
	FeedTypeGuess = 2,
	FeedTypeComment = 3, 
	FeedTypeRepost = 4,
    FeedTypeDrawToUser = 5,
    
}FeedType;


typedef enum{
    
    FeedListTypeUnknow = 0,
    FeedListTypeMy = 1,
    FeedListTypeAll = 2,
    FeedListTypeHot = 3,
    FeedListTypeUser = 4,
    FeedListTypeUserOpus = 5,
    
}FeedListType;

typedef enum {
    OPusStatusNormal = 0, 
    OPusStatusDelete = 1 
}OpusStatus;



@class Draw;
@class PBFeed;

@interface Feed : NSObject
{
    NSString *_feedId;
    NSString *_userId;
    FeedType _feedType;
    NSDate *_createDate;
    
    // for user info
    NSString *_nickName;
    NSString *_avatar;
    BOOL _gender;
    
    
    // for user draw
    Draw *_drawData;
    
    // for user guess
    NSString *_opusId;          // 猜作品的ID
    BOOL _correct;
    NSInteger _score;
    NSArray *_guessWords;  
 
    // for draw to user guess
    NSString *_targetUid;
    NSString *_targetNickName;
    
    // for user comment
    NSString *_comment;
    
    // common data
    NSInteger _matchTimes;
    NSInteger _guessTimes;
    NSInteger _commentTimes;
    NSInteger _correctTimes;
    
    UIImage *_drawImage;
}

@property (nonatomic, retain) NSString *feedId;
@property (nonatomic, retain) NSString *userId;
@property (nonatomic, assign) FeedType feedType;
@property (nonatomic, retain) NSDate *createDate;

// for user info
@property (nonatomic, retain) NSString *nickName;
@property (nonatomic, retain) NSString *avatar;
@property (nonatomic, assign) BOOL gender;


// for user draw
@property (nonatomic, retain) Draw *drawData;
@property (nonatomic, retain) UIImage *drawImage;;

// for user guess
@property (nonatomic, retain) NSString *opusId;          // 猜作品的ID
@property (nonatomic, assign, getter = isCorrect) BOOL correct;
@property (nonatomic, assign) NSInteger score;
@property (nonatomic, retain) NSArray *guessWords;  

// for user comment
@property (nonatomic, retain) NSString *comment;

// for draw to user guess
@property (nonatomic, retain) NSString *targetUid;
@property (nonatomic, retain) NSString *targetNickName;


// common data
@property (nonatomic, assign) NSInteger matchTimes;
@property (nonatomic, assign) NSInteger correctTimes;;
@property (nonatomic, assign) NSInteger commentTimes;
@property (nonatomic, assign) NSInteger guessTimes;;

@property (nonatomic, assign) NSInteger opusStatus;

- (id)initWithPBFeed:(PBFeed *)pbFeed;
- (BOOL)isMyOpus;
- (BOOL) hasGuessed;
- (BOOL) isDrawType;
@end
