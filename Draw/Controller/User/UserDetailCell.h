//
//  UserDetailCell.h
//  Draw
//
//  Created by Kira on 13-3-20.
//
//

#import "PPTableViewCell.h"
#import "UserDetailProtocol.h"

@class PBGameUser;
@class CommonRoundAvatarView;

@protocol UserDetailCellDelegate <NSObject>

- (void)didClickEdit;
- (void)didClickFanCountButton;
- (void)didClickFollowCountButton;
- (void)didClickFollowButton;
- (void)didClickChatButton;
- (void)didClickDrawToButton;

@end

@interface UserDetailCell : PPTableViewCell

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

- (void)setCellWithUserDetail:(NSObject<UserDetailProtocol> *)detail;

@end