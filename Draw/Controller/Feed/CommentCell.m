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

@implementation CommentCell
@synthesize nickNameLabel;
@synthesize commentLabel;
@synthesize timeLabel;


+ (id)createCell:(id)delegate
{
    NSString* cellId = [self getCellIdentifier];
    //    NSLog(@"cellId = %@", cellId);
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).  
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create %@ but cannot find cell object from Nib", cellId);
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
#define COMMENT_SPACE 50


#define AVATAR_VIEW_FRAME CGRectMake(4, 4, 31, 32)
+ (CGFloat)getCellHeight:(NSString *)comment
{
//    CGSize size = [comment sizeWithFont:[UIFont systemFontOfSize:COMMENT_FONT_SIZE] forWidth:COMMENT_WIDTH lineBreakMode:UILineBreakModeWordWrap];
    CGSize size = [comment sizeWithFont:[UIFont systemFontOfSize:COMMENT_FONT_SIZE] constrainedToSize:CGSizeMake(COMMENT_WIDTH, 1000000) lineBreakMode:UILineBreakModeWordWrap];
    int height = COMMENT_SPACE + size.height;
    NSLog(@"comment: = %@, height = %d",comment,height);
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
    CGSize commentSize = [feed.comment sizeWithFont:[UIFont systemFontOfSize:COMMENT_FONT_SIZE] constrainedToSize:CGSizeMake(COMMENT_WIDTH, 1000000) lineBreakMode:UILineBreakModeWordWrap];

    CGPoint origin = self.commentLabel.frame.origin;
    CGSize size = self.commentLabel.frame.size;
    self.commentLabel.frame = CGRectMake(origin.x, origin.y, size.width, size.height + commentSize.height);
    [self.commentLabel setText:feed.comment];
    
    
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
