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
}
- (IBAction)clickBackButton:(id)sender;
@end
