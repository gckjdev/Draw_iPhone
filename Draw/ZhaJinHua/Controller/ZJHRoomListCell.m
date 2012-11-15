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
    return @"ZJHRoomListCell";
}

#define HEIGHT_ZJH_ROOM_LIST_CELL  ([DeviceDetection isIPAD] ? 204: 102)

+ (CGFloat)getCellHeight
{
    return HEIGHT_ZJH_ROOM_LIST_CELL;
}

- (void)setCellInfo:(PBGameSession *)session;
{
    if (session.name == nil || session.name.length <= 0) {
        [self.roomNameLabel setText:[NSString stringWithFormat:@"%lld",session.sessionId]];
    } else {
        [self.roomNameLabel setText:session.name];
    }
    [self.backgroundImageView setImage:[DiceImageManager defaultManager].roomCellBackgroundImage];
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

- (void)dealloc {
    [_roomNameLabel release];
    [_backgroundImageView release];
    [super dealloc];
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
