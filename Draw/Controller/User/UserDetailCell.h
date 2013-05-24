//
//  UserDetailCell.h
//  Draw
//
//  Created by Kira on 13-3-20.
//
//

#import "PPTableViewCell.h"
#import "UserDetailProtocol.h"
#import "CommonRoundAvatarView.h"
#import "iCarousel.h"
#import "CustomSegmentedControl.h"
#import "FeedCarousel.h"

@class PBGameUser;
@class CommonRoundAvatarView;
@class LocalizableLabel;
@class PPViewController;
@class UserDetailRoundButton;

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

@interface UserDetailCell : PPTableViewCell <CommonRoundAvatarViewDelegate, CustomSegmentedControlDelegate, FeedCarouselProtocol>
@property (retain, nonatomic) IBOutlet UIControl *customBackgroundControl;

@property (retain, nonatomic) IBOutlet UIView *feedTabHolder;
@property (retain, nonatomic) IBOutlet UILabel *followCountLabel;
@property (retain, nonatomic) IBOutlet UILabel *fanCountLabel;
@property (retain, nonatomic) IBOutlet UIImageView *genderImageView;
@property (retain, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *signLabel;
@property (retain, nonatomic) IBOutlet UILabel *levelLabel;
@property (retain, nonatomic) IBOutlet UILabel *birthLabel;
@property (retain, nonatomic) IBOutlet UILabel *zodiacLabel;
@property (retain, nonatomic) IBOutlet UILabel *bloodTypeLabel;
@property (retain, nonatomic) IBOutlet UIImageView *customBackgroundImageView;
@property (retain, nonatomic) IBOutlet UILabel *locationLabel;
@property (retain, nonatomic) IBOutlet CommonRoundAvatarView *avatarView;
@property (retain, nonatomic) IBOutlet UIView *basicDetailView;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImageView;
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
@property (retain, nonatomic) IBOutlet UIImageView *specialSepLine;
@property (retain, nonatomic) IBOutlet UIButton *exploreBbsPostBtn;

- (void)setCellWithUserDetail:(NSObject<UserDetailProtocol> *)detail;
- (void)setDrawFeedList:(NSArray*)feedList tipText:(NSString *)tipText;
- (void)clearDrawFeedList;

- (void)setIsLoadingFeed:(BOOL)isLoading;

- (IBAction)clickBBSPost:(id)sender;

@end
