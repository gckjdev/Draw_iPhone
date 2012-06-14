//
//  FeedCell.m
//  Draw
//
//  Created by  on 12-6-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FeedCell.h"
#import "TimeUtils.h"
#import "Feed.h"
#import "Draw.h"
#import "UserManager.h"

@implementation FeedCell
@synthesize guessStatLabel;
@synthesize descLabel;
@synthesize userNameLabel;
@synthesize timeLabel;

+ (NSString*)getCellIdentifier
{
    return @"FeedCell";
}

+ (CGFloat)getCellHeight
{
    return 95.0f;
}

- (void)updateTime:(Feed *)feed
{
    NSString *timeString = dateToString(feed.createDate);
    [self.timeLabel setText:timeString];
}

- (NSString *)userNameForFeed:(Feed *)feed
{
    if ([[UserManager defaultManager] isMe:feed.userId]) {
        return NSLS(@"Me");
    }else{
        return [feed nickName];
    }
}

//get name
- (NSString *)opusCreatorForFeed:(Feed *)feed
{
    NSString *userId = [[feed drawData] userId];
    NSString *nick = [[feed drawData] nickName];
    if ([[UserManager defaultManager] isMe:userId]) {
        return NSLS(@"Me");
    }else{
        return nick;
    }
}


- (void)updateDesc:(Feed *)feed
{
    NSString *desc = nil;
    if (feed.feedType == FeedTypeDraw) {
        desc = [NSString stringWithFormat:NSLS(@"kDrawDesc"),[self userNameForFeed:feed]];
    }else if (feed.feedType == FeedTypeGuess){
        if (feed.isCorrect) {
            desc = [NSString stringWithFormat:NSLS(@"kGuessRightDesc"),[self userNameForFeed:feed], [self opusCreatorForFeed:feed]];                    
        }else{
            desc = [NSString stringWithFormat:NSLS(@"kTryGuessDesc"),[self userNameForFeed:feed], [self opusCreatorForFeed:feed]];                    
        }
    }
    [self.descLabel setText:desc];
}

- (void)updateUser:(Feed *)feed
{
    //avatar
    
    
    //name
    [self.userNameLabel setText:[self userNameForFeed:feed]];
}

- (void)updateGuessDesc:(Feed *)feed
{
    if (feed.matchTimes == 0) {
        [self.guessStatLabel setText:NSLS(@"kNoGuess")];
    }else{
        NSInteger guessTimes = feed.matchTimes;
        NSInteger correctTimes = feed.correctTimes;
        NSString *desc = [NSString stringWithFormat:NSLS(@"kGuessStat"),guessTimes, correctTimes];
        [self.guessStatLabel setText:desc];        
    }
}


- (void)setCellInfo:(Feed *)feed
{
    [self updateDesc:feed];
    [self updateTime:feed];
    [self updateUser:feed];
}

- (void)dealloc {
    [timeLabel release];
    [descLabel release];
    [userNameLabel release];
    [guessStatLabel release];
    [super dealloc];
}
@end
