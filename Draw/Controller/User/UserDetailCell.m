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
    [self.levelLabel setText:[NSString stringWithFormat:@"lv.%d",pbUser.level]];
    [self.nickNameLabel setText:pbUser.nickName];
    [self.signLabel setText:pbUser.signature];
    [self.locationLabel setText:[NSString stringWithFormat:@"%@:%@", NSLS(@"kLocation"), pbUser.location]];
    [self.birthLabel setText:[NSString stringWithFormat:@"%@:%@", NSLS(@"kBirthday"), pbUser.birthday]];
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
    
    [self.genderImageView setImage:[[ShareImageManager defaultManager] userDetailGenderImage:[pbUser gender]]];
    
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
    return (UserDetailCell*)[super createCell:delegate];
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

@end
