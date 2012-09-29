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
                self.commentInfo = [[CommentInfo alloc] initWithPBCommentInfo:
                                    pbFeed.commentInfo];                
            }
            self.comment = pbFeed.comment;
            break;
        case FeedTypeFlower:
            self.comment = NSLS(@"kSendAFlower");            
            if ([pbFeed hasCommentInfo]) {
                self.commentInfo = [[CommentInfo alloc] initWithPBCommentInfo:
                                    pbFeed.commentInfo];                
            }
            break;
        case FeedTypeTomato:
            self.comment = NSLS(@"kThrowATomato");
            if ([pbFeed hasCommentInfo]) {
                self.commentInfo = [[CommentInfo alloc] initWithPBCommentInfo:
                                    pbFeed.commentInfo];                
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
                desc = [NSString stringWithFormat:NSLS(@"kSummaryOfDraw"),nick, self.summary];                
            }else{
                desc = [NSString stringWithFormat:NSLS(@"kSummaryOfDrawNoWord")];
            }
        }
            return desc;

            //回复XX的猜画
        case FeedTypeGuess:
            desc = [NSString stringWithFormat:NSLS(@"kSummaryOfGuess"),nick];
            return desc;
            
            //回复XX的表态:XX
        case FeedTypeTomato:
            desc = [NSString stringWithFormat:NSLS(@"kSummaryOfSendItem"),nick, NSLS(@"kThrowATomato")];
            return desc;
            
        case FeedTypeFlower:
            desc = [NSString stringWithFormat:NSLS(@"kSummaryOfSendItem"),nick,NSLS(@"kSendAFlower")];
            return desc;
            
            //回复XX的评论:XX
        case FeedTypeComment:
            desc = [NSString stringWithFormat:NSLS(@"kSummaryOfComment"),nick,self.summary];
            return desc;
            
        default:
            break;
    }
    return self.summary;
}
@end