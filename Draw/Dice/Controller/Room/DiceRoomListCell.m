//
//  RoomListCell.m
//  Draw
//
//  Created by 小涛 王 on 12-7-27.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceRoomListCell.h"
#import "GameBasic.pb.h"

#define TAG_USER_VIEW 101

@interface DiceRoomListCell ()

@end

@implementation DiceRoomListCell
@synthesize roomNameLabel;

+ (NSString *)getCellIdentifier
{
    return @"DiceRoomListCell";
}

+ (CGFloat)getCellHeight
{
    return 205;
}

- (void)setCellInfo:(PBGameSession *)session
{
    roomNameLabel.text = session.name;
    
    
}

- (void)dealloc {
    [roomNameLabel release];
    [super dealloc];
}
@end
