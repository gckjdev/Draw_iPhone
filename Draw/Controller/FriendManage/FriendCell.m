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
#import "DeviceDetection.h"
#import "Friend.h"
#import "Room.h"
#import "LogUtil.h"

@implementation FriendCell
@synthesize avatarView;
@synthesize nickNameLabel;
@synthesize genderLabel;
@synthesize areaLabel;
@synthesize authImageView;
@synthesize statusLabel;
@synthesize followButton;
@synthesize user = _user;
@synthesize followDelegate;
@synthesize levelLabel = _levelLabel;
//@synthesize inviteDelegate;

- (void)dealloc {
    [avatarView release];
    [nickNameLabel release];
    [genderLabel release];
    [areaLabel release];
    [authImageView release];
    [statusLabel release];
    [followButton release];
    [_user release];
    [_levelLabel release];
    [super dealloc];
}


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
        PPDebug(@"create %@ but cannot find cell object from Nib", cellId);
        return nil;
    }
    
    ((PPTableViewCell*)[topLevelObjects objectAtIndex:0]).delegate = delegate;
    
    return [topLevelObjects objectAtIndex:0];
}


+ (NSString*)getCellIdentifier
{
    return @"FriendCell";
}


#define CELL_HEIGHT_IPHONE  66
#define CELL_HEIGHT_IPAD    132
+ (CGFloat)getCellHeight
{
    if ([DeviceDetection isIPAD]) {
        return CELL_HEIGHT_IPAD;
    }else {
        return CELL_HEIGHT_IPHONE;
    }
}


- (void)setCellByDictionary:(NSDictionary *)aUser indexPath:(NSIndexPath *)aIndexPath
{
    self.user = aUser;
    self.indexPath = aIndexPath;
    
    NSString* userId = [aUser objectForKey:PARA_USERID];
    NSString* avatar = [aUser objectForKey:PARA_AVATAR];
    NSString* gender = [aUser objectForKey:PARA_GENDER];
    NSString* nickName = [aUser objectForKey:PARA_NICKNAME];
    NSString* sinaNick = [aUser objectForKey:PARA_SINA_NICKNAME];
    NSString* qqNick = [aUser objectForKey:PARA_QQ_NICKNAME];
    NSString* facebookNick = [aUser objectForKey:PARA_FACEBOOK_NICKNAME];
    NSString* location = [aUser objectForKey:PARA_LOCATION];
    
    //set avatar
    [avatarView clear];
    if ([gender isEqualToString:MALE])
    {
        [avatarView setImage:[[ShareImageManager defaultManager] maleDefaultAvatarImage]];
    }else {
        [avatarView setImage:[[ShareImageManager defaultManager] femaleDefaultAvatarImage]];
    }
    if ([avatar length] > 0) {
        [avatarView setUrl:[NSURL URLWithString:avatar]];
        [GlobalGetImageCache() manage:avatarView];
    }
    
    
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
        genderLabel.text = NSLS(@"kMale");
    }else {
        genderLabel.hidden = NO;
        genderLabel.text = NSLS(@"kFemale");
    }
    
    //set area label
    areaLabel.text = location;
    
    
    //set 
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    if (sinaNick) {
        authImageView.hidden = NO;
        [authImageView setImage:[imageManager sinaWeiboImage]];
    }else if (qqNick){
        authImageView.hidden = NO;
        [authImageView setImage:[imageManager qqWeiboImage]];
    }else if (facebookNick){
        authImageView.hidden = NO;
        [authImageView setImage:[imageManager facebookImage]];
    }else {
        authImageView.hidden = YES;
    }
    
    
     //set followbutton or statusLabel
    [followButton setBackgroundImage:[[ShareImageManager defaultManager] normalButtonImage] forState:UIControlStateNormal];
    [followButton setTitle:NSLS(@"kAddAsFriend") forState:UIControlStateNormal];
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
}


- (void)setCellWithFriend:(Friend *)aFriend indexPath:(NSIndexPath *)aIndexPath fromType:(FromType)type
{
    if (type == FromFriendList) {
        [self setCellByFriend:aFriend indexPath:aIndexPath];
    }else if(type == FromInviteList)
    {
        [self setCellByFriend:aFriend indexPath:aIndexPath];
//        [followButton setBackgroundImage:
//         [[ShareImageManager defaultManager] normalButtonImage] 
//                                forState:UIControlStateNormal];
    }
}

- (void)setCellByFriend:(Friend *)aFriend indexPath:(NSIndexPath *)aIndexPath
{
    self.indexPath = aIndexPath;
    [self.levelLabel setText:[NSString stringWithFormat:@"%d",aFriend.level.intValue]];
    
    //set avatar
    if ([aFriend.gender isEqualToString:MALE])
    {
        [avatarView setImage:[[ShareImageManager defaultManager] maleDefaultAvatarImage]];
    }else {
        [avatarView setImage:[[ShareImageManager defaultManager] femaleDefaultAvatarImage]];
    }
    if ([aFriend.avatar length] > 0) {
        [avatarView setUrl:[NSURL URLWithString:aFriend.avatar]];
        [GlobalGetImageCache() manage:avatarView];
    }
    
    
    //set nick
    nickNameLabel.text = @"";
    if (aFriend.nickName && [aFriend.nickName length] != 0) {
        nickNameLabel.text = aFriend.nickName;
    }
    else if (aFriend.sinaNick && [aFriend.sinaNick length] != 0){
        nickNameLabel.text = aFriend.sinaNick;
    }
    else if (aFriend.qqNick && [aFriend.qqNick length] != 0){
        nickNameLabel.text = aFriend.qqNick;
    }
    else if (aFriend.facebookNick && [aFriend.facebookNick length] != 0){
        nickNameLabel.text = aFriend.facebookNick;
    }
    
    //set gender
    if ([aFriend.gender isEqualToString:MALE]) {
        genderLabel.hidden = NO;
        genderLabel.text = NSLS(@"kMale");
    }else {
        genderLabel.hidden = NO;
        genderLabel.text = NSLS(@"kFemale");
    }
    
    //set area label
    areaLabel.text = aFriend.location;
    
    
    //set auth
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    if (aFriend.sinaNick) {
        authImageView.hidden = NO;
        [authImageView setImage:[imageManager sinaWeiboImage]];
    }else if (aFriend.qqNick){
        authImageView.hidden = NO;
        [authImageView setImage:[imageManager qqWeiboImage]];
    }else if (aFriend.facebookNick){
        authImageView.hidden = NO;
        [authImageView setImage:[imageManager facebookImage]];
    }else {
        authImageView.hidden = YES;
    }
    
    
    //hide followbutton and statusLabel
    statusLabel.hidden = YES;
    followButton.hidden = YES;
    if ([[FriendManager defaultManager] isFanFriend:aFriend.friendUserId]) {
        
        [followButton setBackgroundImage:[[ShareImageManager defaultManager] normalButtonImage] forState:UIControlStateNormal];
        [followButton setTitle:NSLS(@"kAddAsFriend") forState:UIControlStateNormal];
        
        if (![[FriendManager defaultManager] isFollowFriend:aFriend.friendUserId]) {
            followButton.hidden = NO;
        }
    }
}



- (IBAction)clickFollowButton:(id)sender
{
    if (followDelegate && [followDelegate respondsToSelector:@selector(didClickFollowButtonAtIndexPath:user:)]) {
        PPDebug(@"%d",[self.indexPath row]);
        [followDelegate didClickFollowButtonAtIndexPath:self.indexPath 
                                                   user:self.user];
    }
    
//    if (inviteDelegate && [inviteDelegate respondsToSelector:@selector(didInviteFriendAtIndexPath:)]) {
//        [inviteDelegate didInviteFriendAtIndexPath:self.indexPath];
//    }
}

@end
