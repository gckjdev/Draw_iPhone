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
@class FontButton;
@class DiceAvatarView;
@class PBGameUser;
@class PPViewController;

@interface DiceUserInfoView : CommonInfoView<FriendServiceDelegate, UserServiceDelegate>

+ (void)showUser:(PBGameUser*)aUser 
      infoInView:(PPViewController*)superController;

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
@property (retain, nonatomic) IBOutlet UIImageView *genderImageView;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (retain, nonatomic) IBOutlet UIButton *mask;
@property (retain, nonatomic) IBOutlet UILabel *userName;
@property (retain, nonatomic) IBOutlet UIImageView *snsTagImageView;
@property (retain, nonatomic) IBOutlet UILabel *genderLabel;
@property (retain, nonatomic) IBOutlet UILabel *locationLabel;
@property (retain, nonatomic) IBOutlet FontButton *followUserButton;
@property (retain, nonatomic) IBOutlet UILabel *statusLabel;
@property (retain, nonatomic) PBGameUser* targetFriend;
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
@property (assign, nonatomic) PPViewController* superViewController;
@property (retain, nonatomic) IBOutlet DiceAvatarView *avatar;

@end
