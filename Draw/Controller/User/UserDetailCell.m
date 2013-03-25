//
//  UserDetailCell.m
//  Draw
//
//  Created by Kira on 13-3-20.
//
//

#import "UserDetailCell.h"
#import "GameBasic.pb.h"
#import "CommonRoundAvatarView.h"
#import "ShareImageManager.h"
#import "UserDetailProtocol.h"
#import "UserSettingController.h"
#import "LevelService.h"
#import "GameSNSService.h"
#import "SNSUtils.h"
#import "TimeUtils.h"
#import "PPSNSCommonService.h"
#import "CustomSegmentedControl.h"
#import "ShareImageManager.h"

@interface UserDetailCell ()

@property (retain, nonatomic) CustomSegmentedControl* segmentedControl;

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
    PBGameUser* pbUser = [detail queryUser];
    [self.levelLabel setText:[NSString stringWithFormat:@"lv.%d",[LevelService defaultService].level]];//TODO:level and exp should move to userManager's pbuser, and all info should be got from pbuser. fix it later
    [self.nickNameLabel setText:pbUser.nickName];
    [self.signLabel setText:pbUser.signature];
    [self.locationLabel setText:[NSString stringWithFormat:@"%@:%@", NSLS(@"kLocation"), pbUser.location]];
    NSDate* date = dateFromStringByFormat(pbUser.birthday, @"yyyyMMdd");
    [self.birthLabel setText:[NSString stringWithFormat:@"%@:%@", NSLS(@"kBirthday"), dateToString(date)]];
    [self.zodiacLabel setText:[NSString stringWithFormat:@"%@:%d", NSLS(@"kZodiac"), pbUser.zodiac]];
    [self.bloodTypeLabel setText:[NSString stringWithFormat:@"%@:%@", NSLS(@"kBloodGroup"), pbUser.bloodGroup]];
    [self.followCountLabel setText:[NSString stringWithFormat:@"%d", pbUser.followCount]];
    [self.fanCountLabel setText:[NSString stringWithFormat:@"%d", pbUser.fanCount]];

    [self.avatarView setAvatarUrl:pbUser.avatar gender:pbUser.gender];
    
    self.basicDetailView.hidden = YES;
    
    [self.editButton setHidden:![detail canEdit]];
    [self.followButton setHidden:![detail canFollow]];
    [self.chatButton setHidden:![detail canChat]];
    [self.drawToButton setHidden:![detail canDraw]];
    [self.blackListBtn setHidden:![detail canBlack]];
    [self.superBlackBtn setHidden:![detail canSuperBlack]];
    
    [self.genderImageView setImage:[[ShareImageManager defaultManager] userDetailGenderImage:[pbUser gender]]];
    
    NSArray* snsUserArray = pbUser.snsUsersList;
    [self.sinaBtn setHidden:![SNSUtils hasSNSType:TYPE_SINA inpbSnsUserArray:snsUserArray]];
    [self.qqBtn setHidden:![SNSUtils hasSNSType:TYPE_QQ inpbSnsUserArray:snsUserArray]];
    [self.facebookBtn setHidden:![SNSUtils hasSNSType:TYPE_FACEBOOK inpbSnsUserArray:snsUserArray]];
    
}

+ (float)getCellHeight
{
    return ([DeviceDetection isIPAD]?1600:800);
}

+ (NSString*)getCellIdentifier
{
    return @"UserDetailCell";
}

+ (id)createCell:(id)delegate
{
    UserDetailCell* cell = (UserDetailCell*)[super createCell:delegate];
    cell.avatarView.delegate = cell;
    cell.segmentedControl = [[[CustomSegmentedControl alloc]
                              initWithSegmentTitles:@[NSLS(@"kAll"), NSLS(@"kGuessed"), NSLS(@"kDrawed")]
                              frame:cell.feedTabHolder.frame
                              unpressedImage:[ShareImageManager defaultManager].userDetailTabBgImage
                              pressedImage:[ShareImageManager defaultManager].userDetailTabBgImage
                              delegate:self] autorelease];
    [cell addSubview:cell.segmentedControl];
    [cell.segmentedControl setFrame:cell.feedTabHolder.frame];
    return cell;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    [_nickNameLabel release];
    [_signLabel release];
    [_levelLabel release];
    [_birthLabel release];
    [_zodiacLabel release];
    [_bloodTypeLabel release];
    [_locationLabel release];
    [_avatarView release];
    [_basicDetailView release];
    [_genderImageView release];
    [_backgroundImageView release];
    [_fanCountLabel release];
    [_followCountLabel release];
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
    [super dealloc];
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
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didClickChatButton)]) {
        [_detailDelegate didClickChatButton];
    }
}

- (IBAction)clickDrawToButton:(id)sender
{
    if (_detailDelegate && [_detailDelegate respondsToSelector:@selector(didClickDrawToButton)]) {
        [_detailDelegate didClickDrawToButton];
    }
}

- (void)didClickOnAvatar:(CommonRoundAvatarView*)view
{
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

@end
