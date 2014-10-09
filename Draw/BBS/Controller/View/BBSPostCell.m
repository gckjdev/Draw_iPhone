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
#import "GroupManager.h"
#import "StringUtil.h"
#import "BBSPermissionManager.h"
#import "MKBlockActionSheet.h"
#import "CommonUserInfoView.h"
#import "UserService.h"
#import "SuperUserManageAction.h"
#import "BBSService.h"
#import "GroupManager.h"
#import "ShowFeedController.h"

#define SPACE_CONTENT_TOP (ISIPAD ? (2.33 * 30) : 30)
#define SPACE_CONTENT_BOTTOM_IMAGE (ISIPAD ? (2.33 * 120) : 120) //IMAGE TYPE OR DRAW TYPE
//#define SPACE_CONTENT_BOTTOM_IMAGE (ISIPAD ? (2.33 * 80) : 80) //IMAGE TYPE OR DRAW TYPE
#define SPACE_CONTENT_BOTTOM_TEXT (ISIPAD ? (2.33 * 40) : 40) //TEXT TYPE
//#define IMAGE_HEIGHT (ISIPAD ? (2.33 * 80) : 80)
#define CONTENT_TEXT_LINE (ISIPAD ? (2.33 * 10) : 10)
#define CONTENT_WIDTH (ISIPAD ? (2.33 * 206) : 206)
#define CONTENT_MAX_HEIGHT (ISIPAD ? (70) : 70)
//#define CONTENT_MAX_HEIGHT (ISIPAD ? (2.33 * 200) : 200)
//#define Y_CONTENT_TEXT (ISIPAD ? (2.33 * 5) : 5)
#define Y_CONTENT_TEXT (ISIPAD ? (2.33 * 2) : 2)

#define CONTENT_FONT [[BBSFontManager defaultManager] postContentFont]
#define FLAG_RADIUS (ISIPAD ? 6 : 3)


#define PRIVATE_POST NSLS(@"kPrivatePostDesc")


@implementation BBSPostCell
@synthesize post = _post;
//@synthesize delegate = _delegate;



- (void)updateViews
{
    //action
    [BBSViewManager updateButton:self.reward
                         bgColor:[UIColor clearColor]
                         bgImage:nil
                           image:[_bbsImageManager bbsPostRewardedImage]
                            font:[_bbsFontManager postRewardFont]
                      titleColor:[_bbsColorManager postRewardedColor]
                           title:nil forState:UIControlStateSelected];
    [BBSViewManager updateButton:self.reward
                         bgColor:[UIColor clearColor]
                         bgImage:nil
                           image:[_bbsImageManager bbsPostRewardImage]
                            font:[_bbsFontManager postRewardFont]
                      titleColor:[_bbsColorManager postRewardColor]
                           title:nil forState:UIControlStateNormal];

    [BBSViewManager updateButton:self.comment
                         bgColor:[UIColor clearColor]
                         bgImage:nil
                           image:[_bbsImageManager bbsPostCommentImage]
                            font:[_bbsFontManager postActionFont]
                      titleColor:[_bbsColorManager postActionColor]
                           title:nil forState:UIControlStateNormal];
    
    [BBSViewManager updateButton:self.support
                         bgColor:[UIColor clearColor]
                         bgImage:nil
                           image:[_bbsImageManager bbsPostSupportImage]
                            font:[_bbsFontManager postActionFont]
                      titleColor:[_bbsColorManager postActionColor]
                           title:nil forState:UIControlStateNormal];
    
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

    
}

+ (id)createCell:(id)delegate
{
    BBSPostCell *cell = [BBSTableViewCell createCellWithIdentifier:[self getCellIdentifier] delegate:delegate];
    
    cell.content.numberOfLines = CONTENT_TEXT_LINE;
    cell.content.font = CONTENT_FONT;
    [cell updateViews];
    [cell setUseContentLabel:YES];
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
    CGSize size = [text sizeWithMyFont:CONTENT_FONT constrainedToSize:CGSizeMake(CONTENT_WIDTH, CONTENT_MAX_HEIGHT) lineBreakMode:NSLineBreakByCharWrapping];
    size.height += 2*Y_CONTENT_TEXT;
    return size.height;
}


+ (CGFloat)getCellHeightWithBBSPost:(PBBBSPost *)post
{
    PBBBSContent * content = post.content;
    BOOL isPrivateForMe = [post isPrivateForMe];
    NSString *text = isPrivateForMe ? PRIVATE_POST : content.text;
    
    CGFloat height = [BBSPostCell heightForContentText:text];
    
    if (post.content.hasThumbImage && !isPrivateForMe) {
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

- (void)updateContent:(PBBBSContent *)content
{
    BOOL isPrivateForMe = [self.post isPrivateForMe];
    NSString *text = !isPrivateForMe ? content.text : PRIVATE_POST;
    [self.content setText:text];    
    [self.content setTextColor:(isPrivateForMe?COLOR_GRAY_TEXT:COLOR_BROWN)];
    
    //reset the size
    CGRect frame = self.content.frame;
    frame.size.height = [BBSPostCell heightForContentText:text];
    self.content.frame = frame;

    if (content.hasThumbImage && !isPrivateForMe) {
        [self.image setImageWithURL:content.thumbImageURL placeholderImage:PLACEHOLDER_IMAGE completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if (error == nil) {
                [self updateImageViewFrameWithImage:image];
            }
        }];

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

#define TOP_MARK_SPACE (ISIPAD?70:33)

- (void)updateCellWithBBSPost:(PBBBSPost *)post
{
    self.post = post;
    [self updateUserInfo:post.createUser];
    [self updateContent:post.content];
    [self.timestamp setText:post.createDateString];
    [self updateSupportCount:post.supportCount commentCount:post.replyCount];
    [self updateReward:post];
    [self.topFlag setHidden:![post isTopPost]];
    [self.markedFlag setHidden:![post marked]];
    if (![self.topFlag isHidden]) {
        [self.markedFlag updateCenterX:self.topFlag.center.x + TOP_MARK_SPACE];
    }else {
        self.markedFlag.center = self.topFlag.center;
    }
}

- (void)setCellInfo:(PBBBSPost *)post
{
    [self updateCellWithBBSPost:post];
}

-(void)setButton{
    
    [_support setImage:[UIImage imageNamedFixed:@"bbs_post_support.png"]
              forState:UIControlStateNormal];
    [_comment setImage:[UIImage imageNamedFixed:@"bbs_post_support.png"]
              forState:UIControlStateNormal];
    
    
}


- (void)dealloc {
    PPRelease(_support);
    PPRelease(_comment);
    PPRelease(_post);
    PPRelease(_reward);
    PPRelease(_topFlag);
    [_markedFlag release];
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

+ (BOOL)isBoardManager:(id)delegate boardId:(NSString*)boardId
{
    if ([delegate respondsToSelector:@selector(forGroup)] == NO){
        PPDebug(@"<isBoardManager> delegate not respond to forGroup");
        return NO;
    }
    
    BOOL forGroup = [delegate performSelector:@selector(forGroup)];
    if (forGroup){
        
        GroupPermissionManager* pm = [GroupPermissionManager myManagerWithGroupId:boardId];
        BOOL ret = [pm canTopTopic];
        PPDebug(@"<isBoardManager> group admin %d", ret);
        return ret;
    }
    else{
        BBSPermissionManager *pm = [BBSPermissionManager defaultManager];
        BOOL ret = [pm isBoardManager:boardId];
        PPDebug(@"<isBoardManager> BBS board admin %d for %@", ret, boardId);
        return ret;
    }
}

+ (void)showBoardManagerUserAction:(PBBBSUser*)user
                           boardId:(NSString*)boardId
                            inView:(UIView*)view
                          delegate:(id)delegate
{
    MKBlockActionSheet* as = nil;

    int index = 0;
    
    int BUTTON_INDEX_VIEW_USER = index++;
    int BUTTON_INDEX_FORBID_USER_BOARD = index++;
    int BUTTON_INDEX_UNFORBID_USER_BOARD = index++;
    int BUTTON_INDEX_BLACK_USER = -1;
    int BUTTON_INDEX_CANCEL = -1;
    
    if ([[UserManager defaultManager] canBlackUser]){
        as = [[MKBlockActionSheet alloc] initWithTitle:@"版主/管理员操作"
                                              delegate:nil
                                     cancelButtonTitle:@"取消"
                                destructiveButtonTitle:@"查看用户详情"
                                     otherButtonTitles:@"禁言该用户", @"解除用户禁言", @"加入系统黑名单", nil];
        
        BUTTON_INDEX_BLACK_USER = index ++;
        BUTTON_INDEX_CANCEL = index ++;
        
    }
    else{
        as = [[MKBlockActionSheet alloc] initWithTitle:@"版主/管理员操作"
                                              delegate:nil cancelButtonTitle:@"取消"
                                destructiveButtonTitle:@"查看用户详情"
                                     otherButtonTitles:@"禁言该用户", @"解除用户禁言", nil];

        BUTTON_INDEX_CANCEL = index ++;
    }
    

    
    [as setActionBlock:^(NSInteger buttonIndex){
        
        if (buttonIndex == BUTTON_INDEX_VIEW_USER){
            [CommonUserInfoView showPBBBSUser:user
                                 inController:delegate
                                   needUpdate:YES
                                      canChat:YES];
        }
        else if (buttonIndex == BUTTON_INDEX_FORBID_USER_BOARD){

            if ([delegate isKindOfClass:[UIViewController class]] == NO){
                PPDebug(@"<showBoardManagerUserAction> but delegate is NOT UIViewController");
                return;
            }
            
            UIViewController* vc = (UIViewController*)delegate;
            UIView* view = vc.view;
            
            CommonDialog* inputDialog = [CommonDialog createInputFieldDialogWith:@"请输入版块禁言天数(0:永久)"];
            [inputDialog setClickOkBlock:^(UITextField *tf) {

                if ([SuperUserManageAction isInputValid:tf.text]) {

                    int days = tf.text.intValue;
                    NSString* msg = [NSString stringWithFormat:@"确定要对该用户【%@】在本版块禁言吗？", user.nickName];
                    CommonDialog* dialog = [CommonDialog createDialogWithTitle:nil message:msg style:CommonDialogStyleDoubleButton];
                    [dialog setClickOkBlock:^(UILabel *label){
                        
                        [[BBSService defaultService] forbidUser:user.userId boardId:boardId days:days resultBlock:nil];
                    }];
                    
                    [dialog showInView:view];
                }
            }];
            
            [inputDialog.inputTextField setPlaceholder:@"请输入要禁言的天数"];
            [inputDialog.inputTextField setText:@"3"];
            [inputDialog showInView:view];
        }
        else if (buttonIndex == BUTTON_INDEX_UNFORBID_USER_BOARD){
            [[BBSService defaultService] unforbidUser:user.userId boardId:boardId days:0 resultBlock:nil];
        }
        else if (buttonIndex == BUTTON_INDEX_BLACK_USER){
            [SuperUserManageAction askBlackUser:user.userId viewController:delegate];
        }
        else{
            // do nothing
        }
        
    }];
    
    [as showInView:view];
    [as release];
}

- (void)clickAvatarButton:(id)sender
{
    if ([BBSPostCell isBoardManager:delegate boardId:self.post.boardId]){
        [BBSPostCell showBoardManagerUserAction:self.post.createUser boardId:self.post.boardId inView:self delegate:delegate];
    }
    else{
        if (delegate && [delegate respondsToSelector:@selector(didClickUserAvatar:)]) {
            [delegate didClickUserAvatar:self.post.createUser];
        }
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
    else if([self.post.content.opusId length] > 0){
        // TODO BBS OPUS go to opus feed detail
        [ShowFeedController enterWithFeedId:self.post.content.opusId fromController:delegate];
    }
}
@end
