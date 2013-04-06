//
//  UserSettingController.h
//  Draw
//
//  Created by  on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTableViewController.h"
#import "ChangeAvatar.h"
#import "InputDialog.h"
#import "UserService.h"
#import "UserManager.h"
#import "CommonDialog.h"
#import "ConfigManager.h"
#import "GeographyService.h"

@class UserManager;
@class HJManagedImageV;
@interface UserSettingController : PPTableViewController<UIActionSheetDelegate, InputDialogDelegate,UserServiceDelegate, CommonDialogDelegate, ChangeAvatarDelegate, GeographyServiceDelegate>
{    
    NSInteger rowOfPassword;
    NSInteger rowOfGender;
    NSInteger rowOfNickName;
    NSInteger rowOfBirthday;
    NSInteger rowOfBloodGroup;
    NSInteger rowOfLocation;
    NSInteger rowOfZodiac;
    NSInteger rowOfSignature;
    NSInteger rowOfPrivacy;
    NSInteger rowOfCustomBg;
    NSInteger rowOfLanguage;
    NSInteger rowOfSinaWeibo;
    NSInteger rowOfQQWeibo;
    NSInteger rowOfFacebook;
    NSInteger rowOfLevel;
    NSInteger rowOfAutoSave;
    NSInteger rowOfCustomWord;
    NSInteger rowOfSoundSwitcher;
    NSInteger rowOfMusicSettings;
    NSInteger rowOfVolumeSetting;
    //NSInteger rowOfChatVoice;
    NSInteger rowOfCustomDice;
    
    NSInteger rowsInSectionUser;
    NSInteger rowsInSectionGuessWord;
    NSInteger rowsInSectionSound;
    NSInteger rowsInSectionAccount;
    
    ChangeAvatar *imageUploader;
    
    BOOL hasEdited;
    GuessLevel guessLevel;
    
    UserManager *_userManager;
    int _currentLoginType;
    
    BOOL isSoundOn;
    BOOL isMusicOn;
    BOOL avatarChanged;
}

- (IBAction)clickSaveButton:(id)sender;
- (IBAction)clickAvatar:(id)sender;
- (IBAction)clickBackButton:(id)sender;

@property (retain, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (retain, nonatomic) IBOutlet UILabel *expAndLevelLabel;
@property (retain, nonatomic) IBOutlet UIButton *saveButton;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *avatarButton;
@property (retain, nonatomic) IBOutlet UIImageView *tableViewBG;
@property (retain, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (retain, nonatomic) PBGameUser_Builder *pbUserBuilder;
@property (retain, nonatomic) UIImageView *avatarImageView;

- (void)updateRowIndexs;
@end
