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

@class UserManager;
@class HJManagedImageV;
@interface UserSettingController : PPTableViewController<UIActionSheetDelegate,ChangeAvatarDelegate, InputDialogDelegate,UserServiceDelegate, CommonDialogDelegate>
{
    UserManager *userManager;
    
    NSInteger rowOfPassword;
    NSInteger rowOfNickName;
    NSInteger rowOfLanguage;
    NSInteger rowOfSinaWeibo;
    NSInteger rowOfQQWeibo;
    NSInteger rowOfFacebook;
    NSInteger rowOfSoundSwitcher;
    NSInteger rowNumber;
    HJManagedImageV *imageView;
    ChangeAvatar *changeAvatar;
    NSString *_updatePassword;
    
    BOOL hasEdited;
    BOOL avatarChanged;
    BOOL languageChanged;
    LanguageType languageType;
    
}
- (IBAction)clickSaveButton:(id)sender;
- (IBAction)clickAvatar:(id)sender;
- (IBAction)clickBackButton:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *saveButton;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *avatarButton;
@property (retain, nonatomic) IBOutlet UIImageView *tableViewBG;
@property (retain, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (retain, nonatomic) NSString *updatePassword;
- (void)updateRowIndexs;
@end
