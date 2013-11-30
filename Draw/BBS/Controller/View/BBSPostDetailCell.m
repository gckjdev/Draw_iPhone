//
//  BBSPostDetailCell.m
//  Draw
//
//  Created by gamy on 12-11-19.
//
//

#import "BBSPostDetailCell.h"
#import "UIImageView+WebCache.h"
#import "BBSManager.h"
#import "UserManager.h"
#import "TimeUtils.h"





#define SPACE_CONTENT_TOP (ISIPAD ? (2.33 * 30) : 30)
#define SPACE_CONTENT_BOTTOM_IMAGE (ISIPAD ? (2.33 * 120) : 120) //IMAGE TYPE OR DRAW TYPE

#define SPACE_CONTENT_BOTTOM_TEXT (ISIPAD ? (2.33 * 40) : 40) //TEXT TYPE
//#define IMAGE_HEIGHT (ISIPAD ? (2.33 * 80) : 80)
#define CONTENT_TEXT_LINE (INT_MAX)
#define CONTENT_WIDTH (ISIPAD ? (2.33 * 206) : 206)
#define CONTENT_MAX_HEIGHT 99999999
#define Y_CONTENT_TEXT (ISIPAD ? (2.33 * 5) : 5)
#define FLAG_RADIUS (ISIPAD ? 6 : 3)

#define CONTENT_FONT [[BBSFontManager defaultManager] postContentFont]
#define SEEME_FONT (ISIPAD ? 9 * 2: 9)

@implementation BBSPostDetailCell
@synthesize post = _post;
//@synthesize delegate = _delegate;



- (void)updateViews
{
    
    //action
    [BBSViewManager updateButton:self.reward
                         bgColor:[UIColor clearColor]
                         bgImage:nil
                           image:[_bbsImageManager bbsPostRewardImage]
                            font:[_bbsFontManager postRewardFont]
                      titleColor:[_bbsColorManager postRewardColor]
                           title:nil forState:UIControlStateNormal];
    
    [BBSViewManager updateButton:self.reward
                         bgColor:[UIColor clearColor]
                         bgImage:nil
                           image:[_bbsImageManager bbsPostRewardedImage]
                            font:[_bbsFontManager postRewardFont]
                      titleColor:[_bbsColorManager postRewardedColor]
                           title:nil forState:UIControlStateSelected];

    [BBSViewManager updateButton:self.topFlag
                         bgColor:COLOR_ORANGE//[UIColor clearColor]
                         bgImage:nil//[_bbsImageManager bbsPostTopBg]
                           image:nil
                            font:[_bbsFontManager postTopFont]
                      titleColor:[UIColor whiteColor]
                           title:NSLS(@"kTopPost")
                        forState:UIControlStateNormal];

    [BBSViewManager updateButton:self.markedFlag
                         bgColor:COLOR_YELLOW//[UIColor clearColor]
                         bgImage:nil//[_bbsImageManager bbsPostTopBg]
                           image:nil
                            font:[_bbsFontManager postTopFont]
                      titleColor:COLOR_BROWN
                           title:NSLS(@"kMarked")
                        forState:UIControlStateNormal];

    SET_VIEW_ROUND_CORNER_RADIUS(self.topFlag, FLAG_RADIUS);
    SET_VIEW_ROUND_CORNER_RADIUS(self.markedFlag, FLAG_RADIUS);
    
    SET_BUTTON_ROUND_STYLE_ORANGE(self.seeMeOnly);

    UIFont *font = [UIFont systemFontOfSize:SEEME_FONT];
    [self.seeMeOnly.titleLabel setFont:font];
}

- (IBAction)clickSeeMeOnly:(id)sender {
    NSString *uid = [self isSeeingMe] ? nil : _post.createUser.userId;
    if ([self.delegate respondsToSelector:@selector(didClickOnlySeeMe:)]) {
        [self.delegate didClickOnlySeeMe:uid];
    }
}

+ (id)createCell:(id)delegate
{
    BBSPostDetailCell *cell = [BBSTableViewCell createCellWithIdentifier:[self getCellIdentifier] delegate:delegate];
    
    
    cell.content.numberOfLines = CONTENT_TEXT_LINE;
    [cell.content setLineBreakMode:NSLineBreakByCharWrapping];
    cell.content.font = CONTENT_FONT;
    [cell updateViews];
    cell.delegate = delegate;
    [cell setUseContentLabel:NO];
    return cell;
}

+ (NSString*)getCellIdentifier
{
    return @"BBSPostDetailCell";
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




+ (CGFloat)heightForContentText:(NSString *)text inTextView:(UITextView *)textView
{
    UIFont *font = textView.font;
    [textView updateWidth:CONTENT_WIDTH];
    [textView updateHeight:10];
    [textView setFont:font];
    [textView setText:text];
    CGFloat height = 0;
    
    if (ISIOS7) {
        float fPadding = 16.0*2; // 8.0px x 2
        CGSize constraint = CGSizeMake(CONTENT_WIDTH - fPadding, CGFLOAT_MAX);
        CGSize size = [text sizeWithFont:font constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
        height = size.height + 20;
    }else{
        height = textView.contentSize.height;
    }
    [textView updateHeight:height];
    return height;
/*
    CGRect rect = textView.frame;
    rect.size = CGSizeMake(CONTENT_WIDTH, 10);
    textView.frame = rect;
    [textView setText:text];
    return textView.contentSize.height;
 */
}


+ (CGFloat)getCellHeightWithBBSPost:(PBBBSPost *)post
                         inTextView:(UITextView *)textView
{
    PBBBSContent * content = post.content;
    CGFloat height = [BBSPostDetailCell heightForContentText:content.text inTextView:textView];
    height += SPACE_CONTENT_TOP;
    if (post.content.hasThumbImage) {
        height += SPACE_CONTENT_BOTTOM_IMAGE;
    }else{
        height += SPACE_CONTENT_BOTTOM_TEXT;
    }
    return height;
}

// deprecated method
+ (CGFloat)heightForContentText:(NSString *)text
{
    CGSize size = [text sizeWithFont:CONTENT_FONT constrainedToSize:CGSizeMake(CONTENT_WIDTH, CONTENT_MAX_HEIGHT) lineBreakMode:NSLineBreakByCharWrapping];
    size.height += 2*Y_CONTENT_TEXT;
    return size.height;
}

// deprecated method
+ (CGFloat)getCellHeightWithBBSPost:(PBBBSPost *)post
{
    PBBBSContent * content = post.content;
    CGFloat height = [BBSPostDetailCell heightForContentText:content.text];
    height += SPACE_CONTENT_TOP;
    if (post.content.hasThumbImage) {
        height += SPACE_CONTENT_BOTTOM_IMAGE;
    }else{
        height += SPACE_CONTENT_BOTTOM_TEXT;
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
    if (self.useContentLabel) {
        [self.content setText:content.text];
        CGRect frame = self.content.frame;
        frame.size.height = [BBSPostDetailCell heightForContentText:content.text];
        self.content.frame = frame;
    }else{
        [self.contentTextView setText:content.text];
        CGRect frame = self.contentTextView.frame;
        frame.size.height = [BBSPostDetailCell heightForContentText:content.text inTextView:self.contentTextView];
        self.contentTextView.frame = frame;
    }

    
    //reset the size
  
    if (content.hasThumbImage) {
//        [self.image setImageWithURL:content.thumbImageURL
//                   placeholderImage:PLACEHOLDER_IMAGE
//                            success:^(UIImage *image, BOOL cached) {
//            [self updateImageViewFrameWithImage:image];
//        } failure:^(NSError *error) {
//            
//        }];
        
        [self.image setImageWithURL:content.thumbImageURL placeholderImage:PLACEHOLDER_IMAGE completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            [self updateImageViewFrameWithImage:image];
        }];

        self.image.hidden = NO;
    }else{
        self.image.hidden = YES;
    }
}

- (void)updateTimeStamp:(PBBBSPost *)post
{
    [self.timestamp setText:post.createDateString];
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

- (BOOL)isSeeingMe
{
    if ([self.currentUserId length] != 0 && [self.currentUserId isEqualToString:_post.createUser.userId]) {
        return YES;
    }
    return NO;
}

#define TOP_MARK_SPACE (ISIPAD ? 70 : 33)

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateUserInfo:_post.createUser];
    [self updateContent:_post.content];
    [self updateTimeStamp:_post];
    [self updateReward:_post];
    [self.topFlag setHidden:![_post isTopPost]];
    [self.markedFlag setHidden:![_post marked]];
    if (![self.topFlag isHidden]) {
        [self.markedFlag updateCenterX:self.topFlag.center.x + TOP_MARK_SPACE];
    }else {
        self.markedFlag.center = self.topFlag.center;
    }
    NSString *text = ([self isSeeingMe] ? NSLS(@"kSeeAllPost") : NSLS(@"kSeeLZOnly"));
    [self.seeMeOnly setTitle:text forState:UIControlStateNormal];

}



- (void)updateCellWithBBSPost:(PBBBSPost *)post
{
    self.post = post;
    [self setNeedsLayout];
}



- (void)dealloc {
    PPRelease(_currentUserId);
    PPRelease(_post);
    PPRelease(_reward);
    [_topFlag release];
    [_markedFlag release];
    [_seeMeOnly release];
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
