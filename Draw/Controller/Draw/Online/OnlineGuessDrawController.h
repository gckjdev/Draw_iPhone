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
#import "PickToolView.h"
//#import "CommonItemInfoView.h"
#import "StoreController.h"


@class Word;
@class ShowDrawView;
@class ShareImageManager;
@class UseItemScene;

@interface OnlineGuessDrawController : SuperGameViewController<CommonDialogDelegate,UIScrollViewDelegate,LevelServiceDelegate,PickViewDelegate>
{
    ShowDrawView *showView;
    NSString *_candidateString;
//    VendingController *_shopController;
    BOOL _guessCorrect;
    UIButton *moveButton;
    UIButton *lastScaleTarget;
    PickToolView *_pickToolView;

    UseItemScene* _scene;
    
}
@property (retain, nonatomic) NSString *candidateString;
@property (retain, nonatomic) ShowDrawView *showView;

@property (retain, nonatomic) IBOutlet UIImageView *drawBackground;
- (IBAction)clickToolBox:(id)sender;

- (IBAction)clickRunAway:(id)sender;
- (void)commitAnswer:(NSString *)answer;

- (void)setButton:(UIButton *)button title:(NSString *)title enabled:(BOOL)enabled;
- (NSString *)realValueForButton:(UIButton *)button;
- (void)initShowView;


- (void)initTargetViews;
- (void)updateCandidateViews:(Word *)word lang:(LanguageType)lang;
- (void)updateTargetViews:(Word *)word;
- (void)initWithCacheData;



@end


