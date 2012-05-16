//
//  RoomCell.m
//  Draw
//
//  Created by  on 12-5-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RoomCell.h"
#import "HJManagedImageV.h"
#import "PPApplication.h"
#import "ShareImageManager.h"
#import "StableView.h"
#import "RoomManager.h"

@implementation RoomCell
@synthesize avatarImage;
@synthesize roomNameLabel;
@synthesize roomStatusLabel;
@synthesize creatorLabel;
@synthesize userListLabel;
@synthesize inviteInfoButton;
@synthesize inviteButton;


#define AVATAR_FRAME CGRectMake(18, 3, 36, 37)
+ (id)createCell:(id)delegate
{
    NSString* cellId = [self getCellIdentifier];
    //    NSLog(@"cellId = %@", cellId);
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).  
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create %@ but cannot find cell object from Nib", cellId);
        return nil;
    }
    
    RoomCell *cell = ((RoomCell*)[topLevelObjects objectAtIndex:0]);
    cell.delegate = delegate;

    
    cell.avatarImage = [[[AvatarView alloc] initWithUrlString:nil frame:AVATAR_FRAME gender:YES] autorelease];
    [cell addSubview:cell.avatarImage];
    
    return cell;
}

+ (NSString*)getCellIdentifier
{
    return @"RoomCell";
}

+ (CGFloat)getCellHeight
{
    return 65.0f;
}


- (void)setStatus:(RoomStatus)status
{
    NSString *text;
    UIColor *color;
    switch (status) {
        case RoomFull:
            text = NSLS(@"kFull");
            color = [UIColor redColor];
            break;
        case RoomPlaying:
            text = NSLS(@"kPlaying");
            color = [UIColor orangeColor];
            break;
        case RoomWaitting:
        default:
            text = NSLS(@"kWaitting");
            color = [UIColor greenColor];
            break;
    }
    [self.roomStatusLabel setText:[NSString stringWithFormat:@"[%@]",text]];
    [self.roomStatusLabel setTextColor:color];
}

- (void)setAvatar:(RoomUser *)user
{
    NSString *avatar = user.avatar;
    BOOL gender = ![user isFemale];
    [avatarImage setAvatarUrl:avatar gender:gender];
    [avatarImage setAvatarSelected:YES];
    avatarImage.hidden = NO;
    
    [self.creatorLabel setText:user.nickName];
    [self.creatorLabel setHidden:NO];
}


- (void)setInviteInfo:(Room *)room
{
    self.inviteButton.hidden = YES;
    self.inviteInfoButton.hidden = YES;
    if ([room isMeCreator]) {
        self.inviteButton.hidden = NO;
    }else if(room.myStatus == UserInvited)
    {
        self.inviteInfoButton.hidden = NO;
    }
}


#define USER_LIST_COUNT 3

- (void)setUserListInfo:(Room *)room
{
    NSArray *array = [room playingUserList];
    RoomUserStatus stat = UserPlaying;
    if ([array count] == 0) {
        array = [room joinedUserList];
        stat = UserJoined;
    }
    if ([array count] == 0) {
        array = [room invitedUserList];
        stat = UserInvited;
    }
    self.userListLabel.hidden = YES;
    if ([array count] != 0) {
        //join the string.
        NSString *listString = [[RoomManager defaultManager] 
                                nickStringFromUsers:array 
                                split:@"," 
                                count:USER_LIST_COUNT];
        if ([listString length] == 0) {
            return;
        }
        self.userListLabel.hidden = NO;
        switch (stat) {
            case UserPlaying:
                listString = [NSString stringWithFormat:@"%@ %@",listString, NSLS(@"kIsPlaying")];
                break;
            case UserJoined:
                listString = [NSString stringWithFormat:@"%@ %@",listString, NSLS(@"kIsJoined")];
                break;
                
            case UserInvited:
            default:
                listString = [NSString stringWithFormat:@"%@ %@",listString, NSLS(@"kIsInvited")];
                break;
        }
        [self.userListLabel setText:listString];
    }
    
}

- (IBAction)clickInviteButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didClickInvite:)]) {
        [self.delegate didClickInvite:self.indexPath];
    }
}

- (void)setInfo:(Room *)room
{
    //set room name
    [self.roomNameLabel setText:room.roomName];
    //set avatar image
    [self setAvatar:room.creator];
    //set status
    [self setStatus:room.status];
    //setInviteInfo
    [self setInviteInfo:room];
    //set user list
    [self setUserListInfo:room];
    
}
- (void)dealloc {
    [avatarImage release];
    [roomNameLabel release];
    [roomStatusLabel release];
    [creatorLabel release];
    [userListLabel release];
    [inviteInfoButton release];
    [inviteButton release];
    [super dealloc];
}
@end
