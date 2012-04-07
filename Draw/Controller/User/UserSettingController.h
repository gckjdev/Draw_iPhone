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

@class UserManager;
@class HJManagedImageV;
@interface UserSettingController : PPTableViewController<UIActionSheetDelegate,ChangeAvatarDelegate, InputDialogDelegate>
{
    UserManager *userManager;
    
    NSInteger rowOfPassword;
    NSInteger rowOfNickName;
    NSInteger rowOfLanguage;
    NSInteger rowOfSinaWeibo;
    NSInteger rowOfQQWeibo;
    NSInteger rowOfFacebook;
    NSInteger rowNumber;
    HJManagedImageV *imageView;
    ChangeAvatar *changeAvatar;
    
}
- (IBAction)clickSaveButton:(id)sender;
- (IBAction)clickAvatar:(id)sender;
- (IBAction)clickBackButton:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *saveButton;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *avatarButton;
@property (retain, nonatomic) IBOutlet UIImageView *tableViewBG;
@property (retain, nonatomic) IBOutlet UILabel *nicknameLabel;
- (void)updateRowIndexs;
@end
