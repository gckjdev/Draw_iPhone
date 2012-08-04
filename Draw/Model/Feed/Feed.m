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
#import "UserManager.h"
#import "FeedManager.h"
#import "ShareImageManager.h"

@implementation Feed

@synthesize pbDraw = _pbDraw;
@synthesize wordText = _wordText;
@synthesize authorId = _authorId;
@synthesize authorNick = _authorNick;

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
@synthesize drawImage = _drawImage;

// for user guess
@synthesize opusId = _opusId;          // 猜作品的ID
@synthesize correct = _correct;
@synthesize score = _score;
@synthesize guessWords = _guessWords;  

// for draw to user guess
@synthesize targetUid = _targetUid;
@synthesize targetNickName = _targetNickName;


// for user comment
@synthesize comment = _comment;

// common data
@synthesize matchTimes = _matchTimes;
@synthesize correctTimes = _correctTimes;
@synthesize commentTimes = _commentTimes;
@synthesize guessTimes = _guessTimes;

@synthesize opusStatus = _opusStatus;
@synthesize isParsing = _isParsing;
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
    PPRelease(_targetUid);
    PPRelease(_targetNickName);
    PPRelease(_drawImage);
    PPRelease(_pbDraw);
    PPRelease(_wordText);
    PPRelease(_authorNick);
    PPRelease(_authorId);
    [super dealloc];
}

- (NSString *)saveKey
{
    if ([self.opusId length] != 0) {
        return self.opusId;
    }
    return self.feedId;
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
        self.matchTimes = [pbFeed matchTimes];
        self.correctTimes = [pbFeed correctTimes];
        self.guessTimes = [pbFeed guessTimes];
        self.commentTimes = [pbFeed commentTimes];
        self.opusId = [pbFeed opusId];
        self.opusStatus = [pbFeed opusStatus];
        self.pbDraw = [pbFeed drawData];
        self.isParsing = NO;
        if ([pbFeed hasDrawData]) {
            self.wordText = [[pbFeed drawData] word];
            self.authorId = [[pbFeed drawData] userId];
            self.authorNick = [[pbFeed drawData] nickName];
        }
        //if has image, show the image, or use the draw data.
        /*
        if ([pbFeed hasDrawData]) {
            self.wordText = [[pbFeed drawData] word];
            self.authorId = [[pbFeed drawData] userId];
            self.authorNick = [[pbFeed drawData] nickName];
            
            self.drawImage = [[ShareImageManager defaultManager] getImageWithName:[self saveKey]];
            if (self.drawImage == nil) {
                self.drawData = [[[Draw alloc] initWithPBDraw:
                                      [pbFeed drawData]] autorelease];       

            }else{
                self.pbDraw = [pbFeed drawData];
            }            
        }
        */
        if (self.feedType == FeedTypeGuess) {
            self.correct = [pbFeed isCorrect];
            self.score = [pbFeed score];
            self.guessWords = [pbFeed guessWordsList];
        }else if(self.feedType == FeedTypeComment){
            self.comment = [pbFeed comment];
        }else if(self.feedType == FeedTypeDrawToUser){
            self.targetUid = [pbFeed targetUserId];
            self.targetNickName = [pbFeed targetUserNickName];
        }
    }
    return self;
}


- (BOOL)isMyOpus
{
    UserManager *defaultManager  = [UserManager defaultManager];
    if ([self isDrawType]) {
        return [defaultManager isMe:self.userId];
    }
    if (self.feedType == FeedTypeGuess) {
        return [defaultManager isMe:self.drawData.userId];
    }
    return NO;
}

- (BOOL) hasGuessed
{
    UserManager *defaultManager  = [UserManager defaultManager];
    if ([self isDrawType]) {
        return [defaultManager hasGuessOpus:self.feedId];
    }
    if (self.feedType == FeedTypeGuess) {
        return [defaultManager hasGuessOpus:self.opusId];
    }
    return NO;

}
- (BOOL) isDrawType
{
    return self.feedType == FeedTypeDraw || self.feedType == FeedTypeDrawToUser;
}

- (NSString *)author
{
    return self.authorId;
}

- (void)parseDrawData
{
    if (self.drawData == nil && self.pbDraw != nil) {
        self.drawData = [[[Draw alloc] initWithPBDraw:self.pbDraw] autorelease];
        self.pbDraw = nil;
    }
}

@end
