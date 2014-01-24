//
//  BBSPostActionCell.m
//  Draw
//
//  Created by gamy on 12-11-21.
//
//

#import "BBSPostActionCell.h"
#import "UIImageView+WebCache.h"
#import "BBSManager.h"
#import "UserManager.h"
#import "TimeUtils.h"
#import "BBSPopupSelectionView.h"

#define SPACE_CONTENT_TOP (ISIPAD ? 77 : 35)
#define SPACE_CONTENT_BOTTOM_IMAGE (ISIPAD ? 100 * 2.5 : 100) //IMAGE TYPE OR DRAW TYPE
#define SPACE_CONTENT_BOTTOM_TEXT (ISIPAD ? 40 : 15) //TEXT TYPE
//#define IMAGE_HEIGHT (ISIPAD ? 80 * 2.33 : 80)
#define CONTENT_TEXT_LINE (1000)

#define CONTENT_WIDTH (ISIPAD ?  420 : 190)
#define CONTENT_MAX_HEIGHT (99999999)

#define Y_CONTENT_TEXT (ISIPAD ? 5 * 2.33 : 5)
#define CONTENT_FONT [[BBSFontManager defaultManager] actionContentFont]

#define HEIGHT_SUPPORT (ISIPAD ? 80 * 2.33: 80)

#define SEEME_FONT (ISIPAD ? 9 * 2: 9)

@implementation BBSPostActionCell
@synthesize reply = _reply;
@synthesize action = _action;

- (void)dealloc
{
    PPRelease(_currentUserId);
    PPRelease(_reply);
    PPRelease(_action);
    PPRelease(_post);
    PPRelease(_option);
    [_supportImage release];
    [_seeMeOnly release];
    [super dealloc];
}

- (void)initViews
{
    self.content.numberOfLines = CONTENT_TEXT_LINE;
    self.content.font = CONTENT_FONT;
    [self.content setLineBreakMode:NSLineBreakByCharWrapping];
    
    self.nickName.font = [_bbsFontManager actionNickFont];
    self.timestamp.font = [_bbsFontManager actionDateFont];
    
    BBSImageManager *imageManager = [BBSImageManager defaultManager];
    [self.option setImage:[imageManager bbsDetailOptionUp]];
    
    [self.reply setImage:[imageManager bbsDetailReply] forState:UIControlStateNormal];
    
    [self.supportImage setImage:[[BBSImageManager defaultManager] bbsPostSupportImage]];
    self.useContentLabel = NO;
    self.content.hidden = YES;
    [self.content removeFromSuperview];
    SET_BUTTON_ROUND_STYLE_YELLOW(self.seeMeOnly);
    UIFont *font = [UIFont systemFontOfSize:SEEME_FONT];
    [self.seeMeOnly.titleLabel setFont:font];
}

+ (id)createCell:(id)delegate
{    
    BBSPostActionCell  *cell = [BBSTableViewCell createCellWithIdentifier:[self getCellIdentifier] delegate:delegate];
    [cell initViews];
    [cell setUseContentLabel:NO];
    return cell;
}

+ (NSString*)getCellIdentifier
{
    return @"BBSPostActionCell";
}

+ (CGFloat)heightForContentText:(NSString *)text inTextView:(UITextView *)textView
{
    UIFont *font = [[BBSFontManager defaultManager] actionContentFont];
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
}



+ (CGFloat)getCellHeightWithBBSAction:(PBBBSAction *)action inTextView:(UITextView *)textView
{
    if ([action isSupport]) {
        return HEIGHT_SUPPORT;
    }
    NSString *text = action.showText;
    CGFloat height = [BBSPostActionCell heightForContentText:text inTextView:textView];
    
    if (action.content.hasThumbImage) {
        height += (SPACE_CONTENT_TOP + SPACE_CONTENT_BOTTOM_IMAGE);
    }else{
        height += (SPACE_CONTENT_TOP + SPACE_CONTENT_BOTTOM_TEXT);
    }
    return height;
}

+ (CGFloat)heightForContentText:(NSString *)text
{
    CGSize size = [text sizeWithFont:CONTENT_FONT constrainedToSize:CGSizeMake(CONTENT_WIDTH, CONTENT_MAX_HEIGHT) lineBreakMode:NSLineBreakByCharWrapping];
    size.height += 2*Y_CONTENT_TEXT;
    return size.height;
}


+ (CGFloat)getCellHeightWithBBSAction:(PBBBSAction *)action
{
    if ([action isSupport]) {
        return HEIGHT_SUPPORT;
    }
    NSString *text = action.showText;
    CGFloat height = [BBSPostActionCell heightForContentText:text];

    if (action.content.hasThumbImage) {
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
    [self showVipFlag:user.isVIP];
}

- (void)updateReplyAction
{
    BOOL flag = [self.post canPay] && self.action.type == ActionTypeComment && ![self.action isMyAction];
    [self.reply setHidden:flag];
    [self.option setHidden:!flag];
}

- (void)updateContetWithText:(NSString *)text
{
    if (self.useContentLabel) {
        [self.content setText:text];
    }else{
        [self.contentTextView setText:text];
    }
}

- (void)updateContentWithAction:(PBBBSAction *)action
{

    NSString *text = [action showText];
    
    //reset the size
    if ([self useContentLabel]) {
        CGRect frame = self.content.frame;
        frame.size.height = [BBSPostActionCell heightForContentText:text];
        self.content.frame = frame;
    }else{
        CGRect frame = self.contentTextView.frame;
        frame.size.height = [BBSPostActionCell heightForContentText:text inTextView:self.contentTextView];
        self.contentTextView.frame = frame;
    }
    
    
    if (action.content.hasThumbImage) {
//        [self.image setImageWithURL:action.content.thumbImageURL placeholderImage:PLACEHOLDER_IMAGE success:^(UIImage *image, BOOL cached) {
//            [self updateImageViewFrameWithImage:image];
//        } failure:^(NSError *error) {
//            
//        }];
        
        [self.image setImageWithURL:action.content.thumbImageURL placeholderImage:PLACEHOLDER_IMAGE completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if (error == nil) {
                [self updateImageViewFrameWithImage:image];
            }
        }];
        
        self.image.hidden = NO;
    }else{
        self.image.hidden = YES;
    }
    
    if ([DeviceDetection isOS6] && [action isReply]) {
        NSInteger length = [text length];
        NSInteger contentLength = [[action.content text] length];
        NSInteger loc = length - contentLength;
        if (loc > 0) {
            
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text];
            
            [attr addAttribute:NSFontAttributeName
                         value:[[BBSFontManager defaultManager] actionContentFont]
                         range:NSMakeRange(0, length)];
            
            [attr addAttribute:NSForegroundColorAttributeName
                         value:COLOR_GRAY_TEXT
                         range:NSMakeRange(0, loc)];

            [attr addAttribute:NSForegroundColorAttributeName
                         value:COLOR_BROWN
                         range:NSMakeRange(loc, contentLength)];
            
            if (self.useContentLabel) {
                [self.content setAttributedText:attr];
            }else{
                [self.contentTextView setAttributedText:attr];
            }
            [attr release];
        }else{
            [self updateContetWithText:text];
        }
    }else{
        [self updateContetWithText:text];
    }
//    [self.contentTextView setBackgroundColor:[UIColor redColor]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateUserInfo:self.action.createUser];
    [self.timestamp setText:self.action.createDateString];
    [self updateReplyAction];
    
    if (self.hideReply) {
        self.reply.hidden = YES;
        self.option.hidden = YES;
    }
        
    if ([self.action isSupport]) {
        [self.supportImage setHidden:NO];
        self.content.hidden = YES;
        self.contentTextView.hidden = YES;
        self.image.hidden = YES;
    }else{
        [self.supportImage setHidden:YES];
        self.contentTextView.hidden = NO;
        self.content.hidden = NO;
        [self updateContentWithAction:self.action];
    }
    if([self.post.reward.actionId isEqualToString:self.action.actionId]){
        //if winner change the action bg.
        [self.bgImageView setImage:[_bbsImageManager bbsRewardActionBGImage]];
    }else{
        [self.bgImageView setImage:[_bbsImageManager bbsPostContentBGImage]];
    }
    
    [self.seeMeOnly setHidden:[_action isSupport]];
    
    NSString *text = ([self isSeeingMe] ? NSLS(@"kSeeAllPost") : NSLS(@"kSeeMeOnly"));
    [self.seeMeOnly setTitle:text forState:UIControlStateNormal];

}


- (void)updateCellWithBBSAction:(PBBBSAction *)action post:(PBBBSPost *)post
{
    self.action = action;
    self.post = post;
    [self setNeedsLayout];
}

- (BOOL)isSeeingMe
{
    if ([self.currentUserId length] != 0 && [self.currentUserId isEqualToString:_action.createUser.userId]) {
        return YES;
    }
    return NO;
}

- (IBAction)clickSeeMeOnly:(id)sender {
    NSString *uid = [self isSeeingMe] ? nil : _action.createUser.userId;
    if ([self.delegate respondsToSelector:@selector(didClickOnlySeeMe:)]) {
        [self.delegate didClickOnlySeeMe:uid];
    }
}

- (IBAction)clickRepyButton:(id)sender {
    if (delegate && [delegate respondsToSelector:@selector(didClickReplyButtonWithAction:)]) {
        [delegate didClickReplyButtonWithAction:self.action];
    }
}




#pragma mark - action delegate
- (void)clickAvatarButton:(id)sender
{
    if (delegate && [delegate respondsToSelector:@selector(didClickUserAvatar:)]) {
        [delegate didClickUserAvatar:self.action.createUser];
    }
}
- (void)clickImageButton:(id)sender
{
    //show draw...
    if (self.action.content.type == ContentTypeDraw && delegate
        && [delegate respondsToSelector:@selector(didClickDrawImageWithAction:)]) {
        [delegate didClickDrawImageWithAction:self.action];

    //show image...
    }else if(self.action.content.type == ContentTypeImage && delegate &&
             [delegate respondsToSelector:@selector(didClickImageWithURL:)])
    {
        [delegate didClickImageWithURL:self.action.content.largeImageURL];
    }
}

#pragma mark reward option
#define OPTION_VIEW_TAG 100

enum{
    OptionPay = 0,
    OptionReply,
};

- (void)showOption:(BOOL)show
{
    UIView *optionView = [self viewWithTag:OPTION_VIEW_TAG];
    [optionView removeFromSuperview];
    if (show) {
        NSArray *titles = [NSArray arrayWithObjects:NSLS(@"kReward"),NSLS(@"kReply"), nil];
        BBSPopupSelectionView *selectView = [[[BBSPopupSelectionView alloc] initWithTitles:titles delegate:self] autorelease];
        selectView.tag = OPTION_VIEW_TAG;
        CGPoint point = self.option.center;
        point.y -= 7;
        [selectView showInView:self showAbovePoint:point animated:YES];
    }
}
- (void)optionView:(BBSOptionView *)optionView didSelectedButtonIndex:(NSInteger)index
{
    if (index == OptionPay) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didClickPayButtonWithAction:)]) {
            [self.delegate didClickPayButtonWithAction:self.action];
        }
    }else if(index == OptionReply){
        [self clickRepyButton:nil];
    }
}

@end
