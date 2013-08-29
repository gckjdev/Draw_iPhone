//
//  CommentCell.m
//  Draw
//
//  Created by  on 12-6-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommentCell.h"
#import "TimeUtils.h"
#import "LocaleUtils.h"
#import "DeviceDetection.h"
#import "LocaleUtils.h"
#import "WordManager.h"
#import "ShareImageManager.h"
#import "CommentFeed.h"
#import "MyFriend.h"
#import "ContestManager.h"

@implementation CommentCell
@synthesize commentLabel;
@synthesize timeLabel;
@synthesize nickNameLabel;
@synthesize itemImage;
@synthesize splitLine;
@synthesize feed = _feed;
@synthesize replyButton;



#define COMMENT_REPLY_COLOR [UIColor lightGrayColor]

+ (id)createCell:(id)delegate
{
    NSString* cellId = [self getCellIdentifier];
    CommentCell *cell = [CommentCell createViewWithXibIdentifier:cellId];
    cell.delegate = delegate;
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

+ (NSString*)getCellIdentifier
{
    return @"CommentCell";
}


#define NICK_FONT_SIZE ([DeviceDetection isIPAD] ? 11*2 : 12)

#define COMMENT_WIDTH ([DeviceDetection isIPAD] ? 500 : 204)
#define COMMENT_FONT_SIZE ([DeviceDetection isIPAD] ? 23 : 12)
#define COMMENT_CONST_HEIGHT ([DeviceDetection isIPAD] ? 78 : 40)
//#define COMMENT_BASE_X ([DeviceDetection isIPAD] ? 102 : 44)
//#define COMMENT_BASE_Y ([DeviceDetection isIPAD] ? 65 : 30)

#define COMMENT_ITEM_HEIGHT ([DeviceDetection isIPAD] ? 110 : 60)

#define AVATAR_VIEW_FRAME [DeviceDetection isIPAD] ? CGRectMake(12, 10, 74, 77) : CGRectMake(5, 9, 31, 32)


- (IBAction)clickReplyButton:(id)sender {
    if (self.delegate && [self.delegate
                          respondsToSelector:@selector(didStartToReplyToFeed:)]) {
        [self.delegate didStartToReplyToFeed:self.feed];
    }
}

+ (CGFloat)getCellHeight:(CommentFeed *)feed
{
    if (feed.feedType == ItemTypeFlower || feed.feedType == ItemTypeTomato) {
        return COMMENT_ITEM_HEIGHT;
    }
    NSString *comment = [feed commentInFeedDeatil];
    UIFont *font = [UIFont systemFontOfSize:COMMENT_FONT_SIZE];
    PPDebug(@"start to cal height, comment = %@",comment);
    CGSize commentSize = [comment sizeWithFont:font constrainedToSize:CGSizeMake(COMMENT_WIDTH, 10000000) lineBreakMode:UILineBreakModeCharacterWrap];
    CGFloat height = COMMENT_CONST_HEIGHT + commentSize.height;
    PPDebug(@"comment = %@,height = %f", comment,height);
    return height;
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
    

    //set user name
    UIFont *nickFont = [UIFont systemFontOfSize:NICK_FONT_SIZE];
    [self.nickNameLabel setFont:nickFont];
    [self.nickNameLabel setText:author.nickName];
    [self.nickNameLabel setTextColor:[UIColor darkGrayColor]];
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
    NSString *comment = [feed commentInFeedDeatil];
    UIFont *font = [UIFont systemFontOfSize:COMMENT_FONT_SIZE];
    [self.commentLabel setFont:font];
//    [self.commentLabel setTextColor:COMMENT_CONTENT_COLOR];
    [self.commentLabel setLineBreakMode:NSLineBreakByCharWrapping];
    if ([DeviceDetection isOS6] && [feed commentInfo] != nil && [comment length] != 0) {
        NSInteger length = [comment length];
        NSInteger contentLength = [feed.comment length];
        NSInteger loc = length - contentLength;
        if (loc > 0) {
            //set attributed
            PPDebug(@"comment = %@,length = %d,loc = %d",comment,length,loc);
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:comment];

            [attr addAttribute:NSFontAttributeName
                         value:self.commentLabel.font
                         range:NSMakeRange(0, length)];
            
            [attr addAttribute:NSForegroundColorAttributeName value:COMMENT_REPLY_COLOR range:NSMakeRange(0, loc)];
            [self.commentLabel setText:nil];
            [self.commentLabel setAttributedText:attr];
            [attr release];
        }else{
            [self.commentLabel setAttributedText:nil];
            [self.commentLabel setText:comment];
        }
    }else{
        [self.commentLabel setText:comment];
    }
    
    if ([[ContestManager defaultManager] displayContestAnonymousForFeed:feed.drawFeed] &&
        [[UserManager defaultManager] isMe:feed.author.userId]){
        self.replyButton.hidden = YES;
    }
    else{
        self.replyButton.hidden = NO;
    }
    
}



- (void)dealloc {
    PPRelease(commentLabel);
    PPRelease(timeLabel);
    PPRelease(nickNameLabel);
    PPRelease(itemImage);
    PPRelease(splitLine);
    PPRelease(replyButton);
//    PPRelease(_superViewController);
    [super dealloc];
}

#pragma mark - avatar view delegate
- (void)didClickOnAvatar:(NSString *)userId
{
    MyFriend *friend = [MyFriend friendWithFid:userId
                                      nickName:nil
                                        avatar:nil
                                        gender:nil
                                         level:1];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickAvatar:)]) {
        [self.delegate didClickAvatar:friend];
    }
}
@end
