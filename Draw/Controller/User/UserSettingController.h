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

@class UserManager;
@class HJManagedImageV;
@interface UserSettingController : PPTableViewController<UIActionSheetDelegate,ChangeAvatarDelegate, InputDialogDelegate,UserServiceDelegate, CommonDialogDelegate>
{
    UserManager *userManager;
    
    NSInteger rowOfPassword;
    NSInteger rowOfGender;
    NSInteger rowOfNickName;
    NSInteger rowOfBirthday;
    NSInteger rowOfBloodGropu;
    NSInteger rowOfLocation;
    NSInteger rowOfZodiac;
    NSInteger rowOfSignature;
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
    
    HJManagedImageV *imageView;
    ChangeAvatar *changeAvatar;
    NSString *_updatePassword;
    
    BOOL hasEdited;
    BOOL avatarChanged;
    BOOL isSoundOn;
    BOOL isMusicOn;
    BOOL isAutoSave;
//    BOOL languageChanged;
    LanguageType languageType;
    GuessLevel guessLevel;
    NSString* _gender;
    //ChatVoiceEnable chatVoice;
//    LevelType
    
    UserManager *_userManager;
    int _currentLoginType;
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
@property (retain, nonatomic) NSString *updatePassword;
@property (retain, nonatomic) NSString* gender;
@property (retain, nonatomic) NSString* tempEmail;

- (void)updateRowIndexs;
@end
