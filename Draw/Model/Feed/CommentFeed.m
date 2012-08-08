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


//the feed type can be guess,flower,tomato and comment



#define SHOW_COMMENT_COUNT 3


- (void)initComment:(PBFeed *)pbFeed
{
    switch (self.feedType) {
        case FeedTypeComment:
            self.comment = pbFeed.comment;
            break;
        case FeedTypeFlower:
            self.comment = NSLS(@"kSendAFlower");            
            break;
        case FeedTypeTomato:
            self.comment = NSLS(@"kThrowATomato");
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

- (id)initWithCommentFeedId:(NSString *)feedId 
                 opusStatus:(OpusStatus)status 
                 createData:(NSDate *)createDate 
                   feedUser:(FeedUser*)feedUser
                    comment:(NSString *)comment
{
    self = [super initWithFeedId:feedId 
                        feedType:FeedTypeComment
                      opusStatus:status 
                      createData:createDate 
                        feedUser:feedUser];
    if (self) {
        self.comment = comment;
    }
    return self;
}


//- (id)initWithGuessFeedId:(NSString *)feedId 
//               opusStatus:(OpusStatus)status 
//               createData:(NSDate *)createDate 
//                 feedUser:(FeedUser*)feedUser
//                  correct:(BOOL)correct
//                guessList:(NSArray *)guessList
//{
//    self = [super initWithFeedId:feedId 
//                        feedType:FeedTypeGuess
//                      opusStatus:status 
//                      createData:createDate 
//                        feedUser:feedUser];
//    if (self) {
//        
//    }
//}



- (void)dealloc
{
    PPRelease(_comment);
    [super dealloc];
}
@end
