//
//  UserSettingController.h
//  Draw
//
//  Created by  on 12-3-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTableViewController.h"
@class UserManager;

@interface UserSettingController : PPTableViewController<UIActionSheetDelegate>
{
    UserManager *userManager;
    
    NSInteger rowOfPassword;
    NSInteger rowOfNickName;
    NSInteger rowOfLanguage;
    NSInteger rowOfSinaWeibo;
    NSInteger rowOfQQWeibo;
    NSInteger rowOfFacebook;
    NSInteger rowNumber;
    
}
- (IBAction)clickBackButton:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIImageView *tableViewBG;
- (void)updateRowIndexs;
@end
