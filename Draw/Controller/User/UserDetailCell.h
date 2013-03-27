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

typedef enum {
    DetailTabActionClickOpus = 0,
    DetailTabActionClickGuessed ,
    DetailTabActionClickFavouriate,
}DetailTabAction;

@class PBGameUser;
@class CommonRoundAvatarView;

@protocol UserDetailCellDelegate <NSObject>

@optional
- (void)didClickEdit;
- (void)didClickFanCountButton;
- (void)didClickFollowCountButton;
- (void)didClickFollowButton;
- (void)didClickChatButton;
- (void)didClickDrawToButton;
- (void)didClickAvatar;
- (void)didclickBlack;
- (void)didclickManage;

- (void)didclickSina;
- (void)didclickQQ;
- (void)didclickFacebook;
- (void)didSelectTabAction:(DetailTabAction)tabAction;
- (void)didClickMore;
- (void)didClickDrawFeed:(DrawFeed *)drawFeed;
@end

@interface UserDetailCell : PPTableViewCell <CommonRoundAvatarViewDelegate, CustomSegmentedControlDelegate, FeedCarouselProtocol>

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
@property (retain, nonatomic) IBOutlet UILabel *locationLabel;
@property (retain, nonatomic) IBOutlet CommonRoundAvatarView *avatarView;
@property (retain, nonatomic) IBOutlet UIView *basicDetailView;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (retain, nonatomic) IBOutlet UIButton *editButton;
@property (retain, nonatomic) IBOutlet UIButton *drawToButton;
@property (retain, nonatomic) IBOutlet UIButton *chatButton;
@property (retain, nonatomic) IBOutlet UIButton *followButton;
@property (retain, nonatomic) IBOutlet UIButton *fanCountButton;
@property (retain, nonatomic) IBOutlet UIButton *followCountButton;
@property (assign, nonatomic) id<UserDetailCellDelegate> detailDelegate;
@property (retain, nonatomic) IBOutlet UIButton *sinaBtn;
@property (retain, nonatomic) IBOutlet UIButton *qqBtn;
@property (retain, nonatomic) IBOutlet UIButton *facebookBtn;
@property (retain, nonatomic) IBOutlet UIButton *blackListBtn;
@property (retain, nonatomic) IBOutlet UIButton *superBlackBtn;

@property (retain, nonatomic) IBOutlet UIView *feedPlaceHolderView;


- (void)setCellWithUserDetail:(NSObject<UserDetailProtocol> *)detail;
- (void)setDrawFeedList:(NSArray*)feedList;
@end
