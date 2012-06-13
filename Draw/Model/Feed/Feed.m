//
//  Feed.m
//  Draw
//
//  Created by  on 12-6-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Feed.h"
#import "GameMessage.pb.h"
#import "GameBasic.pb.h"
#import "TimeUtils.h"
#import "Draw.h"
#import "PPDebug.h"

@implementation Feed

@synthesize feedId = _feedId;
@synthesize userId = _userId;
@synthesize feedType = _feedType;
@synthesize createDate = _createDate;

// for user info
@synthesize nickName = _nickName;
@synthesize avatar = _avatar;
@synthesize gender = _gender;


// for user draw
@synthesize drawData = _drawData;

// for user guess
@synthesize opusId = _opusId;          // 猜作品的ID
@synthesize correct = _correct;
@synthesize score = _score;
@synthesize guessWords = _guessWords;  

// for user comment
@synthesize comment = _comment;

// common data
@synthesize matchTimes = _matchTimes;

- (void)dealloc
{
    PPRelease(_feedId);
    PPRelease(_userId);
    PPRelease(_createDate);
    PPRelease(_avatar);
    PPRelease(_nickName);
    PPRelease(_drawData);
    PPRelease(_opusId);
    PPRelease(_guessWords);
    PPRelease(_comment);
    [super dealloc];
}


- (id)initWithPBFeed:(PBFeed *)pbFeed
{
    self = [super init];
    if(self){
        self.feedId = [pbFeed feedId];
        self.userId = [pbFeed userId];
        self.feedType = [pbFeed actionType];
        self.createDate = [NSDate dateWithTimeIntervalSince1970:pbFeed.createDate];
        
        self.nickName = [pbFeed nickName];
        self.avatar = [pbFeed avatar];
        self.gender = [pbFeed gender];
        
        self.opusId = [pbFeed opusId];
        
        if ([pbFeed hasDrawData]) {
            self.drawData = [[[Draw alloc] initWithPBDraw:
                              [pbFeed drawData]] autorelease];
        }
        if (self.feedType == FeedTypeGuess) {
            self.correct = [pbFeed isCorrect];
            self.score = [pbFeed score];
            self.guessWords = [pbFeed guessWordsList];
        }else if(self.feedType == FeedTypeComment){
            self.comment = [pbFeed comment];
        }
    }
    return self;
}


@end
