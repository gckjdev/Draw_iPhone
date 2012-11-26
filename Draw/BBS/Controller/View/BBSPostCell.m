//
//  BBSPostCell.m
//  Draw
//
//  Created by gamy on 12-11-19.
//
//

#import "BBSPostCell.h"
#import "UIImageView+WebCache.h"
#import "BBSManager.h"
#import "UserManager.h"
#import "TimeUtils.h"

#define SPACE_CONTENT_TOP 35
#define SPACE_CONTENT_BOTTOM_IMAGE 100 //IMAGE TYPE OR DRAW TYPE
#define SPACE_CONTENT_BOTTOM_TEXT 40 //TEXT TYPE
#define IMAGE_HEIGHT 80 
#define CONTENT_TEXT_LINE 10

#define CONTENT_WIDTH 240
#define CONTENT_MAX_HEIGHT 200

#define Y_CONTENT_TEXT 5
#define CONTENT_FONT [UIFont systemFontOfSize:15]
@implementation BBSPostCell
@synthesize post = _post;
//@synthesize delegate = _delegate;

+ (id)createCell:(id)delegate
{
    BBSPostCell *cell = [BBSTableViewCell createCellWithIdentifier:[self getCellIdentifier] delegate:delegate];
    
    cell.content.numberOfLines = CONTENT_TEXT_LINE;
    [cell.content setLineBreakMode:NSLineBreakByTruncatingTail];
    cell.content.font = CONTENT_FONT;
    
    return cell;
}

+ (NSString*)getCellIdentifier
{
    return @"BBSPostCell";
}

//+ (NSString *)thumImageUrlForContent:(PBBBSContent *)content
//{
//    if (content.type == ContentTypeImage) {
//       return content.thumbImageUrl;
//    }else if(content.type == ContentTypeDraw){
//       return content.drawThumbUrl;
//    }
//    return nil;
//}


+ (CGFloat)heightForContentText:(NSString *)text
{
    CGSize size = [text sizeWithFont:CONTENT_FONT constrainedToSize:CGSizeMake(CONTENT_WIDTH, CONTENT_MAX_HEIGHT) lineBreakMode:NSLineBreakByCharWrapping];
    size.height += 2*Y_CONTENT_TEXT;
    return size.height;
}

+ (CGFloat)getCellHeightWithBBSPost:(PBBBSPost *)post
{
    PBBBSContent * content = post.content;
    CGFloat height = [BBSPostCell heightForContentText:content.text];
    
    if (post.content.hasThumbImage) {
        height += (SPACE_CONTENT_TOP + SPACE_CONTENT_BOTTOM_IMAGE);
    }else{
        height += (SPACE_CONTENT_TOP + SPACE_CONTENT_BOTTOM_TEXT);
    }
    return height;
}

- (void)updateUserInfo:(PBBBSUser *)user
{
    [self.nickName setText:user.showNick];
    [self.avatar setImageWithURL:user.avatarURL placeholderImage:user.defaultAvatar];
}

- (void)updateContent:(PBBBSContent *)content
{
    
    [BBSManager printBBSContent:content];
    [self.content setText:content.text];
    
    //reset the size
    CGRect frame = self.content.frame;
    frame.size.height = [BBSPostCell heightForContentText:content.text];
    self.content.frame = frame;
  
    if (content.hasThumbImage) {
        [self.image setImageWithURL:content.thumbImageURL placeholderImage:nil];
        self.image.hidden = NO;
    }else{
        self.image.hidden = YES;
    }
}

- (void)updateTimeStamp:(NSInteger)timeInterval
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    [self.timestamp setText:dateToChineseString(date)];
}

- (void)updateSupportCount:(NSInteger)supportCount
              commentCount:(NSInteger)commentCount
{
    [self.support setTitle:[NSString stringWithFormat:@"SP(%d)",supportCount]
                  forState:UIControlStateNormal];
    [self.comment setTitle:[NSString stringWithFormat:@"CM(%d)",commentCount]
                  forState:UIControlStateNormal];

}

- (void)updateReward:(PBBBSReward *)reward
{
    self.reward.hidden = NO;
    if (reward.hasWinner) {
        [self.reward setText:NSLS(@"kWIN")];
    }else if(reward.bonus > 0){
        [self.reward setText:[NSString stringWithFormat:@"$%d",reward.bonus]];
    }else{
        self.reward.hidden = YES;
    }
}

- (void)updateCellWithBBSPost:(PBBBSPost *)post
{
    self.post = post;
    [self updateUserInfo:post.createUser];
    [self updateContent:post.content];
    [self updateTimeStamp:post.createDate];
    [self updateSupportCount:post.supportCount commentCount:post.replyCount];
    [self updateReward:post.reward];
}



- (void)dealloc {
    PPRelease(_support);
    PPRelease(_comment);
    PPRelease(_post);
    PPRelease(_reward);
    [super dealloc];
}
- (IBAction)clickSupportButton:(id)sender {
    if (delegate && [delegate respondsToSelector:
                     @selector(didClickSupportButtonWithPost:)]) {
        [delegate didClickSupportButtonWithPost:self.post];
    }
}

- (IBAction)clickCommentButton:(id)sender {
    if (delegate && [delegate respondsToSelector:
                     @selector(didClickReplyButtonWithPost:)]) {
        [delegate didClickReplyButtonWithPost:self.post];
    }
}
@end
