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
@class Word;
@class DrawView;
@interface ShowDrawController : UIViewController<DrawGameServiceDelegate>
{
    Word *_word;
    DrawGameService *drawGameService;
    DrawView *showView;
    NSString *_candidateString;
    NSTimer *guessTimer;
    NSInteger retainCount;
    LanguageType languageType;
    BOOL gameCompleted;
}

@property(nonatomic, retain)Word *word;
- (void)clickGuessDoneButton:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *guessMsgLabel;
@property (retain, nonatomic) IBOutlet UIButton *guessDoneButton;
@property (retain, nonatomic) IBOutlet UILabel *clockLabel;
@property (retain, nonatomic) NSString *candidateString;
- (IBAction)clickRunAway:(id)sender;
- (IBAction)clickBombButton:(id)sender;


+ (ShowDrawController *)instance;

@end

extern ShowDrawController *GlobalGetShowDrawController();
