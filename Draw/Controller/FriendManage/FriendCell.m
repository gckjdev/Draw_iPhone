//
//  FriendCell.m
//  Draw
//
//  Created by haodong qiu on 12年5月14日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "FriendCell.h"
#import "HJManagedImageV.h"
#import "GameNetworkConstants.h"
#import "ShareImageManager.h"
#import "FriendManager.h"
#import "PPApplication.h"

@implementation FriendCell
@synthesize avatarView;
@synthesize nickNameLabel;
@synthesize genderLabel;
@synthesize areaLabel;
@synthesize authImageView;
@synthesize statusLabel;
@synthesize followButton;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (id)createCell:(id)delegate
{
    NSString* cellId = [self getCellIdentifier];
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
    return @"FriendCell";
}

+ (CGFloat)getCellHeight
{
    return 60;
}

- (void)setCellByDictionar:(NSDictionary *)friend
{
    NSString* userId = [friend objectForKey:PARA_USERID];
    NSString* avatar = [friend objectForKey:PARA_AVATAR];
    NSString* gender = [friend objectForKey:PARA_GENDER];
    NSString* nickName = [friend objectForKey:PARA_NICKNAME];
    NSString* sinaNick = [friend objectForKey:PARA_SINA_NICKNAME];
    NSString* qqNick = [friend objectForKey:PARA_QQ_NICKNAME];
    NSString* facebookNick = [friend objectForKey:PARA_FACEBOOK_NICKNAME];
    
    //set avatar
    if ([gender isEqualToString:MALE])
    {
        [avatarView setImage:[[ShareImageManager defaultManager] maleDefaultAvatarImage]];
    }else {
        [avatarView setImage:[[ShareImageManager defaultManager] femaleDefaultAvatarImage]];
    }
    [avatarView setUrl:[NSURL URLWithString:avatar]];
    [GlobalGetImageCache() manage:avatarView];
    
    
    //set nick
    if (nickName && [nickName length] != 0) {
        nickNameLabel.text = nickName;
    }
    else if (sinaNick && [sinaNick length] != 0){
        nickNameLabel.text = sinaNick;
    }
    else if (qqNick && [qqNick length] != 0){
        nickNameLabel.text = qqNick;
    }
    else if (facebookNick && [facebookNick length] != 0){
        nickNameLabel.text = facebookNick;
    }
    
    //set gender
    if ([gender isEqualToString:MALE]) {
        genderLabel.hidden = NO;
        genderLabel.text = NSLS(@"男");
    }else if ([gender isEqualToString:FEMALE]) {
        genderLabel.hidden = NO;
        genderLabel.text = NSLS(@"女");
    }else {
        genderLabel.hidden = YES;
    }
    
    //set area label
    
    
    //set 
    if (sinaNick) {
        authImageView.hidden = NO;
        [authImageView setImage:[UIImage imageNamed:@"sina.png"]];
    }else if (qqNick){
        authImageView.hidden = NO;
        [authImageView setImage:[UIImage imageNamed:@"qq.png"]];
    }else if (facebookNick){
        authImageView.hidden = NO;
        [authImageView setImage:[UIImage imageNamed:@"facebook.png"]];
    }else {
        authImageView.hidden = YES;
    }
    
    
     //set followbutton or statusLabel
    [followButton setTitle:NSLS(@"kAddFriend") forState:UIControlStateNormal];
    if ([[[UserManager defaultManager] userId] isEqualToString:userId]){
        statusLabel.hidden = NO;
        followButton.hidden = YES;
        statusLabel.text = NSLS(@"kMyself");
    }else if ([[FriendManager defaultManager] isFollowFriend:userId]) {
        statusLabel.hidden = NO;
        followButton.hidden = YES;
        statusLabel.text = NSLS(@"kAlreadyBeFriend");
    }
    else {
        statusLabel.hidden = YES;
        followButton.hidden = NO; 
    }
    
    //return cell;
}

- (void)dealloc {
    [avatarView release];
    [nickNameLabel release];
    [genderLabel release];
    [areaLabel release];
    [authImageView release];
    [statusLabel release];
    [followButton release];
    [super dealloc];
}
@end
