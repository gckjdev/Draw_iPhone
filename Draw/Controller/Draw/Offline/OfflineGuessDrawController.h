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
#import "DrawDataService.h"
#import "CommonMessageCenter.h"
#import "StableView.h"
#import "PickToolView.h"
#import "CanvasRect.h"
//#import "CommonItemInfoView.h"



@protocol OfflineGuessDelegate <NSObject>

@optional
- (void)didGuessFeed:(Feed *)feed 
           isCorrect:(BOOL)isCorrect 
               words:(NSArray *)words;

@end

@class Word;
@class ShowDrawView;
@class ShareImageManager;
@class VendingController;
@class Draw;
@class DrawFeed;
@class UseItemScene;

@interface OfflineGuessDrawController : PPViewController<CommonDialogDelegate,UIScrollViewDelegate,DrawDataServiceDelegate, AvatarViewDelegate,PickViewDelegate>
{
    ShowDrawView *showView;
    NSString *_candidateString;
    VendingController *_shopController;
    PickToolView *_pickToolView;
    
    UIButton *moveButton;
    UIButton *lastScaleTarget;
    
    ShareImageManager *shareImageManager;

    Word *_word;
    LanguageType languageType;
    DrawFeed *_feed;
    NSMutableArray *_guessWords;
    
    NSString *_opusId;
    NSString *_authorId;
    Draw *_draw;
    UIViewController *_supperController;
    UIImageView* _throwingItem;
    
    UseItemScene* _scene;

}
@property (retain, nonatomic) NSString *candidateString;
@property (retain, nonatomic) ShowDrawView *showView;
@property (retain, nonatomic) UIViewController *superController;

@property (retain, nonatomic) IBOutlet UIImageView *drawBackground;
@property (retain, nonatomic) Word *word;
@property (retain, nonatomic) DrawFeed *feed;
@property (retain, nonatomic) Draw *draw;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;

@property (assign, nonatomic) id<OfflineGuessDelegate>delegate;

- (IBAction)clickRunAway:(id)sender;
- (void)commitAnswer:(NSString *)answer;
- (IBAction)clickToolBox:(id)sender;


- (void)setButton:(UIButton *)button title:(NSString *)title enabled:(BOOL)enabled;
- (NSString *)realValueForButton:(UIButton *)button;
- (void)initShowView;

- (void)initTargetViews;
- (void)updateCandidateViews:(Word *)word lang:(LanguageType)lang;
- (void)updateTargetViews:(Word *)word;


//the feed should be draw type
- (id)initWithFeed:(Feed *)feed;
//+ (void)startOfflineGuess:(UIViewController *)fromController;
+ (OfflineGuessDrawController *)startOfflineGuess:(DrawFeed *)feed 
                                   fromController:(UIViewController *)fromController;


@end


