//
//  RoomListCell.m
//  Draw
//
//  Created by 小涛 王 on 12-7-27.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceRoomListCell.h"
#import "GameBasic.pb.h"
#import "DiceAvatarView.h"
#import "DiceImageManager.h"
#import "PPDebug.h"

#define TAG_USER_VIEW 101

@interface DiceRoomListCell ()

@end

@implementation DiceRoomListCell
@synthesize backgroundImageView;
@synthesize roomNameLabel;

+ (NSString *)getCellIdentifier
{
    return @"DiceRoomListCell";
}

+ (CGFloat)getCellHeight
{
    return 102;
}

- (void)setCellInfo:(PBGameSession *)session
{
    roomNameLabel.text = session.name;
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
    PPDebug(@"<test>get a room, name=%@, user count = %d",session.name, session.usersList.count);
}

- (void)dealloc {
    [roomNameLabel release];
    [backgroundImageView release];
    [super dealloc];
}

    
@end
