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
#define CONTENT_FONT [[BBSFontManager defaultManager] postContentFont]

#define HEIGHT_SUPPORT (ISIPAD ? 80 * 2.33: 80)

@implementation BBSPostActionCell
@synthesize reply = _reply;
@synthesize action = _action;

- (void)dealloc
{
    PPRelease(_reply);
    PPRelease(_action);
    PPRelease(_post);
    PPRelease(_option);
    [_supportImage release];
    [super dealloc];
}

- (void)initViews
{
    self.content.numberOfLines = CONTENT_TEXT_LINE;
    self.content.font = CONTENT_FONT;
    [self.content setLineBreakMode:NSLineBreakByCharWrapping];
    
    BBSImageManager *imageManager = [BBSImageManager defaultManager];
    [self.option setImage:[imageManager bbsDetailOptionUp]];
    [self.reply setImage:[imageManager bbsDetailReply] forState:UIControlStateNormal];
    [self.supportImage setImage:[[BBSImageManager defaultManager] bbsPostSupportImage]];
    
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
    CGRect rect = textView.frame;
    [textView setFont:[[BBSFontManager defaultManager] postContentFont]];
    rect.size = CGSizeMake(CONTENT_WIDTH, 10);
    textView.frame = rect;
    [textView setText:text];
    return textView.contentSize.height;
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
        [self.image setImageWithURL:action.content.thumbImageURL placeholderImage:nil success:^(UIImage *image, BOOL cached) {
            [self updateImageViewFrameWithImage:image];
        } failure:^(NSError *error) {
            
        }];
        
        self.image.hidden = NO;
    }else{
        self.image.hidden = YES;
    }
    
    [self.contentTextView setFont:[[BBSFontManager defaultManager] postContentFont]];
    
    if ([DeviceDetection isOS6] && [action isReply]) {
        NSInteger length = [text length];
        NSInteger contentLength = [[action.content text] length];
        NSInteger loc = length - contentLength;
        if (loc > 0) {
            NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text];
            [attr addAttribute:NSForegroundColorAttributeName value:[UIColor darkGrayColor] range:NSMakeRange(0, loc)];            
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



- (void)updateCellWithBBSAction:(PBBBSAction *)action post:(PBBBSPost *)post
{
    self.action = action;
    self.post = post;
    
    
    [self updateUserInfo:action.createUser];
    [self.timestamp setText:action.createDateString];
    [self updateReplyAction];
    
    if ([action isSupport]) {
        [self.supportImage setHidden:NO];
        self.content.hidden = YES;
        self.contentTextView.hidden = YES;
        self.image.hidden = YES;
    }else{
        [self.supportImage setHidden:YES];
        self.contentTextView.hidden = NO;
        self.content.hidden = NO;
        [self updateContentWithAction:action];        
    }
    if([post.reward.actionId isEqualToString:action.actionId]){
        //if winner change the action bg.
        [self.bgImageView setImage:[_bbsImageManager bbsRewardActionBGImage]];
    }else{
        [self.bgImageView setImage:[_bbsImageManager bbsPostContentBGImage]];
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
