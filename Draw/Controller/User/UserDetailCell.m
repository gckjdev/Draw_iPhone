//
//  UserDetailCell.m
//  Draw
//
//  Created by Kira on 13-3-20.
//
//

#import "UserDetailCell.h"
#import "GameBasic.pb.h"
#import "ShareImageManager.h"
#import "UserDetailProtocol.h"
#import "UserSettingController.h"
#import "LevelService.h"
#import "GameSNSService.h"
#import "SNSUtils.h"
#import "TimeUtils.h"
//#import "PPSNSCommonService.h"
#import "CustomSegmentedControl.h"
#import "ShareImageManager.h"
#import "FeedCarousel.h"
#import "UIColor+UIColorExt.h"
#import "RoundPercentageView.h"
#import "UIImageView+WebCache.h"
#import "CustomInfoView.h"
#import "UIViewUtils.h"
#import "GameApp.h"
#import "UIImageView+Extend.h"
#import "CommonDialog.h"
#import "UILabel+Extend.h"
#import "SuperHomeController.h"
#import "IconView.h"
#import "UILabel+Touchable.h"
#import "GroupManager.h"
#import "GroupService.h"
#import "GroupTopicController.h"
#import "GroupUIManager.h"

#define BG_COLOR  OPAQUE_COLOR(56, 208, 186)

#define NICK_NAME_FONT (ISIPAD?30:15)
#define NICK_NAME_MAX_WIDTH (ISIPAD?424:181)

#define USER_ACTION_BTN_INDEX_OFFSET    20130330
#define USER_ACTION_BTN_COUNT 5

#define SNS_BTN_INDEX_OFFSET 120130412
#define SNS_COUNT 3

@interface UserDetailCell ()

@property (retain, nonatomic) CustomSegmentedControl* segmentedControl;
@property (retain, nonatomic) FeedCarousel *carousel;
@property (assign, nonatomic) NSObject<UserDetailProtocol> *detail;

@end

@implementation UserDetailCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)setCellWithUserDetail:(NSObject<UserDetailProtocol> *)detail
{
    self.detail = detail;
    PBGameUser* pbUser = [detail getUser];
    
    [self.nickNameLabel addTapGuestureWithTarget:self selector:@selector(clickNickNameLabel)];
    
    [self updateNickNameLabel];
    [self updateSignLabel];
    
    if ([detail isPrivacyVisable]) {
        [self.birthLabel setText:[NSString stringWithFormat:@"%@ : %@", NSLS(@"kBirthday"), ([pbUser hasBirthday]?pbUser.birthday:@"-")]];
        NSString* zodiacStr = [pbUser hasZodiac]?[LocaleUtils getZodiacWithIndex:pbUser.zodiac-1]:@"-";
        zodiacStr = (zodiacStr != nil)?zodiacStr:@"-";
        [self.zodiacLabel setText:[NSString stringWithFormat:@"%@ : %@", NSLS(@"kZodiac"),zodiacStr]];
        [self.bloodTypeLabel setText:[NSString stringWithFormat:@"%@ : %@", NSLS(@"kBloodGroup"), ([pbUser hasBloodGroup]?pbUser.bloodGroup:@"-")]];
    } else {
        [self.birthLabel setText:[NSString stringWithFormat:@"%@ : %@", NSLS(@"kBirthday"), @"-"]];
        [self.zodiacLabel setText:[NSString stringWithFormat:@"%@ : %@", NSLS(@"kZodiac"), @"-"]];
        [self.bloodTypeLabel setText:[NSString stringWithFormat:@"%@ : %@", NSLS(@"kBloodGroup"), @"-"]];
    }
    
    [self.locationLabel setText:[NSString stringWithFormat:@"%@ : %@", NSLS(@"kLocation"), ([pbUser hasLocation]?pbUser.location:@"-")]];
        
    self.basicDetailView.hidden = YES;
    
    [self.editButton setHidden:![detail canEdit]];
    
    [self.customBackgroundControl setUserInteractionEnabled:[detail canEdit]];


    [self.blackListBtn setHidden:![detail isBlackBtnVisable]];
    [self.superBlackBtn setHidden:![detail isSuperManageBtnVisable]];
    
    [self.genderImageView setImage:[[ShareImageManager defaultManager] userDetailGenderImage:[pbUser gender]]];
    
    [detail initSNSButton:self.sinaBtn withType:TYPE_SINA];
    [detail initSNSButton:self.qqBtn withType:TYPE_QQ];
    [detail initSNSButton:self.facebookBtn withType:TYPE_FACEBOOK];
    
    for (int i = 0; i < USER_ACTION_BTN_COUNT; i ++) {
        UserDetailRoundButton* btn =(UserDetailRoundButton*)[self viewWithTag:(USER_ACTION_BTN_INDEX_OFFSET+i)];
        [detail initUserActionButton:btn atIndex:i];
    }
    
    [self.blackListBtn setTitle:[detail blackUserBtnTitle] forState:UIControlStateNormal];

    
    [self.segmentedControl setHidden:![detail hasFeedTab]];
    
    [self.noSNSTipsLabel setHidden:!(self.sinaBtn.hidden && self.qqBtn.hidden && self.facebookBtn.hidden)];
    

    [self.customBackgroundImageView setImageWithUrl:[NSURL URLWithString:[[detail getUser] backgroundUrl]] placeholderImage:nil showLoading:NO animated:YES];

    [self.customBackgroundControl setBackgroundColor:BG_COLOR];
    
    
    [self.customBackgroundControl addTarget:self action:@selector(clickCustomBackground:) forControlEvents:UIControlEventTouchUpInside];
    

    
    [self.exploreBbsPostBtn setTitle:NSLS(@"kViewPost") forState:UIControlStateNormal];
    
    if ([[UserManager defaultManager] getLanguageType] != ChineseType) {
        [self.exploreBbsPostBtn setHidden:YES];
    }
    
    [self.seperator3 setHidden:(self.blackListBtn.hidden && self.superBlackBtn.hidden && self.exploreBbsPostBtn.hidden)];
    [self.specialTitleLabel setHidden:self.seperator3.hidden];
    
    if (self.blackListBtn.hidden && !self.exploreBbsPostBtn.hidden) {
        [self.exploreBbsPostBtn setCenter:CGPointMake(self.bounds.size.width/2, self.exploreBbsPostBtn.center.y)];
    }
    
    if (!self.blackListBtn.hidden && self.exploreBbsPostBtn.hidden) {
        [self.blackListBtn setCenter:CGPointMake(self.bounds.size.width/2, self.exploreBbsPostBtn.center.y)];
        [self.superBlackBtn setCenter:self.exploreBbsPostBtn.center];
    }
    
    [self adaptSNSButton];
    
    [self handleInSecureSmsApp];
    
    
    PBGameUser *user = [detail getUser];
    self.avatarView = [[[AvatarView alloc] initWithUrlString:[user avatar] frame:self.avatarHolderView.bounds gender:user.gender level:user.level vip:user.vip] autorelease];
    _avatarView.delegate = self;
    _avatarView.layer.borderWidth = 0;
    [_avatarView setIsVIP:NO];
    [self.avatarHolderView addSubview:_avatarView];
    
    self.signLabel.textColor = COLOR_WHITE;

    
    [self.seperator1 setBackgroundColor:BG_COLOR];
    [self.seperator2 setBackgroundColor:COLOR_ORANGE];
    [self.seperator3 setBackgroundColor:COLOR_YELLOW];
    [self.seperator5 setBackgroundColor:COLOR_YELLOW];
    
    SET_VIEW_ROUND_CORNER(self.hisOpusLabel);
    [self.hisOpusLabel setBackgroundColor:BG_COLOR];
    self.hisOpusLabel.textColor = [UIColor whiteColor];
    
    SET_VIEW_ROUND_CORNER(self.snsTipLabel);
    [self.snsTipLabel setBackgroundColor:COLOR_ORANGE];
    self.snsTipLabel.textColor = [UIColor whiteColor];

    SET_VIEW_ROUND_CORNER(self.groupHeader);
    [self.groupHeader setBackgroundColor:COLOR_YELLOW];
    self.groupHeader.textColor = COLOR_BROWN;
    
    SET_VIEW_ROUND_CORNER(self.specialTitleLabel);
    [self.specialTitleLabel setBackgroundColor:COLOR_YELLOW];
    self.specialTitleLabel.textColor = COLOR_BROWN;
    
    
    [self.exploreBbsPostBtn setBackgroundImage:[UIImage imageNamed:@"user_detail_button@2x.png"] forState:UIControlStateNormal];
    [self.exploreBbsPostBtn setTitleColor:COLOR_BROWN forState:UIControlStateNormal];


    [self.superBlackBtn setBackgroundImage:[UIImage imageNamed:@"user_detail_button@2x.png"] forState:UIControlStateNormal];
    [self.superBlackBtn setTitleColor:COLOR_BROWN forState:UIControlStateNormal];


    [self.blackListBtn setBackgroundImage:[UIImage imageNamed:@"user_detail_button@2x.png"] forState:UIControlStateNormal];
    [self.blackListBtn setTitleColor:COLOR_BROWN forState:UIControlStateNormal];
    
    if ([[UserManager defaultManager] isMe:detail.getUserId]
        ) {
        self.badgeView.hidden = NO;
        [self.badgeView setNumber:[[UserManager defaultManager] getUserBadgeCountWithoutHomeBg]];

        self.bgBadgeView.hidden = NO;
        self.bgButton.hidden = NO;
        BOOL hasTrySetHomeBg = [[UserManager defaultManager] hasTrySetHomeBg];
        [self.bgBadgeView setNumber:(hasTrySetHomeBg ? 0 : 1)];
    }else{
        self.badgeView.hidden = YES;
        
        self.bgBadgeView.hidden = YES;
        self.bgButton.hidden = YES;
    }
    [self updateGroupInfo];
}


#define SNS_BTN_CENTER_OFFSET (ISIPAD?75:33)
- (void)adaptSNSButton
{
    NSMutableArray* tempArray = [[[NSMutableArray alloc] initWithCapacity:SNS_COUNT] autorelease];
    for (int i = 0; i < SNS_COUNT; i ++) {
        UIButton* btn = (UIButton*)[self viewWithTag:(SNS_BTN_INDEX_OFFSET + i)];
        if (btn && !btn.hidden) {
            [tempArray addObject:btn];
        }
    }
    if (tempArray.count == 1) {
        UIButton* btn = (UIButton*)[tempArray objectAtIndex:0];
        [btn setCenter:CGPointMake(self.frame.size.width/2, btn.center.y)];
    } else if (tempArray.count == 2) {
        UIButton* btn1 = (UIButton*)[tempArray objectAtIndex:0];
        UIButton* btn2 = (UIButton*)[tempArray objectAtIndex:1];
        [btn1 setCenter:CGPointMake(self.frame.size.width/2 - SNS_BTN_CENTER_OFFSET, btn1.center.y)];
        [btn2 setCenter:CGPointMake(self.frame.size.width/2 + SNS_BTN_CENTER_OFFSET, btn2.center.y)];
    }
}

#define MAX_HEIGHT (ISIPAD?81:36)
#define MAX_CONSTRAIN_HEIGHT 99999
//#define MAX_SIGN_FRAME (ISIPAD?CGRectMake(84, 70, 600, 81):CGRectMake(46, 31, 229, 36))

#define MAX_SIGN_HEIGHT (ISIPAD?81:36)

- (void)adjustSignatureLabel:(UILabel*)label WithText:(NSString*)signatureText
{
    [label setText:signatureText];
    CGSize size = [signatureText sizeWithFont:label.font constrainedToSize:CGSizeMake(label.frame.size.width, MAX_CONSTRAIN_HEIGHT) lineBreakMode:UILineBreakModeCharacterWrap];
    if (size.height < MAX_HEIGHT) {
        [label updateHeight:size.height];
    } else {
        [label updateHeight:MAX_SIGN_HEIGHT];
    }
}

+ (float)getCellHeight
{
    return ([DeviceDetection isIPAD]?1770:800);
}

+ (NSString*)getCellIdentifier
{
    return @"UserDetailCell";
    
}

#define CAROUSEL_CENTER (ISIPAD ? CGPointMake(384, 992) : ([DeviceDetection isIPhone5] ? CGPointMake(160, 460) : CGPointMake(160, 455)))

#define TAB_FONT    (ISIPAD?22:11)

+ (id)createCell:(id)delegate
{
    UserDetailCell* cell = (UserDetailCell*)[super createCell:delegate];
    cell.avatarView.delegate = cell;
    
    cell.segmentedControl = [[[CustomSegmentedControl alloc]
                              initWithSegmentTitles:@[NSLS(@"kUserOpus"), NSLS(@"kFavorite")]
                              frame:cell.feedTabHolder.frame
                              unpressedColor:BG_COLOR pressedColor:COLOR_GREEN delegate:cell] autorelease];
    
    [cell addSubview:cell.segmentedControl];
//    [cell.segmentedControl setFrame:cell.feedTabHolder.frame];
    [cell.segmentedControl setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cell.segmentedControl setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [cell.segmentedControl setTitleFont:[UIFont systemFontOfSize:TAB_FONT]];
    
    cell.carousel = [FeedCarousel createFeedCarousel];
    cell.carousel.delegate = cell;
    cell.carousel.center = CAROUSEL_CENTER;
    cell.carousel.tag = 400;
    [cell addSubview:cell.carousel];
    [cell.carousel startScrolling];
    [cell.carousel enabaleWrap:YES];
    [cell.carousel showActivity];
    cell.carousel.backgroundColor = [UIColor clearColor];
    
    
    return cell;
}

#define TAG_WILL_HIDE   400
- (void)handleInSecureSmsApp
{

}


- (void)dealloc {
    
    PPRelease(imageUploader);
    PPRelease(_bgBadgeView);
    PPRelease(_bgButton);
    
    [_carousel release];
    [_nickNameLabel release];
    [_signLabel release];
//    [_levelLabel release];
    [_birthLabel release];
    [_zodiacLabel release];
    [_bloodTypeLabel release];
    [_locationLabel release];
    [_avatarView release];
    [_basicDetailView release];
    [_genderImageView release];
//    [_backgroundImageView release];
//    [_fanCountLabel release];
//    [_followCountLabel release];
    [_editButton release];
    [_drawToButton release];
    [_chatButton release];
    [_followButton release];
    [_fanCountButton release];
    [_followCountButton release];
    [_sinaBtn release];
    [_qqBtn release];
    [_facebookBtn release];
    [_blackListBtn release];
    [_superBlackBtn release];
    [_feedTabHolder release];
    [_segmentedControl release];
    [_noSNSTipsLabel release];
    [_customBackgroundControl release];
    [_customBackgroundImageView release];
    [_specialTitleLabel release];
    [_exploreBbsPostBtn release];
    [_avatarHolderView release];
    [_seperator1 release];
    [_seperator2 release];
    [_seperator3 release];
    [_hisOpusLabel release];
    [_snsTipLabel release];
    [_signButton release];
    [_badgeView release];
    [_groupName release];
    [_inviteMemberButton release];
    [_inviteGuestButton release];
    [_groupIcon release];
    [_groupHeader release];
    [_seperator5 release];
    [_vipFlag release];
    [super dealloc];
}

#pragma mark - CustomSegmentedControl delegate
- (void) touchUpInsideSegmentIndex:(NSUInteger)segmentIndex
{
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didClickTabAtIndex:)]) {
        [_detailDelegate didClickTabAtIndex:segmentIndex];
    }
}

-(IBAction)switchBasicInfoAndAction:(id)sender
{
    [self.basicDetailView setHidden:!self.basicDetailView.hidden];
}

- (IBAction)clickEdit:(id)sender
{
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didClickEdit)]) {
        [_detailDelegate didClickEdit];
    }
}

- (IBAction)clickFollow:(id)sender
{
    CHECK_AND_LOGIN([self theTopView]);
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didClickFollowButton)]) {
        [_detailDelegate didClickFollowButton];
    }
}

- (IBAction)clickFollowCount:(id)sender
{
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didClickFollowCountButton)]) {
        [_detailDelegate didClickFollowCountButton];
    }
}

- (IBAction)clickFanCount:(id)sender
{
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didClickFanCountButton)]) {
        [_detailDelegate didClickFanCountButton];
    }
}

- (IBAction)clickChatButton:(id)sender
{
    CHECK_AND_LOGIN([self theTopView]);
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didClickChatButton)]) {
        [_detailDelegate didClickChatButton];
    }
}

- (IBAction)clickDrawToButton:(id)sender
{
    CHECK_AND_LOGIN([self theTopView]);
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didClickDrawToButton)]) {
        [_detailDelegate didClickDrawToButton];
    }
}

- (void)didClickOnAvatar:(NSString *)userId{
    
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didClickAvatar)]) {
        [_detailDelegate didClickAvatar];
    }
}

- (IBAction)clickBlack:(id)sender
{
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didclickBlack)]) {
        [_detailDelegate didclickBlack];
    }
}

- (IBAction)clickManage:(id)sender
{
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didclickManage)]) {
        [_detailDelegate didclickManage];
    }
}

- (IBAction)clickSina:(id)sender
{
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didclickSina)]) {
        [_detailDelegate didclickSina];
    }
}

- (IBAction)clickQQ:(id)sender
{
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didclickQQ)]) {
        [_detailDelegate didclickQQ];
    }
}

- (IBAction)clickFacebook:(id)sender
{
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didclickFacebook)]) {
        [_detailDelegate didclickFacebook];
    }
}

- (IBAction)clickMore:(id)sender
{
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didClickMore)]) {
        [_detailDelegate didClickMore];
    }
}

- (IBAction)clickUserAction:(id)sender
{
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didClickUserActionButtonAtIndex:)]) {
        [_detailDelegate didClickUserActionButtonAtIndex:(((UIButton*)sender).tag - USER_ACTION_BTN_INDEX_OFFSET)];
    }
}

- (IBAction)clickCustomBackground:(id)sender
{
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didClickCustomBackground)]) {
        [_detailDelegate didClickCustomBackground];
    }
}

- (IBAction)clickBBSPost:(id)sender
{
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didClickBBSPost)]) {
        [_detailDelegate didClickBBSPost];
    }
}

- (ChangeAvatar*)backgroundPicker
{
    if (imageUploader == nil) {
        imageUploader = [[ChangeAvatar alloc] init];
        imageUploader.autoRoundRect = NO;
        imageUploader.isCompressImage = NO;
    }
    return imageUploader;
}

- (IBAction)clickSetHomeBg:(id)sender
{
    [[UserManager defaultManager] setTrySetHomeBg];
    [self.bgBadgeView setNumber:0];    
    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_HOME_BG_NOTIFICATION_KEY
                                                        object:nil];    
    
    // set home bg
    [[self backgroundPicker] showSelectionView:self.delegate
                                      delegate:nil
                            selectedImageBlock:^(UIImage *image)
     {
        if ([[UserManager defaultManager] setPageBg:image
                                             forKey:HOME_BG_KEY]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_HOME_BG_NOTIFICATION_KEY
                                                                object:nil];
            POSTMSG(NSLS(@"kCustomHomeBgSucc"));
        }    
     }
                            didSetDefaultBlock:^
    {
        if ([[UserManager defaultManager] resetPageBgforKey:HOME_BG_KEY]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_HOME_BG_NOTIFICATION_KEY
                                                                object:nil];
            POSTMSG(NSLS(@"kResetCustomHomeBgSucc"));
        }
    }
                                         title:NSLS(@"kCustomHomeBg")
                               hasRemoveOption:YES
                                  canTakePhoto:YES
                             userOriginalImage:YES];
    
}

- (void)setDrawFeedList:(NSArray*)feedList tipText:(NSString *)tipText
{
    [self.carousel setDrawFeedList:feedList
                           tipText:(NSString *)tipText];
}

- (void)clearDrawFeedList
{
    [self.carousel clearDrawFeedList];
}

- (void)setIsLoadingFeed:(BOOL)isLoading
{
    if (isLoading) {
        [self.carousel showActivity];
    } else {
        [self.carousel hideActivity];
    }

}

#pragma mark - feedCarousel delegate
- (void)didSelectDrawFeed:(DrawFeed *)drawFeed
{
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didClickDrawFeed:)]) {
        [_detailDelegate didClickDrawFeed:drawFeed];
    }
}

- (IBAction)clickSignButton:(id)sender {
    
    if ([[UserManager defaultManager] isMe:_detail.getUserId]
        ) {
        
        CommonDialog *dialog = [CommonDialog createInputViewDialogWith:NSLS(@"kSignature")];
        dialog.inputTextView.text = [_detail getUser].signature;
        [dialog setMaxInputLen:[PPConfigManager getSignatureMaxLen]];

        [dialog setClickOkBlock:^(UITextView *tv){
            
            if ([tv.text isEqualToString:[_detail getUser].signature]) {
                return ;
            }
            
            [[UserManager defaultManager] setSignature:tv.text];
            [self saveUserInfo];
        }];
        
        [dialog showInView:self];
        
    }else{
        
        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kSignature") message:[[self.detail getUser] signature] style:CommonDialogStyleCross];
        
        [dialog showInView:self];
    }
}

- (void)updateSignLabel{
    
    NSString *text = @"";
    
    if ([[[_detail getUser] xiaojiNumber] length] > 0) {
        text = [text stringByAppendingString:[NSString stringWithFormat:@"%@:%@", NSLS(@"kXiaoji"), [[_detail getUser] xiaojiNumber]]];
        text = [text stringByAppendingString:@"  "];
    }
    
    
    text = [text stringByAppendingString:[NSString stringWithFormat:@"lv:%d", [_detail getUser].level]];
    
    if ([[_detail getUser].signature length] > 0) {
        text = [text stringByAppendingString:@"  "];
        text = [text stringByAppendingString:[_detail getUser].signature];
    }
    
    self.signLabel.text = text;
    
    CGSize constrainedSize = (ISIPAD ? CGSizeMake(550, 75) : CGSizeMake(230, 42));
    [self.signLabel wrapTextWithConstrainedSize:constrainedSize];
    [self.signLabel updateCenterX:self.center.x];
    [self.signLabel updateOriginY:self.signButton.frame.origin.y];
}

- (void)saveUserInfo{
    
    PBGameUser* user = [[UserManager defaultManager] pbUser];
    
    [[UserService defaultService] updateUser:user resultBlock:^(int resultCode) {
        
        if (resultCode == 0){
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kUpdateUserSucc") delayTime:1.5];
            
            [self updateSignLabel];
            [self updateNickNameLabel];
        }
        else{
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kUpdateUserFail") delayTime:1.5];
        }
    }];
}

- (void)updateNickNameLabel{
    
    PBGameUser* pbUser = [_detail getUser];
    
    [self.nickNameLabel setText:pbUser.nickName];
    
    CGSize constrainedSize = ISIPAD ? CGSizeMake(440, 45) : CGSizeMake(170, 19);
    [self.nickNameLabel wrapTextWithConstrainedSize:constrainedSize];
    [self.nickNameLabel updateCenterX:self.center.x];
    [self.nickNameLabel updateCenterY:self.genderImageView.center.y];
    
    
    CGFloat originX = self.nickNameLabel.frame.origin.x - (ISIPAD ? 4:2) - self.genderImageView.frame.size.width;
    [self.genderImageView updateOriginX:originX];

    originX -= (CGRectGetWidth(self.vipFlag.bounds));
    [self.vipFlag updateOriginX:originX];
    self.vipFlag.hidden = (_detail.getUser.vip == 0);
}

- (void)clickNickNameLabel{
    
    if ([[UserManager defaultManager] isMe:_detail.getUserId]
        ) {
    
        CommonDialog *dialog = [CommonDialog createInputFieldDialogWith:NSLS(@"kNickname")];
        dialog.inputTextField.text = [_detail getUser].nickName;
        [dialog setMaxInputLen:[PPConfigManager getNicknameMaxLen]];
        [dialog setAllowInputEmpty:NO];
        
        [dialog setClickOkBlock:^(UITextField *tf){
            
            if ([tf.text isEqualToString:[_detail getUser].nickName]) {
                return;
            }
            [[UserManager defaultManager] setNickName:tf.text];
            [self saveUserInfo];
        }];
        
        [dialog showInView:self];
        
    }else{
        
        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kNickname") message:[[self.detail getUser] nickName] style:CommonDialogStyleCross];
        
        [dialog showInView:self];
    }
}

- (void)updateGroupInfo
{
    
    [self.inviteGuestButton setBackgroundImage:[UIImage imageNamed:@"user_detail_button@2x.png"] forState:UIControlStateNormal];
    [self.inviteGuestButton setTitleColor:COLOR_BROWN forState:UIControlStateNormal];
    
    [self.inviteMemberButton setBackgroundImage:[UIImage imageNamed:@"user_detail_button@2x.png"] forState:UIControlStateNormal];
    [self.inviteMemberButton setTitleColor:COLOR_BROWN forState:UIControlStateNormal];
    
    [self.groupName setTextColor:self.noSNSTipsLabel.textColor];
    [self.groupName setFont:self.noSNSTipsLabel.font];

    
    NSString *myGroupId = [[GroupManager defaultManager] userCurrentGroupId];
    GroupPermissionManager *gpm = [GroupPermissionManager myManagerWithGroupId:myGroupId];

    if (![[self.detail getUser] hasGroupInfo]) {
        //not a member
        
        [self.groupName setText:NSLS(@"kNoJoinGroup")];
        [self.groupName updateCenterX:CGRectGetMidX(self.noSNSTipsLabel.frame)];
        [self.groupName setTextAlignment:NSTextAlignmentCenter];
        [self.groupName disableTapTouch];


        
        self.groupIcon.hidden = YES;
        self.inviteGuestButton.hidden = self.inviteMemberButton.hidden = ![gpm canInviteUser];
        
    }else{
        //is member
        PBSimpleGroup *group = [[self.detail getUser] groupInfo];
        self.groupName.hidden = self.groupIcon.hidden = NO;
        self.inviteGuestButton.hidden = ![gpm canInviteGuest] || [[UserManager defaultManager] isMe:_detail.getUserId];
        
        [self.inviteGuestButton updateCenterX:CGRectGetMidX(self.contentView.bounds)];

        self.inviteMemberButton.hidden = YES;
        [self.groupName setText:group.groupName];
        [self.groupIcon setGroupId:group.groupId];
        [self.groupIcon setImageURL:[NSURL URLWithString:group.groupMedal] placeholderImage:[GroupUIManager defaultGroupMedal]];
        __block typeof (self) cp = self;
        
        [self.groupIcon setClickHandler:^(IconView *iconView){
            [cp enterGroup];
        }];
        
        [self.groupName setTextAlignment:NSTextAlignmentLeft];
        CGFloat x = CGRectGetMaxX(self.groupIcon.frame) + CGRectGetWidth(self.groupIcon.frame)/4;
        [self.groupName updateOriginX:x];
        [self.groupName enableTapTouch:self selector:@selector(handleTapOnGroupName:)];
    }
    if (self.inviteGuestButton.hidden) {
        CGFloat centerY = (CGRectGetMidY(self.seperator2.frame)+CGRectGetMidY(self.seperator5.frame)) / 2;
        [self.groupName updateCenterY:centerY];
        [self.groupIcon updateCenterY:centerY];
    }
}

- (void)handleTapOnGroupName:(UITapGestureRecognizer *)tap
{
    if(tap.state == UIGestureRecognizerStateEnded){
        [self enterGroup];
    }
}

- (NSString *)targetUserGroupId{
    return [[[self.detail getUser] groupInfo] groupId];
}

- (NSString *)targetUserId
{
    return [self.detail getUserId];
}

- (void)enterGroup
{
    PPViewController * vc = (id)[self theViewController];
    [GroupTopicController enterWithGroupId:[self targetUserGroupId] fromController:vc];
}

- (void)alertForInvation:(BOOL)member callback:(dispatch_block_t)callback
{
    NSString *title = member ? NSLS(@"kInviteMemberTitle") : NSLS(@"kInviteGuestTitle");
    
    NSString *message = member ? NSLS(@"kInviteMemberMessage") : NSLS(@"kInviteGuestMessage");

    CommonDialog *dialog = [CommonDialog createDialogWithTitle:title message:message style:CommonDialogStyleDoubleButton];
    [dialog setClickOkBlock:^(id view){
        EXECUTE_BLOCK(callback);
    }];
    [dialog showInView:[self theTopView]];
}

- (IBAction)inviteMember:(id)sender {
    __block UIButton *button = sender;
    NSString *groupId = [[GroupManager defaultManager] userCurrentGroupId];
    [self alertForInvation:YES callback:^{
        [[GroupService defaultService] inviteMembers:@[[self targetUserId]] groupId:groupId titleId:GroupRoleMember callback:^(NSError *error) {
            if (!error) {
//                button.hidden = YES;
                [button setTitle:NSLS(@"kInvitationSent") forState:UIControlStateNormal];
                [button setEnabled:NO];
            }
        }];        
    }];
}

- (IBAction)inviteGuest:(id)sender {
    __block UIButton *button = sender;
    NSString *groupId = [[GroupManager defaultManager] userCurrentGroupId];
    [self alertForInvation:NO callback:^{
        [[GroupService defaultService] inviteGuests:@[[self targetUserId]] groupId:groupId callback:^(NSError *error) {
            if (!error) {
                [button setTitle:NSLS(@"kInvitationSent") forState:UIControlStateNormal];
                [button setEnabled:NO];
            }
        }];        
    }];
}

@end
