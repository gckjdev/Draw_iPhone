//
//  CommentCell.m
//  Draw
//
//  Created by  on 12-6-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MyCommentCell.h"
#import "TimeUtils.h"
#import "LocaleUtils.h"
#import "DeviceDetection.h"
#import "LocaleUtils.h"
#import "WordManager.h"
//#import "DrawUserInfoView.h"
#import "UserDetailViewController.h"
#import "ViewUserDetail.h"
#import "ShareImageManager.h"
#import "CommentFeed.h"
#import "MyFriend.h"

@implementation MyCommentCell
@synthesize sourceButton;
@synthesize commentLabel;
@synthesize timeLabel;
@synthesize nickNameLabel;
@synthesize itemImage;
//@synthesize splitLine;
@synthesize feed = _feed;
@synthesize superViewController = _superViewController;

+ (id)createCell:(id)delegate
{
    NSString* cellId = [self getCellIdentifier];
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    
    MyCommentCell *cell = ((MyCommentCell*)[topLevelObjects objectAtIndex:0]);
    cell.delegate = delegate;
    
    [cell.sourceButton.titleLabel setNumberOfLines:3];
    [cell.sourceButton.titleLabel setLineBreakMode:UILineBreakModeCharacterWrap];
//    [cell.sourceButton.titleLabel sets
    
    return cell;
}

+ (NSString*)getCellIdentifier
{
    return @"MyCommentCell";
}


#define COMMENT_WIDTH ([DeviceDetection isIPAD] ? 590: 260)
#define REPLY_WIDTH ([DeviceDetection isIPAD] ? 563: 244)
#define COMMENT_FONT_SIZE ([DeviceDetection isIPAD] ? 12*2 : 12)
#define REPLY_FONT_SIZE ([DeviceDetection isIPAD] ? 11*2 : 11)

#define COMMENT_SPACE ([DeviceDetection isIPAD] ? 10 : 5)
#define COMMENT_BASE_X ([DeviceDetection isIPAD] ? 110 : 44)
#define COMMENT_BASE_Y ([DeviceDetection isIPAD] ? 65 : 30)

#define COMMENT_ITEM_HEIGHT ([DeviceDetection isIPAD] ? 110 : 60)

#define AVATAR_VIEW_FRAME [DeviceDetection isIPAD] ? CGRectMake(12, 10, 74, 77) : CGRectMake(5, 9, 31, 32)

#define COMMENT_PAN ([DeviceDetection isIPAD] ? 10 : 6)
#define REPLY_PAN ([DeviceDetection isIPAD] ? 42 : 22)



+ (CGRect)getCommentRect:(CommentFeed *)feed startY:(CGFloat)startY
{
    NSString *comment = [feed commentInMyComment];
    UIFont *font = [UIFont systemFontOfSize:COMMENT_FONT_SIZE];
    CGSize commentSize = [comment sizeWithFont:font constrainedToSize:CGSizeMake(COMMENT_WIDTH, 10000000) lineBreakMode:UILineBreakModeCharacterWrap];
    
    return CGRectMake(COMMENT_BASE_X, startY, COMMENT_WIDTH, commentSize.height + COMMENT_PAN);

}

+ (CGRect)getReplyRect:(CommentFeed *)feed startY:(CGFloat)startY
{
    NSString *reply = [feed replySummary];
    UIFont *font = [UIFont systemFontOfSize:REPLY_FONT_SIZE];
    CGSize commentSize = [reply sizeWithFont:font constrainedToSize:CGSizeMake(REPLY_WIDTH, 10000000) lineBreakMode:UILineBreakModeCharacterWrap];
    return CGRectMake(COMMENT_BASE_X, startY, COMMENT_WIDTH, commentSize.height + REPLY_PAN);    
}

+ (CGFloat)getCellHeight:(CommentFeed *)feed
{
    CGRect commentRect = [MyCommentCell getCommentRect:feed startY:COMMENT_BASE_Y];
    CGRect replyRect = [MyCommentCell getReplyRect:feed startY:CGRectGetMaxY(commentRect)];
    return CGRectGetMaxY(replyRect) + COMMENT_SPACE;
}

#define SHOW_COMMENT_COUNT 3

- (void)setCellInfo:(CommentFeed *)feed;
{
    //set avatar
    self.feed = feed;
    
    FeedUser *author = feed.author;
    [_avatarView removeFromSuperview];
    _avatarView = [[AvatarView alloc] initWithUrlString:author.avatar 
                                                  frame:AVATAR_VIEW_FRAME 
                                                 gender:author.gender 
                                                  level:0];
    _avatarView.delegate = self;
    _avatarView.userId = feed.author.userId;
    [self addSubview:_avatarView];
    [_avatarView release];
    
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
    
     NSString *comment = [feed commentInMyComment];
    //set user name
    [self.nickNameLabel setText:author.nickName];
    
    itemImage.hidden = YES;
    commentLabel.hidden = NO;
    if (feed.feedType == ItemTypeFlower) {
        itemImage.hidden = NO;
        [itemImage setImage:[[ShareImageManager defaultManager] flower]];
        
    }else if(feed.feedType == ItemTypeTomato)
    {
        itemImage.hidden = NO;
        [itemImage setImage:[[ShareImageManager defaultManager] tomato]];
    }
        
    //set comment
    
    [self.commentLabel setText:[NSString stringWithFormat:@"%@", comment]];
    self.commentLabel.frame = [MyCommentCell getCommentRect:feed startY:COMMENT_BASE_Y];
    self.sourceButton.frame = [MyCommentCell getReplyRect:feed startY:CGRectGetMaxY(self.commentLabel.frame)];
    
//    splitLine.center = CGPointMake(splitLine.center.x, CGRectGetMaxY(sourceButton.frame) + COMMENT_SPACE);
    
    [self.sourceButton setBackgroundImage:[[ShareImageManager defaultManager] commentSourceBG] forState:UIControlStateNormal];
    
    [self.sourceButton setTitle:feed.replySummary forState:UIControlStateNormal];        
}



- (void)dealloc {
    PPRelease(commentLabel);
    PPRelease(timeLabel);
    PPRelease(nickNameLabel);
    PPRelease(itemImage);
    PPRelease(sourceButton);
    PPRelease(_superViewController);
    [super dealloc];
}

#pragma mark - avatar view delegate
- (void)didClickOnAvatar:(NSString *)userId
{
//    MyFriend *friend = [MyFriend friendWithFid:userId
//                                      nickName:nil
//                                        avatar:nil
//                                        gender:nil
//                                         level:1];
//    [DrawUserInfoView showFriend:friend infoInView:_superViewController needUpdate:YES];
    
//    UserDetailViewController* uc = [[[UserDetailViewController alloc] initWithUserDetail:[ViewUserDetail viewUserDetailWithUserId:userId avatar:nil nickName:nil]] autorelease];
//    [_superViewController.navigationController pushViewController:uc animated:YES];
//    return;
    
    [UserDetailViewController presentUserDetail:[ViewUserDetail viewUserDetailWithUserId:userId avatar:nil nickName:nil] inViewController:self];
}
@end
