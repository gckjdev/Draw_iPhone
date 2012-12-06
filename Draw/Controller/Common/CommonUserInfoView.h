//
//  CommonUserInfoView.h
//  Draw
//
//  Created by Orange on 12-6-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendService.h"
#import "UserService.h"
#import "CommonInfoView.h"
@class PPViewController;
@class MyFriend;

@interface CommonUserInfoView : CommonInfoView<FriendServiceDelegate, UserServiceDelegate>
{
    MyFriend* _targetFriend;
    PPViewController*   _superViewController;
}

@property (retain, nonatomic) IBOutlet UIButton *mask;
@property (retain, nonatomic) IBOutlet UILabel *userName;
@property (retain, nonatomic) IBOutlet UIImageView *snsTagImageView;
@property (retain, nonatomic) IBOutlet UILabel *genderLabel;
@property (retain, nonatomic) IBOutlet UILabel *locationLabel;
@property (retain, nonatomic) IBOutlet UIButton *chatToUserButton;
@property (retain, nonatomic) IBOutlet UIButton *followUserButton;
@property (retain, nonatomic) IBOutlet UILabel *statusLabel;
@property (retain, nonatomic) IBOutlet UILabel *levelLabel;
@property (retain, nonatomic) IBOutlet UIImageView *genderImageView;
@property (retain, nonatomic) IBOutlet UIView *avatarHolderView;

@property (retain, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (retain, nonatomic) IBOutlet UILabel *coinsLabel;

//use MyFriend as the model
@property (retain, nonatomic) MyFriend* targetFriend;

+ (void)showFriend:(MyFriend*)afriend
        infoInView:(UIViewController*)superController
        needUpdate:(BOOL)needUpdate; //if need update the info from service.
- (void)initView;//

@end
