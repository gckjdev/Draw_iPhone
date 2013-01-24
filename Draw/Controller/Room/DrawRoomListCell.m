//
//  DrawRoomListCell.m
//  Draw
//
//  Created by Kira on 13-1-22.
//
//

#import "DrawRoomListCell.h"
#import "GameBasic.pb.h"
#import "PPResourceService.h"


#define TAG_USER_VIEW 101

@implementation DrawRoomListCell

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
    return @"DrawRoomListCell";
}

#define HEIGHT_DRAW_ROOM_LIST_CELL  ([DeviceDetection isIPAD] ? 204: 102)


+ (CGFloat)getCellHeight
{
    return HEIGHT_DRAW_ROOM_LIST_CELL;
}

- (void)setCellInfo:(PBGameSession *)session roomListTitile:(NSString *)roomListTitile
{
    [super setCellInfo:session];
    
    if (session.name == nil || session.name.length <= 0) {
        [self.roomNameLabel setText:[roomListTitile stringByAppendingString:[NSString stringWithFormat:NSLS(@"kDrawRoomCellTitle"), session.sessionId]]];
    } else {
        [self.roomNameLabel setText:session.name];
    }

    
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
