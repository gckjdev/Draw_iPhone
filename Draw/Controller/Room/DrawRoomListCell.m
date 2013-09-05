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
#import "FXLabel.h"


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

- (void)dealloc
{
    [_roomNameLabel release];
    [super dealloc];
}

+ (NSString *)getCellIdentifier
{
    return @"DrawRoomListCell";
}

#define HEIGHT_DRAW_ROOM_LIST_CELL  ([DeviceDetection isIPAD] ? 245: 102)


+ (CGFloat)getCellHeight
{
    return HEIGHT_DRAW_ROOM_LIST_CELL;
}

- (void)initCell
{
    [self.roomNameLabel setTextColor:[UIColor colorWithRed:62/255.0 green:43/255.0 blue:23/255.0 alpha:1.0]];
    
    self.roomNameLabel.shadowColor = [UIColor whiteColor];
    self.roomNameLabel.shadowOffset = CGSizeZero;
    self.roomNameLabel.shadowBlur = 5.0f;

}

- (void)setCellInfo:(PBGameSession *)session roomListTitile:(NSString *)roomListTitile
{
    [super setCellInfo:session];
    [self initCell];
    
    self.backgroundImageView.layer.borderWidth = (ISIPAD ? 4 : 2);
    self.backgroundImageView.layer.borderColor = [COLOR_YELLOW CGColor];
    SET_VIEW_ROUND_CORNER(self.backgroundImageView);
    
    self.roomNameLabel.textColor = COLOR_BROWN;
    
    if (session.name == nil || session.name.length <= 0) {
        [self.roomNameLabel setText:[roomListTitile stringByAppendingString:[NSString stringWithFormat:NSLS(@"kDrawRoomCellTitle"), session.sessionId]]];
    } else {
        [self.roomNameLabel setText:session.name];
    }

    
    for (int i = 0; i < 6; i ++) {
        
        AvatarView* avatar = (AvatarView*)[self viewWithTag:(i + TAG_USER_VIEW)];
//        [avatar setAsRound];
        avatar.delegate = nil;
        [avatar setUrlString:nil];
        [avatar setUserId:nil];
        [avatar setGender:NO];
        [avatar setHidden:YES];
    }
    for (int i = 0; i < session.usersList.count; i ++) {
        
        AvatarView* avatar = (AvatarView*)[self viewWithTag:(i + TAG_USER_VIEW)];
//        [avatar setAsRound];
        PBGameUser* user = [session.usersList objectAtIndex:i];
        [avatar setUserId:user.userId];
        [avatar setAvatarUrl:user.avatar gender:user.gender];
        avatar.delegate = self;
        [avatar setHidden:NO];
    }
}

- (void)didClickOnAvatar:(NSString *)userId{
    if (delegate && [delegate respondsToSelector:@selector(didQueryUser:)]) {
        [delegate didQueryUser:userId];
    }
}

@end
