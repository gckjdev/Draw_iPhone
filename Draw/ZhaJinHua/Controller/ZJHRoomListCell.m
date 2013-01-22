//
//  ZJHRoomListCell.m
//  Draw
//
//  Created by Kira on 12-11-14.
//
//

#import "ZJHRoomListCell.h"
#import "GameBasic.pb.h"
#import "DiceImageManager.h"
#import "ZJHGameService.h"
#import "PPResourceService.h"

#define TAG_USER_VIEW 101

@implementation ZJHRoomListCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (NSString *)getCellIdentifier
{
    return ([[ZJHGameService defaultService] rule]== PBZJHRuleTypeDual ? @"ZJHRoomListCell_dual" : @"ZJHRoomListCell");
}

#define HEIGHT_ZJH_ROOM_LIST_CELL  ([DeviceDetection isIPAD] ? 204: 102)
#define HEIGHT_ZJH_ROOM_LIST_CELL_DUAL  ([DeviceDetection isIPAD] ? 131: 70)


+ (CGFloat)getCellHeight
{
    return ([[ZJHGameService defaultService] rule]== PBZJHRuleTypeDual ? HEIGHT_ZJH_ROOM_LIST_CELL_DUAL : HEIGHT_ZJH_ROOM_LIST_CELL);
}

- (void)setCellInfo:(PBGameSession *)session roomListTitile:(NSString *)roomListTitile
{
    [super setCellInfo:session];
    self.roomNameLabel.textColor = ([[ZJHGameService defaultService] rule]== PBZJHRuleTypeDual ? [UIColor colorWithRed:107 green:124 blue:126 alpha:1] : [UIColor colorWithRed:209 green:233 blue:219 alpha:1]);
    
    
    if (session.name == nil || session.name.length <= 0) {
        [self.roomNameLabel setText:[roomListTitile stringByAppendingString:[NSString stringWithFormat:NSLS(@"kZJHRoomTitle"), session.sessionId]]];
    } else {
        [self.roomNameLabel setText:session.name];
    }
    
    [self.backgroundImageView setImage:[DiceImageManager defaultManager].roomCellBackgroundImage];
    
    NSString *imageName = ([[ZJHGameService defaultService] rule]== PBZJHRuleTypeDual ?[getGameApp() roomListCellDualBgImageName] : [getGameApp() roomListCellBgImageName]);
    [self.backgroundImageView setImage:[[PPResourceService defaultService] imageByName:imageName inResourcePackage:[getGameApp() resourcesPackage]]];

    for (int i = 0; i < 6; i ++) {
        DiceAvatarView* avatar = (DiceAvatarView*)[self viewWithTag:(i + TAG_USER_VIEW)];
        avatar.delegate = self;
        [avatar setGestureRecognizerEnable:NO];
        [avatar setUrlString:nil userId:nil gender:NO level:0 drunkPoint:0 wealth:0];
    }
    for (int i = 0; i < session.usersList.count; i ++) {
        DiceAvatarView* avatar = (DiceAvatarView*)[self viewWithTag:(i + TAG_USER_VIEW)];
        PBGameUser* user = [session.usersList objectAtIndex:i];
        [avatar setUrlString:user.avatar userId:user.userId gender:user.gender level:user.userLevel drunkPoint:0 wealth:0];
        [avatar setGestureRecognizerEnable:YES];
    }
}

- (void)didClickOnAvatar:(DiceAvatarView *)view
{
    if (delegate && [delegate respondsToSelector:@selector(didQueryUser:)]) {
        [delegate didQueryUser:view.userId];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
