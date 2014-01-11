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
#import "GroupUIManager.h"

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
    [_genderImageView release];
    [_groupIcon release];
    [_groupLabel release];
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

- (void)updateView
{
    [self.nickNameLabel setFont:CELL_NICK_FONT];

    genderLabel.font =
    areaLabel.font =
    statusLabel.font =
    _levelLabel.font = CELL_SMALLTEXT_FONT;
}

+ (id)createCell:(id)delegate
{
    NSString* cellId = [self getCellIdentifier];
    
    FriendCell *cell = [self createViewWithXibIdentifier:cellId];
    cell.delegate = delegate;
    
    [cell updateView];
    return cell;
}


+ (NSString*)getCellIdentifier
{
    return @"FriendCell";
}

+ (CGFloat)getCellHeight
{
    return CELL_CONST_HEIGHT;
}




- (void)updateAvatar:(MyFriend *)aFriend
{
//    UIImage *placeHolderImage = [[ShareImageManager defaultManager] avatarImageByGender:aFriend.isMale];
//    NSURL *url = [NSURL URLWithString:aFriend.avatar];
//    [self.avatarView setImageWithUrl:url placeholderImage:placeHolderImage showLoading:YES animated:YES];
    
    [self.avatarView setAvatarUrl:aFriend.avatar gender:aFriend.gender];
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
    if ([aFriend.xiaoji length] > 0){
        [_levelLabel setText:[NSString stringWithFormat:@"%@:%@", NSLS(@"kXiaoji"), aFriend.xiaoji]];
    }
    else{
        [_levelLabel setText:[NSString stringWithFormat:@"LV:%d",aFriend.level]];
    }
    
    [self updateAuthImageView:aFriend];
    
    [self updateStatusLabel:statusText];
    
    self.nickNameLabel.textColor = COLOR_BROWN;
    self.levelLabel.textColor = COLOR_GREEN;
    self.areaLabel.textColor = COLOR_BROWN;
    self.groupLabel.textColor = COLOR_BROWN;
    
    NSString *imageName = aFriend.isMale ? @"user_detail_gender_male@2x.png" : @"user_detail_gender_female@2x.png";
    [self.genderImageView setImage:[UIImage imageNamed:imageName]];
    
    self.groupIcon.hidden = self.groupLabel.hidden = ![aFriend hasGroup];
    if ([aFriend hasGroup]) {
        [self.groupIcon setImageURL:aFriend.groupMedalURL placeholderImage:[GroupUIManager defaultGroupMedal]];
        [self.groupLabel setText:aFriend.groupName];
    }
}




@end
