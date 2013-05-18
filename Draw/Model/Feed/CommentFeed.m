//
//  CommentFeed.m
//  Draw
//
//  Created by  on 12-8-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommentFeed.h"
#import "ItemType.h"
#import "WordManager.h"

@implementation CommentFeed
@synthesize comment = _comment;
@synthesize commentInfo = _commentInfo;
@synthesize opusId = _opusId;
@synthesize opusCreator = _opusCreator;

//the feed type can be guess,flower,tomato and comment



#define SHOW_COMMENT_COUNT 3

#define FEED_KEY_COMMENT @"ACTION_ID"
#define KEY_COMMENT_INFO @"COMMENT_INFO"
#define KEY_OPUS_ID @"OPUS_ID"
#define KEY_OPUS_CREATOR @"ACTION_UID"

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [self encodeWithCoder:aCoder];
    [aCoder encodeObject:_comment forKey:FEED_KEY_COMMENT];
    [aCoder encodeObject:_commentInfo forKey:KEY_COMMENT_INFO];
    [aCoder encodeObject:self.opusId forKey:KEY_OPUS_ID];
    [aCoder encodeObject:self.opusCreator forKey:KEY_OPUS_CREATOR];
    
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self initWithCoder:aDecoder];
    if (self) {
        self.comment = [aDecoder decodeObjectForKey:FEED_KEY_COMMENT];
        self.commentInfo = [aDecoder decodeObjectForKey:KEY_COMMENT_INFO];
        self.opusId = [aDecoder decodeObjectForKey:KEY_OPUS_ID];
        self.opusCreator = [aDecoder decodeObjectForKey:KEY_OPUS_CREATOR];
    }
    return self;
}

- (NSString *)commentInFeedDeatil
{
    if (self.feedType == FeedTypeComment && self.commentInfo) {
        FeedType type = self.commentInfo.type;
        if (type == FeedTypeComment || type == FeedTypeFlower || type == FeedTimesTypeTomato || type ==FeedTypeGuess) {
            NSString *cmt = [NSString stringWithFormat:NSLS(@"kReplyCommentDesc"),self.commentInfo.actionNick,self.comment];
//            self.comment = cmt;
            return cmt;
        }
    }
    return self.comment;
}
- (NSString *)commentInMyComment
{
    if (self.feedType == FeedTypeFlower) {
        return  NSLS(@"kSendMeFlower");
    }else if(self.feedType == FeedTypeTomato){
        return  NSLS(@"kThrowMeTomato");
    }
    
    return [self commentInFeedDeatil];
}

- (NSString *)replySummary
{
    NSString *desc = self.commentInfo.summaryDesc;
    if (desc == nil) {
        desc = NSLS(@"kCommentMyOpus");
    }
    return desc;
}

- (BOOL)canDelete
{
    
    //we don't know the opus creator, so return no this version.
    return NO;
}



- (void)initComment:(PBFeed *)pbFeed
{
    self.opusId = pbFeed.opusId;
    self.opusCreator = pbFeed.opusCreatorUserId;
    
    switch (self.feedType) {
        case FeedTypeComment:
            if ([pbFeed hasCommentInfo]) {
                self.commentInfo = [[[CommentInfo alloc] initWithPBCommentInfo:
                                    pbFeed.commentInfo] autorelease];
            }
            self.comment = pbFeed.comment;
            break;
        case FeedTypeFlower:
            self.comment = NSLS(@"kSendAFlower");            
            if ([pbFeed hasCommentInfo]) {
                self.commentInfo = [[[CommentInfo alloc] initWithPBCommentInfo:
                                    pbFeed.commentInfo] autorelease];
            }
            break;
        case FeedTypeTomato:
            self.comment = NSLS(@"kThrowATomato");
            if ([pbFeed hasCommentInfo]) {
                self.commentInfo = [[[CommentInfo alloc] initWithPBCommentInfo:
                                    pbFeed.commentInfo] autorelease];
            }

            break;
            
        case FeedTypeGuess:
            if (pbFeed.isCorrect) {
                self.comment = NSLS(@"kCorrect");            
            }else{
                NSString *guessWords = nil;
                NSInteger wordCount = [pbFeed.guessWordsList count];
                if (wordCount != 0) {
                    NSArray *wordList = nil;
                    if (wordCount > SHOW_COMMENT_COUNT) {
                        wordList = [pbFeed.guessWordsList objectsAtIndexes:
                                    [NSIndexSet indexSetWithIndexesInRange:
                                     NSMakeRange(0, SHOW_COMMENT_COUNT)]];
                    }else{
                        wordList = pbFeed.guessWordsList;
                    }
                    if ([LocaleUtils isChinese]) {
                        guessWords = [wordList componentsJoinedByString:@"、"];    
                    }else{
                        guessWords = [wordList componentsJoinedByString:@", "];
                    }
                    if ([LocaleUtils isTraditionalChinese]) {
                        guessWords = [WordManager changeToTraditionalChinese:guessWords];
                    }
                    if (wordCount > SHOW_COMMENT_COUNT) {
                        guessWords = [NSString stringWithFormat:@"%@%@",guessWords,@"..."];
                    }
                    guessWords = [NSString stringWithFormat:NSLS(@"kGuessWords"),guessWords];
                }
                
                if (guessWords) {
                    self.comment = [NSString stringWithFormat:@"%@",guessWords];
                }else{
                    self.comment = NSLS(@"kGuessWrong");                
                }
            }
            break;
        default:
            break;
    }
}
- (id)initWithPBFeed:(PBFeed *)pbFeed
{
    self = [super initWithPBFeed:pbFeed];
    if (self) {
        [self initComment:pbFeed];
    }
    return self;
}

- (void)dealloc
{
    PPRelease(_opusCreator);
    PPRelease(_opusId);
    PPRelease(_comment);
    PPRelease(_commentInfo);
    [super dealloc];
}
@end


@implementation CommentInfo
@synthesize actionId = _actionId;
@synthesize type = _type;
@synthesize comment = _comment;
@synthesize summary = _summary;
@synthesize actionUid = _actionUid;
@synthesize actionNick = _actionNick;

- (void)dealloc
{
    PPRelease(_actionNick);
    PPRelease(_actionId);
    PPRelease(_actionUid);
    PPRelease(_comment);
    PPRelease(_summary);
    [super dealloc];
}

#define KEY_ACTION_ID @"ACTION_ID"
#define KEY_COMMENT @"COMMENT"
#define KEY_SUMMAY @"SUMMARY"
#define KEY_ACTION_UID @"ACTION_UID"
#define KEY_ACTION_NICK @"ACTION_NICK"
#define KEY_TYPE @"TYPE"

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_actionId forKey:KEY_ACTION_ID];
    [aCoder encodeObject:_comment forKey:KEY_COMMENT];
    [aCoder encodeObject:_summary forKey:KEY_SUMMAY];
    [aCoder encodeObject:_actionUid forKey:KEY_ACTION_UID];
    [aCoder encodeObject:_actionNick forKey:KEY_ACTION_NICK];
    [aCoder encodeInteger:_type forKey:KEY_TYPE];

}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [self init];
    if (self) {
        self.actionId = [aDecoder decodeObjectForKey:KEY_ACTION_ID];
        self.comment = [aDecoder decodeObjectForKey:KEY_COMMENT];
        self.actionUid = [aDecoder decodeObjectForKey:KEY_ACTION_UID];
        self.summary = [aDecoder decodeObjectForKey:KEY_SUMMAY];
        self.actionNick = [aDecoder decodeObjectForKey:KEY_ACTION_NICK];
        self.type = [aDecoder decodeIntegerForKey:KEY_TYPE];
    }
    return self;
}


- (id)initWithPBCommentInfo:(PBCommentInfo *)pbInfo
{
    self = [super init];
    if (self) {
        self.actionId = [pbInfo actionId];
        self.actionUid = [pbInfo actionUserId];
        self.actionNick = [pbInfo actionNickName];
        self.type = [pbInfo type];
        self.comment = [pbInfo comment];
        self.summary = [pbInfo actionSummary];
    }
    return self;
}
- (NSString *)summaryDesc
{
    NSString *desc = nil;
    BOOL isMe = [[UserManager defaultManager] isMe:self.actionUid];
    NSString *nick = isMe ? NSLS(@"kMe") : self.actionNick;
    
    switch (self.type) {
            //评论XX画的XX
        case FeedTypeDraw:
        case FeedTypeDrawToUser:
        {   
            if (isMe || [[UserManager defaultManager] hasGuessOpus:self.actionId]) {
                if (!isMe) {
                    desc = [NSString stringWithFormat:NSLS(@"kSummaryOfDraw"),nick, self.summary];
                } else {
                    desc = [NSString stringWithFormat:NSLS(@"kSummaryOfDraw_Me"), self.summary];
                }
            
            }else{
                desc = [NSString stringWithFormat:NSLS(@"kSummaryOfDrawNoWord"),nick];
            }
        }
            return desc;

            //回复XX的猜画
        case FeedTypeGuess:
            if (isMe) {
                desc = [NSString stringWithFormat:NSLS(@"kSummaryOfGuess_Me")];
            } else {
                desc = [NSString stringWithFormat:NSLS(@"kSummaryOfGuess"),nick];
            }
            
            return desc;
            
            //回复XX的表态:XX
        case FeedTypeTomato:
            if (isMe) {
                desc = [NSString stringWithFormat:NSLS(@"kSummaryOfSendItem_Me"), NSLS(@"kThrowATomato")];
            } else {
                desc = [NSString stringWithFormat:NSLS(@"kSummaryOfSendItem"),nick, NSLS(@"kThrowATomato")];
            }
            
            return desc;
            
        case FeedTypeFlower:
            if (isMe) {
                desc = [NSString stringWithFormat:NSLS(@"kSummaryOfSendItem_Me"), NSLS(@"kSendAFlower")];
            } else {
                desc = [NSString stringWithFormat:NSLS(@"kSummaryOfSendItem"),nick,NSLS(@"kSendAFlower")];
            }
            
            return desc;
            
            //回复XX的评论:XX
        case FeedTypeComment:
            if (isMe) {
                desc = [NSString stringWithFormat:NSLS(@"kSummaryOfComment_Me"), self.summary];
            } else
            {
                desc = [NSString stringWithFormat:NSLS(@"kSummaryOfComment"),nick,self.summary];
            }
            
            return desc;
            
        default:
            break;
    }
    return self.summary;
}
@end