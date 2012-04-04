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
    NSTimer *guessTimer;
    NSInteger retainCount;
    LanguageType languageType;
    BOOL gameCompleted;
    
    ShareImageManager *shareImageManager;
    NSMutableArray *avatarArray;
    ToolView *toolView;
    BOOL gameStarted;
    BOOL _guessCorrect;
}
@property (retain, nonatomic) IBOutlet UIButton *turnNumberButton;

@property (retain, nonatomic) IBOutlet UIButton *popupButton;
@property(nonatomic, retain)Word *word;

@property (retain, nonatomic) IBOutlet UIButton *guessDoneButton;
@property (retain, nonatomic) IBOutlet UIButton *clockButton;
@property (retain, nonatomic) NSString *candidateString;
- (IBAction)clickRunAway:(id)sender;
- (void)bomb:(id)sender;
- (IBAction)clickGuessDoneButton:(id)sender;

+ (ShowDrawController *)instance;

@end

extern ShowDrawController *GlobalGetShowDrawController();
