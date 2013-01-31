//
//  DiceUserInfoView.h
//  Draw
//
//  Created by Orange on 12-8-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendService.h"
#import "UserService.h"
#import "CommonInfoView.h"
#import "MyFriend.h"

@class FontButton;
@class DiceAvatarView;
@class PBGameUser;
@class PPViewController;

@interface DiceUserInfoView : CommonInfoView<FriendServiceDelegate, UserServiceDelegate>
{
    MyFriend *targetFriend;
}

+ (void)showFriend:(MyFriend*)afriend 
        infoInView:(PPViewController*)superController 
           canChat:(BOOL)canChat
        needUpdate:(BOOL)needUpdate; //if need update the info from service.

+ (void)showUser:(PBGameUser*)aUser 
        infoInView:(PPViewController*)superController 
           canChat:(BOOL)canChat
        needUpdate:(BOOL)needUpdate; //if need update the info from service.


@property (retain, nonatomic) IBOutlet UILabel *coinsLabel;
@property (retain, nonatomic) IBOutlet UIImageView *genderImageView;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (retain, nonatomic) IBOutlet UIButton *mask;
@property (retain, nonatomic) IBOutlet UILabel *userName;
@property (retain, nonatomic) IBOutlet UIImageView *snsTagImageView;
@property (retain, nonatomic) IBOutlet UILabel *genderLabel;
@property (retain, nonatomic) IBOutlet UILabel *locationLabel;
@property (retain, nonatomic) IBOutlet UIButton *followUserButton;
@property (retain, nonatomic) IBOutlet UILabel *statusLabel;
@property (retain, nonatomic) IBOutlet UILabel *levelLabel;
@property (retain, nonatomic) IBOutlet DiceAvatarView *avatar;
@property (retain, nonatomic) IBOutlet UIButton *chatButton;

@property (retain, nonatomic) MyFriend* targetFriend;
@property (assign, nonatomic) PPViewController* superViewController;
//@property (assign, nonatomic) long coins;

@end
