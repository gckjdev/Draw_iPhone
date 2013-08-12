//
//  ShareController.h
//  Draw
//
//  Created by Orange on 12-3-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonTabController.h"
#import "PPViewController.h"
#import "ShareCell.h"
#import "ShowDrawView.h"
#import "CommonDialog.h"
#import "ShareAction.h"
#import "MyPaintManager.h"
#import "PPTableViewController.h"
#import "OfflineDrawViewController.h"
#import "UserService.h"

typedef enum {
    FromWeixinOptionShareOpus = 0,
    FromWeixinOptionDrawAPicture = 1
}FromWeixinOption;

@class MyPaint;
@interface ShareController : CommonTabController <UIActionSheetDelegate, ShareCellDelegate, ShowDrawViewDelegate, CommonDialogDelegate,MyPaintManagerDelegate, OfflineDrawDelegate, UserServiceDelegate> {
    
    int EDIT;
    int SHARE_AS_PHOTO;
//    int SHARE_AS_GIF;
    int REPLAY;
    int DELETE;
    int DELETE_ALL;
    int DELETE_ALL_MINE;
    int DELETE_ALL_DRAFT;
    int CANCEL;    
    BOOL isLoading;
}

@property (retain, nonatomic) IBOutlet CommonTitleView *titleView;

@property (retain, nonatomic) IBOutlet UIButton *clearButton;
@property (retain, nonatomic) IBOutlet UILabel *awardCoinTips;
@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) ShareAction *shareAction;
@property (assign, nonatomic, getter = isFromWeiXin) BOOL fromWeiXin;

// to be removed later
- (IBAction)deleteAll:(id)sender;

- (IBAction)clickClearButton:(id)sender;

+ (void)shareFromWeiXin:(UIViewController*)superController;
@end
