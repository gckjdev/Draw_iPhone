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

@implementation RoomCell
@synthesize avatarImage;
@synthesize roomNameLabel;
@synthesize roomStatusLabel;

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
    
    ((PPTableViewCell*)[topLevelObjects objectAtIndex:0]).delegate = delegate;
    
    return [topLevelObjects objectAtIndex:0];
}

+ (NSString*)getCellIdentifier
{
    return @"RoomCell";
}

+ (CGFloat)getCellHeight
{
    return 44.0f;
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
    [self.roomStatusLabel setText:text];
    [self.roomStatusLabel setTextColor:color];
}

- (void)setAvatar:(RoomUser *)user
{
    [self.avatarImage clear];
    
    NSString *avatar = user.avatar;
    avatarImage.hidden = NO;
    
    BOOL isFemale = [user isFemale];
    if (!isFemale)
        [avatarImage setImage:[[ShareImageManager defaultManager] maleDefaultAvatarImage]];
    else
        [avatarImage setImage:[[ShareImageManager defaultManager] femaleDefaultAvatarImage]];
    
    if ([avatar length] > 0){     
        // set URL for download avatar
        [self.avatarImage setUrl:[NSURL URLWithString:avatar]];
        
    }else{
        if ([user isMe]){
            [avatarImage setImage:[[UserManager defaultManager] avatarImage]];
        }
    }
    [GlobalGetImageCache() manage:avatarImage];

}


- (void)setInfo:(Room *)room
{
    //set room name
    [self.roomNameLabel setText:room.roomName];
    //set avatar image
    [self setAvatar:room.creator];
    //set status
    [self setStatus:room.status];
    
}
- (void)dealloc {
    [avatarImage release];
    [roomNameLabel release];
    [roomStatusLabel release];
    [super dealloc];
}
@end
