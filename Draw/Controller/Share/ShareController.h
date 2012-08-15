//
//  ShareController.h
//  Draw
//
//  Created by Orange on 12-3-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPViewController.h"
#import "ShareCell.h"
#import "ShowDrawView.h"
#import "CommonDialog.h"
#import "ShareAction.h"
#import "MyPaintManager.h"
#import "PPTableViewController.h"

@class MyPaint;
@interface ShareController : PPTableViewController <UIActionSheetDelegate, ShareCellDelegate, ShowDrawViewDelegate, CommonDialogDelegate,MyPaintManagerDelegate> {
    
    int SHARE_AS_PHOTO;
    int SHARE_AS_GIF;
    int REPLAY;
    int DELETE;
    int DELETE_ALL;
    int DELETE_ALL_MINE;
    int CANCEL;    
}
- (IBAction)selectDraft:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *selectDraftButton;
@property (retain, nonatomic) IBOutlet UIButton *selectMineButton;
@property (retain, nonatomic) IBOutlet UIButton *selectAllButton;
@property (retain, nonatomic) IBOutlet UIButton *clearButton;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) ShareAction *shareAction;
@property (retain, nonatomic) IBOutlet UILabel *awardCoinTips;
@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (assign, nonatomic, getter = isFromWeiXin) BOOL fromWeiXin;
@end
