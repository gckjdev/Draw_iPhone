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
#import "PPViewController.h"
@class Word;
@class ShowDrawView;
@class ShareImageManager;
@class ToolView;
@interface ShowDrawController : PPViewController<DrawGameServiceDelegate,CommonDialogDelegate>
{
    Word *_word;
    DrawGameService *drawGameService;
    ShowDrawView *showView;
    NSString *_candidateString;
//    NSString *_traditionalCandidateString;
    
    NSTimer *guessTimer;
    NSInteger retainCount;
    LanguageType languageType;
    ShareImageManager *shareImageManager;
    NSMutableArray *avatarArray;
    UIViewController *_shopController;
    ToolView *toolView;
    BOOL _viewIsAppear;
    BOOL _guessCorrect;
}
@property (retain, nonatomic) IBOutlet UIButton *turnNumberButton;

@property (retain, nonatomic) IBOutlet UIButton *popupButton;
@property(nonatomic, retain)Word *word;

@property (retain, nonatomic) IBOutlet UIButton *guessDoneButton;
@property (retain, nonatomic) IBOutlet UIButton *clockButton;
@property (retain, nonatomic) NSString *candidateString;
@property (nonatomic, assign) BOOL needResetData;
- (IBAction)clickRunAway:(id)sender;
- (void)bomb:(id)sender;
- (IBAction)clickGuessDoneButton:(id)sender;
- (void)popupWordLengthMessage;

//- (void)setWordButtonsHidden:(BOOL)hidden;
+ (ShowDrawController *)instance;
+ (void)returnFromController:(UIViewController*)fromController;
+ (void)startGuessFromController:(UIViewController*)fromController;

@end

extern ShowDrawController *GlobalGetShowDrawController();
