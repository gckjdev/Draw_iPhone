//
//  CommentCell.m
//  Draw
//
//  Created by  on 12-6-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommentCell.h"
#import "StableView.h"
#import "FeedManager.h"
#import "TimeUtils.h"
#import "LocaleUtils.h"
#import "DeviceDetection.h"
#import "LocaleUtils.h"
#import "WordManager.h"

@implementation CommentCell
@synthesize commentLabel;
@synthesize timeLabel;
@synthesize nickNameLabel;


+ (id)createCell:(id)delegate
{
    NSString* cellId = [self getCellIdentifier];
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    
    ((PPTableViewCell*)[topLevelObjects objectAtIndex:0]).delegate = delegate;
    
    return [topLevelObjects objectAtIndex:0];
}

+ (NSString*)getCellIdentifier
{
    return @"CommentCell";
}


#define COMMENT_WIDTH ([DeviceDetection isIPAD] ? 550 : 209)
#define COMMENT_FONT_SIZE ([DeviceDetection isIPAD] ? 11*2 : 11)
#define COMMENT_SPACE ([DeviceDetection isIPAD] ? 20 : 10)
#define COMMENT_BASE_X ([DeviceDetection isIPAD] ? 102 : 44)
#define COMMENT_BASE_Y ([DeviceDetection isIPAD] ? 64 : 30)


#define AVATAR_VIEW_FRAME [DeviceDetection isIPAD] ? CGRectMake(11, 14, 71, 74) : CGRectMake(5, 9, 31, 32)



+ (CGFloat)getCellHeight:(Feed *)feed
{
    NSString *comment = feed.comment;
    if (feed.feedType ==  FeedTypeGuess) {
        comment = NSLS(@"kCorrect");
    }else{
        comment = [comment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    UIFont *font = [UIFont systemFontOfSize:COMMENT_FONT_SIZE];
    CGSize commentSize = [comment sizeWithFont:font constrainedToSize:CGSizeMake(COMMENT_WIDTH, 10000000) lineBreakMode:UILineBreakModeCharacterWrap];
    int height = COMMENT_BASE_Y + COMMENT_SPACE + commentSize.height;
    return height;
}

- (void)setCellInfo:(Feed *)feed
{
    //set avatar
    [_avatarView removeFromSuperview];
    _avatarView = [[AvatarView alloc] initWithUrlString:feed.avatar frame:AVATAR_VIEW_FRAME gender:feed.gender level:0];
    [self addSubview:_avatarView];
    [_avatarView release];

    //set user name
    NSString *userName = [FeedManager userNameForFeed:feed];
    [self.nickNameLabel setText:userName];
    
    //set comment
    NSString *comment = feed.comment;
    if (feed.feedType ==  FeedTypeGuess) {
        if (feed.isCorrect) {
            comment = NSLS(@"kCorrect");            
        }else{
            NSString *guessWords = nil;
            if ([feed.guessWords count] != 0) {
                if ([LocaleUtils isChinese]) {
                    guessWords = [feed.guessWords componentsJoinedByString:@"、"];    
                }else{
                    guessWords = [feed.guessWords componentsJoinedByString:@", "];
                }
                
                if ([LocaleUtils isTraditionalChinese]) {
                    guessWords = [WordManager changeToTraditionalChinese:guessWords];
                }
                guessWords = [NSString stringWithFormat:NSLS(@"kGuessWords"),guessWords];
            }

            if (guessWords) {
                comment = [NSString stringWithFormat:@"%@",guessWords];
            }else{
                comment = NSLS(@"kGuessWrong");                
            }
            //who guess wrong! he guess: [2/2/2]
        }

        //[self.commentLabel setTextColor:[UIColor redColor]];
    }else{
        comment = [comment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [self.commentLabel setTextColor:[UIColor darkGrayColor]];
    }
    UIFont *font = [UIFont systemFontOfSize:COMMENT_FONT_SIZE];
    CGSize commentSize = [comment sizeWithFont:font constrainedToSize:CGSizeMake(COMMENT_WIDTH, 10000000) lineBreakMode:UILineBreakModeCharacterWrap];
    
    self.commentLabel.frame = CGRectMake(COMMENT_BASE_X, COMMENT_BASE_Y, COMMENT_WIDTH,commentSize.height);
        
    [self.commentLabel setText:[NSString stringWithFormat:@"%@", comment]];
    [self.commentLabel setFont:font];
    
    //set times
    NSString *timeString = nil;
    if ([LocaleUtils isChinese]) {
        timeString = chineseBeforeTime(feed.createDate);
    } else {
        timeString = englishBeforeTime(feed.createDate);
    }
    
    if (timeString) {
        [self.timeLabel setText:timeString];
    }else {
        NSString *formate = @"yy-MM-dd HH:mm";
        timeString = dateToStringByFormat(feed.createDate, formate);
        [self.timeLabel setText:timeString];
    }
}



- (void)dealloc {
    [commentLabel release];
    [timeLabel release];
    [nickNameLabel release];
    [super dealloc];
}
@end
