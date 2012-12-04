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





#define SPACE_CONTENT_TOP (ISIPAD ? (2.33 * 30) : 30)
#define SPACE_CONTENT_BOTTOM_IMAGE (ISIPAD ? (2.33 * 120) : 120) //IMAGE TYPE OR DRAW TYPE
#define SPACE_CONTENT_BOTTOM_TEXT (ISIPAD ? (2.33 * 40) : 40) //TEXT TYPE
#define IMAGE_HEIGHT (ISIPAD ? (2.33 * 80) : 80)
#define CONTENT_TEXT_LINE (ISIPAD ? (2.33 * 10) : 10)
#define CONTENT_WIDTH (ISIPAD ? (2.33 * 206) : 206)
#define CONTENT_MAX_HEIGHT (ISIPAD ? (2.33 * 200) : 200)
#define Y_CONTENT_TEXT (ISIPAD ? (2.33 * 5) : 5)

#define CONTENT_FONT [[BBSFontManager defaultManager] postContentFont]


@implementation BBSPostCell
@synthesize post = _post;
//@synthesize delegate = _delegate;



+ (void)updateViews:(BBSPostCell *)cell
{
    BBSImageManager *_bbsImageManager = [BBSImageManager defaultManager];
    BBSColorManager *_bbsColorManager = [BBSColorManager defaultManager];
    BBSFontManager *_bbsFontManager = [BBSFontManager defaultManager];

    
    
    //action
    [BBSViewManager updateButton:cell.reward
                         bgColor:[UIColor clearColor]
                         bgImage:nil
                           image:[_bbsImageManager bbsPostRewardImage]
                            font:[_bbsFontManager postRewardFont]
                      titleColor:[_bbsColorManager postRewardColor]
                           title:nil forState:UIControlStateNormal];
    
    [BBSViewManager updateButton:cell.reward
                         bgColor:[UIColor clearColor]
                         bgImage:nil
                           image:[_bbsImageManager bbsPostRewardedImage]
                            font:[_bbsFontManager postRewardFont]
                      titleColor:[_bbsColorManager postRewardedColor]
                           title:nil forState:UIControlStateSelected];

    [BBSViewManager updateButton:cell.comment
                         bgColor:[UIColor clearColor]
                         bgImage:nil
                           image:[_bbsImageManager bbsPostCommentImage]
                            font:[_bbsFontManager postActionFont]
                      titleColor:[_bbsColorManager postActionColor]
                           title:nil forState:UIControlStateNormal];
    
    [BBSViewManager updateButton:cell.support
                         bgColor:[UIColor clearColor]
                         bgImage:nil
                           image:[_bbsImageManager bbsPostSupportImage]
                            font:[_bbsFontManager postActionFont]
                      titleColor:[_bbsColorManager postActionColor]
                           title:nil forState:UIControlStateNormal];
    
}

+ (id)createCell:(id)delegate
{
    BBSPostCell *cell = [BBSTableViewCell createCellWithIdentifier:[self getCellIdentifier] delegate:delegate];
    
    cell.content.numberOfLines = CONTENT_TEXT_LINE;
    cell.content.font = CONTENT_FONT;
    [BBSPostCell updateViews:cell];
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



- (void)updateSupportCount:(NSInteger)supportCount
              commentCount:(NSInteger)commentCount
{
    [self.support setTitle:[NSString stringWithFormat:@"%d",supportCount]
                  forState:UIControlStateNormal];
    [self.comment setTitle:[NSString stringWithFormat:@"%d",commentCount]
                  forState:UIControlStateNormal];

}

- (void)updateReward:(PBBBSPost *)post
{
    PBBBSReward *reward = post.reward;
    if (post.hasReward) {
        if ([post hasPay]) {
            [self.reward setSelected:YES];
            [self.reward setTitle:[NSString stringWithFormat:@"%d",reward.bonus]
                         forState:UIControlStateSelected];
        }else{
            [self.reward setSelected:NO];
            [self.reward setTitle:[NSString stringWithFormat:@"%d",reward.bonus]
                         forState:UIControlStateNormal];
        }
        self.reward.hidden = NO;
    }else{
        [self.reward setHidden:YES];
    }
}

- (void)updateCellWithBBSPost:(PBBBSPost *)post
{
    self.post = post;
    [self updateUserInfo:post.createUser];
    [self updateContent:post.content];
    [self.timestamp setText:post.createDateString];
    [self updateSupportCount:post.supportCount commentCount:post.replyCount];
    [self updateReward:post];
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

#pragma mark - Click avatar && image

- (void)clickAvatarButton:(id)sender
{
    if (delegate && [delegate respondsToSelector:@selector(didClickUserAvatar:)]) {
        [delegate didClickUserAvatar:self.post.createUser];
    }
}
- (void)clickImageButton:(id)sender
{
    //show draw...
    if (self.post.content.type == ContentTypeDraw && delegate
        && [delegate respondsToSelector:@selector(didClickDrawImageWithPost:)]) {
        [delegate didClickDrawImageWithPost:self.post];
    //show image...
    }else if(self.post.content.type == ContentTypeImage && delegate &&
             [delegate respondsToSelector:@selector(didClickImageWithURL:)])
    {
        [delegate didClickImageWithURL:self.post.content.largeImageURL];
    }
}
@end
