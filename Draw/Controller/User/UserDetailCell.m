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

@implementation UserDetailCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setCellWithPBGameUser:(PBGameUser *)pbUser
{
    [self.levelLabel setText:[NSString stringWithFormat:@"LV.%d",pbUser.level]];
    [self.nickNameLabel setText:pbUser.nickName];
    [self.locationLabel setText:pbUser.location];
    [self.birthLabel setText:pbUser.birthday];
    [self.zodiacLabel setText:pbUser.zodiac];

    [self.avatarView setAvatarUrl:pbUser.avatar gender:pbUser.gender];
    
    
}

+ (float)getCellHeight
{
    return ([DeviceDetection isIPAD]?1600:800);
}

+ (NSString*)getCellIdentifier
{
    return @"UserDetailCell";
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
    [super dealloc];
}
@end
