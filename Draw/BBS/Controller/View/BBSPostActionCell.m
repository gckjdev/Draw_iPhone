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

#define SPACE_CONTENT_TOP (ISIPAD ? 25 * 2 : 30)
#define SPACE_CONTENT_BOTTOM_IMAGE (ISIPAD ? 100 * 2 : 100) //IMAGE TYPE OR DRAW TYPE
#define SPACE_CONTENT_BOTTOM_TEXT (ISIPAD ? 15 * 2 : 15) //TEXT TYPE
#define IMAGE_HEIGHT (ISIPAD ? 186 : 80)
#define CONTENT_TEXT_LINE (1000)

#define CONTENT_WIDTH (ISIPAD ? 396 : 170)
#define CONTENT_MAX_HEIGHT (99999999)

#define Y_CONTENT_TEXT (ISIPAD ? 5 * 2 : 5)
#define CONTENT_FONT [[BBSFontManager defaultManager] postContentFont]


@implementation BBSPostActionCell
@synthesize reply = _reply;
@synthesize action = _action;

- (void)dealloc
{
    PPRelease(_reply);
    PPRelease(_action);
    PPRelease(_post);
    PPRelease(_option);
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

}

+ (id)createCell:(id)delegate
{    
    BBSPostActionCell  *cell = [BBSTableViewCell createCellWithIdentifier:[self getCellIdentifier] delegate:delegate];
    [cell initViews];
    return cell;
}

+ (NSString*)getCellIdentifier
{
    return @"BBSPostActionCell";
}


+ (CGFloat)heightForContentText:(NSString *)text
{
    CGSize size = [text sizeWithFont:CONTENT_FONT constrainedToSize:CGSizeMake(CONTENT_WIDTH, CONTENT_MAX_HEIGHT) lineBreakMode:NSLineBreakByCharWrapping];
    size.height += 2*Y_CONTENT_TEXT;
    return size.height;
}


+ (CGFloat)getCellHeightWithBBSAction:(PBBBSAction *)action
{
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
    BOOL flag = [self.post canPay] && self.action.type == ActionTypeComment;
    [self.reply setHidden:flag];
    [self.option setHidden:!flag];
}

- (void)updateContentWithAction:(PBBBSAction *)action
{
    
    NSString *text = [action showText];
    [self.content setText:text];
    
    //reset the size
    CGRect frame = self.content.frame;
    frame.size.height = [BBSPostActionCell heightForContentText:text];
    self.content.frame = frame;
        
    if (action.content.hasThumbImage) {
        [self.image setImageWithURL:action.content.thumbImageURL placeholderImage:nil];
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


- (void)updateCellWithBBSAction:(PBBBSAction *)action post:(PBBBSPost *)post
{
    self.action = action;
    self.post = post;
    [self updateUserInfo:action.createUser];
    [self updateContentWithAction:action];
    [self updateTimeStamp:action.createDate];
    [self updateReplyAction];
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
        NSArray *titles = [NSArray arrayWithObjects:NSLS(@"k奖赏"),NSLS(@"k回复"), nil];
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
