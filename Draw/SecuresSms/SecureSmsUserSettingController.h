//
//  SecureSmsUserSettingController.h
//  Draw
//
//  Created by haodong on 13-5-23.
//
//

#import <UIKit/UIKit.h>
#import "ChangeAvatar.h"
#import "PPTableViewController.h"
#import "PassWordDialog.h"
#import "InputDialog.h"
#import "CommonDialog.h"

@interface SecureSmsUserSettingController : PPTableViewController <ChangeAvatarDelegate, InputDialogDelegate, CommonDialogDelegate>

@property (retain, nonatomic) IBOutlet UIImageView *backgroundImage;
@property (retain, nonatomic) IBOutlet UIButton *saveButton;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *avatarButton;
@property (retain, nonatomic) IBOutlet UILabel *nicknameLabel;

- (IBAction)clickBackButton:(id)sender;
- (IBAction)clickAvatar:(id)sender;

@end
