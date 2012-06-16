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

@implementation CommentCell
@synthesize nickNameLabel;
@synthesize commentLabel;
@synthesize timeLabel;


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


#define COMMENT_WIDTH 248
#define COMMENT_FONT_SIZE 14
#define COMMENT_SPACE 10
#define COMMENT_BASE_X 44
#define COMMENT_BASE_Y 28


#define AVATAR_VIEW_FRAME CGRectMake(4, 4, 31, 32)



+ (CGFloat)getCellHeight:(Feed *)feed
{
    
    NSString *comment = feed.comment;
    if (feed.feedType ==  FeedTypeGuess) {
        comment = NSLS(@"kCorrect");
    }
    CGSize size = [comment sizeWithFont:[UIFont systemFontOfSize:COMMENT_FONT_SIZE] constrainedToSize:CGSizeMake(COMMENT_WIDTH, 1000000) lineBreakMode:UILineBreakModeWordWrap];
    int height = COMMENT_BASE_Y + COMMENT_SPACE + size.height;
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
        comment = NSLS(@"kCorrect");
        [self.commentLabel setTextColor:[UIColor redColor]];
    }else{
        [self.commentLabel setTextColor:[UIColor darkGrayColor]];
    }
    
    CGSize commentSize = [comment sizeWithFont:[UIFont systemFontOfSize:COMMENT_FONT_SIZE] constrainedToSize:CGSizeMake(COMMENT_WIDTH, 1000000) lineBreakMode:UILineBreakModeWordWrap];

    self.commentLabel.frame = CGRectMake(COMMENT_BASE_X, COMMENT_BASE_Y, COMMENT_WIDTH,commentSize.height);
    [self.commentLabel setText:comment];
    
    
    //set times
    [self.timeLabel setText:dateToString(feed.createDate)];
    
}



- (void)dealloc {
    [nickNameLabel release];
    [commentLabel release];
    [timeLabel release];
    [super dealloc];
}
@end
