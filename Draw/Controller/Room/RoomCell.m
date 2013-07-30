//
//  RoomCell.m
//  Draw
//
//  Created by  on 12-5-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RoomCell.h"
//#import "HJManagedImageV.h"
#import "PPApplication.h"
#import "ShareImageManager.h"
#import "StableView.h"
#import "RoomManager.h"
#import "DeviceDetection.h"
#import "UIManager.h"
#import "UIImageView+Extend.h"

@implementation RoomCell
@synthesize avatarView;
@synthesize roomNameLabel;
@synthesize creatorLabel;
@synthesize userListLabel;
@synthesize inviteInfoButton;
@synthesize inviteButton;
@synthesize roomCellType = _roomCellType;
@synthesize roomCellDelegate;

#define ROOM_CELL_HEIGHT     [DeviceDetection isIPAD] ? 150.0f : 75.0f

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
    
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    [cell.inviteInfoButton setBackgroundImage:[imageManager toolNumberImage] forState:UIButtonTypeCustom];
    [cell.inviteButton setBackgroundImage:[imageManager orangeImage] forState:UIControlStateNormal];
    [cell.inviteButton setTitle:NSLS(@"kInviteFriends") forState:UIControlStateNormal];
    
    return cell;
}

+ (NSString*)getCellIdentifier
{
    return @"RoomCell";
}

+ (CGFloat)getCellHeight
{

    return ROOM_CELL_HEIGHT;
}

- (void)setViewsColor:(UIColor *)color
{
    self.creatorLabel.textColor = color;
    self.userListLabel.textColor = color;
    self.roomNameLabel.textColor = color;
}

- (void)setAvatar:(RoomUser *)user
{
    NSString *avatar = user.avatar;
    BOOL gender = [user isMale];
    
    UIImage* placeHolderImage = nil;
    if (gender) {
        placeHolderImage = [[ShareImageManager defaultManager] maleDefaultAvatarImage];
    }else{
        placeHolderImage = [[ShareImageManager defaultManager] femaleDefaultAvatarImage];
    }
    
    NSURL* url = [NSURL URLWithString:avatar];
    [avatarView setImageWithUrl:url placeholderImage:placeHolderImage showLoading:YES animated:YES];
    
    if ([[UserManager defaultManager] isMe:user.userId]) {
        [self.creatorLabel setText:NSLS(@"Me")];        
    }else{
        [self.creatorLabel setText:user.nickName];
    }
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


#define USER_LIST_COUNT 2

- (NSString *)roomStatusString:(RoomStatus)stat
{
    switch (stat) {
        case RoomFull:
            return NSLS(@"kFull");
        case RoomUnFull:
            return NSLS(@"kUnFull");
        case RoomFree:
        default:
            return NSLS(@"kFree");
    }
}

- (NSString *)playingStringForStat:(RoomStatus)stat
{
    switch (stat) {
        case RoomFull:
        case RoomUnFull:
            return NSLS(@"kFriendsPlaying");
        case RoomFree:
        default:
            return NSLS(@"kFriendsInvited");
    }
}


- (void)setUserListInfo:(Room *)room
{
    NSArray *array = [room playingUserList];
    RoomStatus stat = RoomUnknow;
    NSInteger count = [array count];
    if (count != 0) {
        if (count >= [[RoomManager defaultManager] roomCapacity]){
            count = [[RoomManager defaultManager] roomCapacity];
            stat = RoomFull;
        }else{
            stat = RoomUnFull;            
        }
    }else{
        array = room.userList;
        count = [array count];
        if (count != 0) {
            stat = RoomFree;    
        }
    }
    self.userListLabel.hidden = NO;
    if (count!= 0) {
        //join the string.
        NSString *listString = [[RoomManager defaultManager] 
                                nickStringFromUsers:array 
                                split:@", " 
                                count:USER_LIST_COUNT];
        if ([listString length] == 0) {
            listString = [NSString stringWithFormat:@"[%@] %d %@",[self roomStatusString:stat],count,[self playingStringForStat:stat]];
        }else{
        
            NSInteger userCount = MIN(USER_LIST_COUNT, count);
            NSString *dot =  @"...";
            if (userCount == count) {
                dot = @"";
            }
            listString = [NSString stringWithFormat:@"[%@] %d %@(%@%@)",[self roomStatusString:stat],count,[self playingStringForStat:stat],listString,dot];

        }
        [self.userListLabel setText:listString];

    }else{
        [self.userListLabel setText:NSLS(@"kNoneInvited")];
    }
    
}

- (IBAction)clickInviteButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didClickInvite:)]) {
        [self.delegate didClickInvite:self.indexPath];
    }
}

- (IBAction)clickAvatar:(id)sender
{
    if (roomCellDelegate && [roomCellDelegate respondsToSelector:@selector(didClickAvatar:)]) {
        [roomCellDelegate didClickAvatar:self.indexPath];
    }
}

- (void)view:(UIView *)view setWidth:(CGFloat)width
{
    CGPoint origin = view.frame.origin;
    CGSize size = view.frame.size;
    view.frame = CGRectMake(origin.x, origin.y, width, size.height);
}

- (void)setRoomCellType:(RoomCellType)roomCellType
{
    if (roomCellType == RoomCellTypeSearchRoom) {
        self.inviteInfoButton.hidden = self.inviteButton.hidden = YES;
        [self view:self.roomNameLabel setWidth:self.roomNameLabel.frame.size.width * 1.35];
        [self view:self.creatorLabel setWidth:self.creatorLabel.frame.size.width * 1.35];
    }
    _roomCellType = roomCellType;
}

- (void)setInfo:(Room *)room
{
    
    //set room name
    [self.roomNameLabel setText:room.roomName];
    //set avatar image
    [self setAvatar:room.creator];

    //set user list
    [self setUserListInfo:room];
    
    if ([room isMeCreator]) {
        [self setViewsColor:[UIManager cellTextColor]];
    }else{
        [self setViewsColor:[UIManager cellTextColor]];
    }
    if (self.roomCellType == RoomCellTypeMyRoom) {
        [self setInviteInfo:room];  
    }else{
        self.inviteButton.hidden = self.inviteInfoButton.hidden = YES;
    }
    
}
- (void)dealloc {

    PPRelease(roomNameLabel);
    PPRelease(creatorLabel);
    PPRelease(userListLabel);
    PPRelease(inviteInfoButton);
    PPRelease(inviteButton);
    PPRelease(avatarView);
    [super dealloc];
}
@end
