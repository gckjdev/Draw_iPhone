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
#import "SuperDrawViewController.h"


@class Word;
@class ShowDrawView;
@class ShareImageManager;
@class ToolView;
@interface ShowDrawController : SuperDrawViewController<CommonDialogDelegate,UIScrollViewDelegate>
{
    Word *_word;
    ShowDrawView *showView;
    NSString *_candidateString;
    LanguageType languageType;
    UIViewController *_shopController;
    ToolView *toolView;
    BOOL _viewIsAppear;
    BOOL _guessCorrect;
    UIButton *moveButton;
    UIButton *lastScaleTarget;
}
@property(nonatomic, retain)Word *word;
@property (retain, nonatomic) IBOutlet UIButton *guessDoneButton;
@property (retain, nonatomic) NSString *candidateString;
@property (nonatomic, assign) BOOL needResetData;
- (IBAction)clickRunAway:(id)sender;
- (void)bomb:(id)sender;
- (IBAction)clickGuessDoneButton:(id)sender;
- (IBAction)clickLeftPage:(id)sender;
- (IBAction)clickRightPage:(id)sender;
- (void)popupWordLengthMessage;


@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIPageControl *pageControl;
@property (retain, nonatomic) IBOutlet UIButton *leftPageButton;
@property (retain, nonatomic) IBOutlet UIButton *rightPageButton;

//- (void)setWordButtonsHidden:(BOOL)hidden;
+ (ShowDrawController *)instance;
+ (void)returnFromController:(UIViewController*)fromController;
+ (void)startGuessFromController:(UIViewController*)fromController;

@end

extern ShowDrawController *GlobalGetShowDrawController();
