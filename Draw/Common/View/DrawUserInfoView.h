//
//  Draw
//
//  Created by Orange on 12-6-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendService.h"
#import "UserService.h"
#import "MWPhotoBrowser.h"
#import "StableView.h"

@class PPViewController;
@class MyFriend;
@class PBBBSUser;

@interface DrawUserInfoView : UIView<FriendServiceDelegate, UserServiceDelegate,MWPhotoBrowserDelegate, AvatarViewDelegate>
{
    MyFriend* targetFriend;
}

+ (void)showFriend:(MyFriend*)afriend 
        infoInView:(UIViewController*)superController
        needUpdate:(BOOL)needUpdate; //if need update the info from service.
+ (void)showPBBBSUser:(PBBBSUser*)user
           infoInView:(PPViewController*)superController
           needUpdate:(BOOL)needUpdate;
@property (retain, nonatomic) IBOutlet UIButton *superUserManageButton;
@property (retain, nonatomic) IBOutlet UIButton *blackFriendButton;

@property (retain, nonatomic) IBOutlet UIButton *mask;
@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (retain, nonatomic) IBOutlet UILabel *userName;
@property (retain, nonatomic) IBOutlet UIImageView *snsTagImageView;
@property (retain, nonatomic) IBOutlet UILabel *genderLabel;
@property (retain, nonatomic) IBOutlet UILabel *locationLabel;
@property (retain, nonatomic) IBOutlet UILabel *playWithUserLabel;
@property (retain, nonatomic) IBOutlet UILabel *chatToUserLabel;
@property (retain, nonatomic) IBOutlet UIButton *drawToUserButton;
@property (retain, nonatomic) IBOutlet UIButton *exploreUserFeedButton;
@property (retain, nonatomic) IBOutlet UIButton *chatToUserButton;
@property (retain, nonatomic) IBOutlet UIButton *followUserButton;
@property (retain, nonatomic) IBOutlet UILabel *statusLabel;
@property (retain, nonatomic) IBOutlet UILabel *levelLabel;

@property (assign, nonatomic) PPViewController* superViewController;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImageView;

//use MyFriend as the model
@property (retain, nonatomic) MyFriend* targetFriend;

@end
