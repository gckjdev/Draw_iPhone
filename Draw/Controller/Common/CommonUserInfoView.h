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
@class PPViewController;
@class Friend;

@interface CommonUserInfoView : UIView<FriendServiceDelegate, UserServiceDelegate>

+ (void)showUser:(Friend*)afriend 
      infoInView:(UIViewController*)superController;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImageView;
+ (void)showUser:(NSString*)userId 
        nickName:(NSString*)nickName 
          avatar:(NSString*)avatar 
          gender:(NSString*)aGender 
        location:(NSString*)location 
           level:(int)level
         hasSina:(BOOL)didHasSina 
           hasQQ:(BOOL)didHasQQ 
     hasFacebook:(BOOL)didHasFacebook
      infoInView:(PPViewController*)superController;
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
@property (retain, nonatomic) Friend* targetFriend;
@property (retain, nonatomic) NSString* userId;
@property (retain, nonatomic) NSString* userAvatar;
@property (retain, nonatomic) NSString* userNickName;
@property (retain, nonatomic) NSString* userLocation;
@property (retain, nonatomic) NSString* userGender;
@property (assign, nonatomic) BOOL hasSina;
@property (assign, nonatomic) BOOL hasQQ;
@property (assign, nonatomic) BOOL hasFacebook;
@property (assign, nonatomic) int userLevel;
@property (retain, nonatomic) IBOutlet UILabel *levelLabel;
@property (retain, nonatomic) PPViewController* superViewController;

@end
