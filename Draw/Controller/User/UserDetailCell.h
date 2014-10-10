//
//  UserDetailCell.h
//  Draw
//
//  Created by Kira on 13-3-20.
//
//

#import "PPTableViewCell.h"
#import "UserDetailProtocol.h"
#import "StableView.h"
#import "iCarousel.h"
#import "CustomSegmentedControl.h"
#import "FeedCarousel.h"
#import "LocalizableLabel.h"
#import "ChangeAvatar.h"

@class GroupIconView;
@class PBGroup;
@class PBGameUser;
@class AvatarView;
@class LocalizableLabel;
@class PPViewController;
@class UserDetailRoundButton;
@class BadgeView;

@protocol UserDetailCellDelegate <NSObject>

@optional
- (void)didClickEdit;
- (void)didClickFanCountButton;
- (void)didClickFollowCountButton;
- (void)didClickFollowButton;
- (void)didClickChatButton;
- (void)didClickDrawToButton;
- (void)didClickAvatar;
- (void)didClickCustomBackground;
- (void)didclickBlack;
- (void)didclickManage;
- (void)didClickBBSPost;

- (void)didclickSina;
- (void)didclickQQ;
- (void)didclickFacebook;
- (void)didClickTabAtIndex:(int)index;
- (void)didClickMore;
- (void)didClickDrawFeed:(DrawFeed *)drawFeed;
- (void)didClickUserActionButtonAtIndex:(NSInteger)index;
@end

@interface UserDetailCell : PPTableViewCell <AvatarViewDelegate, CustomSegmentedControlDelegate, FeedCarouselProtocol>

{
    ChangeAvatar *imageUploader;
}
@property (retain, nonatomic) IBOutlet UIControl *customBackgroundControl;

@property (retain, nonatomic) IBOutlet UIView *feedTabHolder;
//@property (retain, nonatomic) IBOutlet UILabel *followCountLabel;
//@property (retain, nonatomic) IBOutlet UILabel *fanCountLabel;
@property (retain, nonatomic) IBOutlet UIImageView *genderImageView;
@property (retain, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *signLabel;
//@property (retain, nonatomic) IBOutlet UILabel *levelLabel;
@property (retain, nonatomic) IBOutlet UILabel *birthLabel;
@property (retain, nonatomic) IBOutlet UILabel *zodiacLabel;
@property (retain, nonatomic) IBOutlet UILabel *bloodTypeLabel;
@property (retain, nonatomic) IBOutlet UIImageView *customBackgroundImageView;
@property (retain, nonatomic) IBOutlet UILabel *locationLabel;
@property (retain, nonatomic) IBOutlet UIView *avatarHolderView;
@property (retain, nonatomic) AvatarView *avatarView;
@property (retain, nonatomic) IBOutlet UIView *basicDetailView;
//@property (retain, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (retain, nonatomic) IBOutlet UIButton *editButton;
@property (retain, nonatomic) IBOutlet UserDetailRoundButton *drawToButton;
@property (retain, nonatomic) IBOutlet UserDetailRoundButton *chatButton;
@property (retain, nonatomic) IBOutlet UserDetailRoundButton *followButton;
@property (retain, nonatomic) IBOutlet UserDetailRoundButton *fanCountButton;
@property (retain, nonatomic) IBOutlet UserDetailRoundButton *followCountButton;
@property (assign, nonatomic) id<UserDetailCellDelegate> detailDelegate;
@property (retain, nonatomic) IBOutlet UIButton *sinaBtn;
@property (retain, nonatomic) IBOutlet UIButton *qqBtn;
@property (retain, nonatomic) IBOutlet UIButton *facebookBtn;
@property (retain, nonatomic) IBOutlet UIButton *blackListBtn;
@property (retain, nonatomic) IBOutlet UIButton *superBlackBtn;
@property (retain, nonatomic) IBOutlet LocalizableLabel *noSNSTipsLabel;
@property (retain, nonatomic) IBOutlet LocalizableLabel *specialTitleLabel;
@property (retain, nonatomic) IBOutlet UIButton *exploreBbsPostBtn;
@property (retain, nonatomic) IBOutlet UIImageView *seperator1;
@property (retain, nonatomic) IBOutlet UIImageView *seperator2;
@property (retain, nonatomic) IBOutlet UIImageView *seperator3;
@property (retain, nonatomic) IBOutlet LocalizableLabel *hisOpusLabel;
@property (retain, nonatomic) IBOutlet LocalizableLabel *snsTipLabel;
//@property (retain, nonatomic) IBOutlet UILabel *xiaojiLabel;
@property (retain, nonatomic) IBOutlet UIButton *signButton;
@property (retain, nonatomic) IBOutlet BadgeView *badgeView;
@property (retain, nonatomic) IBOutlet UIImageView *vipFlag;

@property (retain, nonatomic) IBOutlet UIButton *bgButton;
@property (retain, nonatomic) IBOutlet BadgeView *bgBadgeView;
@property (retain, nonatomic) IBOutlet UILabel *groupName;
@property (retain, nonatomic) IBOutlet UIButton *inviteMemberButton;
@property (retain, nonatomic) IBOutlet UIButton *inviteGuestButton;
@property (retain, nonatomic) IBOutlet GroupIconView *groupIcon;
@property (retain, nonatomic) IBOutlet LocalizableLabel *groupHeader;

@property (retain, nonatomic) IBOutlet UIImageView *seperator5;
@property (retain, nonatomic) IBOutlet UIButton *pullDownButton;
@property (retain, nonatomic) IBOutlet UIButton *opusShowButton;

- (IBAction)inviteMember:(id)sender;
- (IBAction)inviteGuest:(id)sender;

- (void)setCellWithUserDetail:(NSObject<UserDetailProtocol> *)detail;
- (void)setDrawFeedList:(NSArray*)feedList tipText:(NSString *)tipText;
- (void)clearDrawFeedList;

- (void)setIsLoadingFeed:(BOOL)isLoading;
- (IBAction)clickBBSPost:(id)sender;
- (IBAction)clickSetHomeBg:(id)sender;

@end
