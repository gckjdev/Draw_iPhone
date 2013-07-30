//
//  FriendCell.m
//  Draw
//
//  Created by haodong qiu on 12年5月14日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "FriendCell.h"
//#import "HJManagedImageV.h"
#import "GameNetworkConstants.h"
#import "ShareImageManager.h"
#import "FriendManager.h"
#import "PPApplication.h"
#import "DeviceDetection.h"
#import "Friend.h"
#import "Room.h"
#import "LogUtil.h"
#import "MyFriend.h"
#import "UIImageView+Extend.h"

@implementation FriendCell
@synthesize avatarView;
@synthesize nickNameLabel;
@synthesize genderLabel;
@synthesize areaLabel;

@synthesize statusLabel;
@synthesize followDelegate;
@synthesize levelLabel = _levelLabel;
@synthesize myFriend = _myFriend;
//@synthesize inviteDelegate;

- (void)dealloc {
    PPRelease(avatarView);
    PPRelease(nickNameLabel);
    PPRelease(genderLabel);
    PPRelease(areaLabel);
    PPRelease(statusLabel);
    PPRelease(_levelLabel);
    PPRelease(_myFriend);
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
    
    FriendCell *cell = (FriendCell*)[topLevelObjects objectAtIndex:0];
    cell.delegate = delegate;
    
    
    return cell;
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




- (void)updateAvatar:(MyFriend *)aFriend
{
    UIImage *defaultImage = nil;
    if (aFriend.isMale) {
        defaultImage = [[ShareImageManager defaultManager] maleDefaultAvatarImage];
    }else{
        defaultImage = [[ShareImageManager defaultManager] femaleDefaultAvatarImage];
    }
    
    NSURL *url = [NSURL URLWithString:aFriend.avatar];
    [self.avatarView setImageWithUrl:url placeholderImage:defaultImage showLoading:YES animated:YES];
}


- (void)updateGender:(MyFriend *)aFriend
{
    genderLabel.hidden = NO;
    genderLabel.text = aFriend.isMale ? NSLS(@"kMale") : NSLS(@"kFemale");
}


#define AUTH_TAG_START 100
#define AUTH_TAG_END 102
- (void)updateAuthImageView:(MyFriend *)aFriend
{
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    int tag = AUTH_TAG_START;
    
    if (aFriend.isSinaUser) {
        UIImageView *imageView = (UIImageView *)[self viewWithTag:tag ++];
        imageView.hidden = NO;
        [imageView setImage:[imageManager sinaWeiboImage]];
    }
    if (aFriend.isQQUser){
        UIImageView *imageView = (UIImageView *)[self viewWithTag:tag ++];
        imageView.hidden = NO;
        [imageView setImage:[imageManager qqWeiboImage]];
    }
    if (aFriend.isFacebookUser){
        UIImageView *imageView = (UIImageView *)[self viewWithTag:tag ++];
        imageView.hidden = NO;
        [imageView setImage:[imageManager facebookImage]];
    }
    //hide the left auth images
    while (tag <= AUTH_TAG_END) {
        [self viewWithTag:tag ++].hidden = YES;
    }
}


- (void)updateStatusLabel:(NSString *)text
{
    if (text.length != 0) {
        statusLabel.hidden = NO;
        [statusLabel setText:text];
    }else{
        statusLabel.hidden = YES;
    }    
}
- (void)setCellWithMyFriend:(MyFriend *)aFriend
                  indexPath:(NSIndexPath *)aIndexPath 
                 statusText:(NSString *)statusText
{
    self.myFriend = aFriend;
    self.indexPath = aIndexPath;


    //set avatar
    [self updateAvatar:aFriend];    
    
    //set gender 
    [self updateGender:aFriend];
    
    //set nick
    nickNameLabel.text = aFriend.friendNick;
    
    //set area label
    areaLabel.text = aFriend.location;
    
    //set level
    [_levelLabel setText:[NSString stringWithFormat:@"LV:%d",aFriend.level]];
    
    [self updateAuthImageView:aFriend];
    
    [self updateStatusLabel:statusText];
}




@end
