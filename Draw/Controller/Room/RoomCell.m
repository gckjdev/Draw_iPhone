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


#define AVATAR_FRAME CGRectMake(15, 12, 57, 55)
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
//    [cell.inviteButton setBackgroundImage:[imageManager normalButtonImage] forState:UIControlStateSelected];
    
    cell.avatarImage = [[[AvatarView alloc] initWithUrlString:nil frame:AVATAR_FRAME gender:YES] autorelease];
    [cell addSubview:cell.avatarImage];
    [cell sendSubviewToBack:cell.avatarImage];
    
    return cell;
}

+ (NSString*)getCellIdentifier
{
    return @"RoomCell";
}

+ (CGFloat)getCellHeight
{
    return 75.0f;
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
    BOOL gender = ![user isFemale];
    [avatarImage setAvatarUrl:avatar gender:gender];
    [avatarImage setAvatarSelected:NO];
    avatarImage.hidden = NO;
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

//    self.userListLabel.hidden = YES;
    if (count!= 0) {
        //join the string.
        NSString *listString = [[RoomManager defaultManager] 
                                nickStringFromUsers:array 
                                split:@", " 
                                count:USER_LIST_COUNT];
        if ([listString length] == 0) {
            return;
        }
        self.userListLabel.hidden = NO;
        NSInteger userCount = MIN(USER_LIST_COUNT, count);
        NSString *dot =  @"...";
        if (userCount == count) {
            dot = @"";
        }
        switch (stat) {
            case RoomFull:
                listString = [NSString stringWithFormat:@"[%@] %d %@(%@%@)",NSLS(@"kFull"),count,NSLS(@"kFriendsPlaying"),listString,dot];
                break;
            case RoomUnFull:
                listString = [NSString stringWithFormat:@"[%@] %d %@(%@%@)",NSLS(@"kUnFull"),count,NSLS(@"kFriendsPlaying"),listString,dot];
                break;
            case RoomFree:
            default:
                listString = [NSString stringWithFormat:@"[%@] %d %@(%@%@)",NSLS(@"kFree"),count,NSLS(@"kFriendsInvited"),listString,dot];
                break;
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

- (void)setInfo:(Room *)room
{
    //set room name
    [self.roomNameLabel setText:room.roomName];
    //set avatar image
    [self setAvatar:room.creator];
    [self setInviteInfo:room];
    //set user list
    [self setUserListInfo:room];
    
    if ([room isMeCreator]) {
        [self setViewsColor:[UIColor grayColor]];
    }else{
        [self setViewsColor:[UIColor brownColor]];
    }
    
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
