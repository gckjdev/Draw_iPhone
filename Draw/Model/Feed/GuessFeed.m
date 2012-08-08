//
//  GuessFeed.m
//  Draw
//
//  Created by  on 12-8-6.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GuessFeed.h"
#import "DrawFeed.h"


@implementation GuessFeed
@synthesize guessWords = _guessWords;
@synthesize drawFeed = _drawFeed;
@synthesize score = _score;
@synthesize correct = _correct;

- (void)dealloc
{
    PPRelease(_guessWords);
    PPRelease(_drawFeed);
    [super dealloc];
}


- (void)updateDesc
{
    NSString *nick = self.drawFeed.author.nickName;
    NSString *word = self.drawFeed.wordText;
    
//    PPDebug(@"***nick = %@, word = %@ ***", nick, word);
    if ([self correct]) {
        if ([self.drawFeed isMyOpus]) {
            self.desc = [NSString stringWithFormat:NSLS(@"kGuessRightDesc_MyDraw"), word];      
        }else{
            if (self.isMyFeed || [self.drawFeed hasGuessed]) {                
                self.desc = [NSString stringWithFormat:NSLS(@"kGuessRightDesc"), nick,
                             word];      
            }else{
                self.desc = [NSString stringWithFormat:NSLS(@"kGuessRightDescNoWord"), nick]; 
            }
        }
    }else{
        if ([self.drawFeed isMyOpus]) {
            self.desc = [NSString stringWithFormat:NSLS(@"kTryGuessDesc_MyDraw"), 
                         self.drawFeed.wordText];      
        }else{
            if ([self.drawFeed hasGuessed]) {                
                self.desc = [NSString stringWithFormat:NSLS(@"kTryGuessDesc"), nick,
                             word];      
            }else{
                self.desc = [NSString stringWithFormat:NSLS(@"kTryGuessDescNoWord"), nick]; 
            }
        }
    }

}

- (id)initWithPBFeed:(PBFeed *)pbFeed
{
    self = [super initWithPBFeed:pbFeed];
    if (self) {
        self.correct = pbFeed.isCorrect;
        self.score = pbFeed.score;
        self.guessWords = pbFeed.guessWordsList;
        self.drawFeed = [[[DrawFeed alloc] 
                          initWithFeedId:pbFeed.opusId 
                          userId:pbFeed.opusCreatorUserId 
                          nickName:pbFeed.opusCreatorNickName 
                          avatar:pbFeed.opusCreatorAvatar 
                          gender:pbFeed.opusCreatorGender 
                          drawImageUrl:pbFeed.opusImage 
                          pbDraw:pbFeed.drawData 
                          wordText:pbFeed.opusWord 
                          timesArray:pbFeed.feedTimesList] autorelease];
        
        [self.drawFeed setFeedType:FeedTypeDraw];
        [self.drawFeed setFeedId:pbFeed.opusId];
        [self updateDesc];
    }
    return self;
}

- (NSInteger)guessTimes
{
    PPDebug(@"warnning:<guessTimes> get guess times from guess feed, feedId = %@", self.feedId);
    return _drawFeed.guessTimes;
}
- (NSInteger)correctTimes
{
    PPDebug(@"warnning:<correctTimes> get guess times from guess feed, feedId = %@", self.feedId);
    return _drawFeed.correctTimes;
}

- (FeedUser *)author
{
    return self.drawFeed.author;
}

@end
