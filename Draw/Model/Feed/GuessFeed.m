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
                          signature:pbFeed.signature
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


#define KEY_GUESS_WORD @"GUESS_WORD"
#define KEY_DRAW_FEED @"DRAW_FEED"
#define KEY_CORRECT @"CORRECT"
#define KEY_SCORE @"SCORE"


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.drawFeed = [aDecoder decodeObjectForKey:KEY_DRAW_FEED];
        self.guessWords = [aDecoder decodeObjectForKey:KEY_GUESS_WORD];
        _correct = [aDecoder decodeIntegerForKey:KEY_CORRECT];
        _score = [aDecoder decodeIntegerForKey:KEY_SCORE];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_drawFeed forKey:KEY_DRAW_FEED];
    [aCoder encodeObject:_guessWords forKey:KEY_GUESS_WORD];
    [aCoder encodeInteger:_correct forKey:KEY_CORRECT];
    [aCoder encodeInteger:_score forKey:KEY_SCORE];
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

- (NSInteger)commentTimes
{
    return _drawFeed.commentTimes;
}

- (NSInteger)matchTimes
{
    return _drawFeed.matchTimes;
}
- (NSInteger)saveTimes
{
    return _drawFeed.saveTimes;
}
- (NSInteger)flowerTimes
{
    return _drawFeed.flowerTimes;
}
- (NSInteger)tomatoTimes
{
    return _drawFeed.tomatoTimes;
}

- (FeedUser *)author
{
    return self.drawFeed.author;
}

- (BOOL)showAnswer
{
    if([self.drawFeed showAnswer]){
        return YES;
    }
    if ([self isMyFeed] && [self correct]){
        return YES;
    }
    return NO;
}


@end
