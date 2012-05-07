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
@class ItemShopController;
@interface ShowDrawController : SuperDrawViewController<CommonDialogDelegate,UIScrollViewDelegate>
{
    Word *_word;
    ShowDrawView *showView;
    NSString *_candidateString;
    LanguageType languageType;
    ItemShopController *_shopController;
    ToolView *toolView;
    BOOL _guessCorrect;
    UIButton *moveButton;
    UIButton *lastScaleTarget;
}
@property(nonatomic, retain)Word *word;
@property (retain, nonatomic) NSString *candidateString;
@property (nonatomic, assign) BOOL needResetData;
@property (retain, nonatomic) IBOutlet UIImageView *drawBackground;
- (IBAction)clickRunAway:(id)sender;
- (void)bomb:(id)sender;
- (void)commitAnswer:(NSString *)answer;
- (IBAction)clickLeftPage:(id)sender;
- (IBAction)clickRightPage:(id)sender;
- (void)popupWordLengthMessage;

- (void)initRoundNumber;
- (void)initClock;
- (void)initAvatars;
- (void)initShowView;
- (void)initWordButtons;
- (void)initBomb;
- (void)initPopButton;
- (void)initTargetViews;

- (void)updateCandidateViews:(Word *)word lang:(LanguageType)lang;
- (void)updateTargetViews:(Word *)word;

- (void)initWithCachData;

//- (void)updateBomb;

- (void)cleanData;


@property (retain, nonatomic) ShowDrawView *showView;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIPageControl *pageControl;
@property (retain, nonatomic) IBOutlet UIButton *leftPageButton;
@property (retain, nonatomic) IBOutlet UIButton *rightPageButton;

@end

extern ShowDrawController *GlobalGetShowDrawController();
