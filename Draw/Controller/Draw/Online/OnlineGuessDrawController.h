//
//  ShowDrawController.h
//  Draw
//
//  Created by  on 12-3-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawGameService.h"
#import "UserManager.h"
#import "CommonDialog.h"
#import "SuperGameViewController.h"
#import "LevelService.h"
#import "WordInputView.h"
#import "CMPopTipView.h"

@class ShowDrawView;
@class UseItemScene;

@interface OnlineGuessDrawController : SuperGameViewController<CommonDialogDelegate,LevelServiceDelegate, WordInputViewDelegate, CMPopTipViewDelegate>
{
    BOOL _guessCorrect;
    UseItemScene* _scene;
}
@property (retain, nonatomic) ShowDrawView *showView;
@property (retain, nonatomic) CMPopTipView *popView;
@property (retain, nonatomic) UIView *toolView;
@property (retain, nonatomic) IBOutlet WordInputView *wordInputView;
- (IBAction)clickToolBox:(id)sender;
- (IBAction)clickGroupChatButton:(id)sender;

@property (retain, nonatomic) IBOutlet UIButton *toolBoxButton;




@end


