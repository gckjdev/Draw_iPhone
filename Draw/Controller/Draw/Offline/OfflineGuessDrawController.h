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

@protocol OfflineGuessDelegate <NSObject>

@optional
- (void)didGuessFeed:(Feed *)feed 
           isCorrect:(BOOL)isCorrect 
               words:(NSArray *)words;

@end

@class Word;
@class ShowDrawView;
@class ShareImageManager;
@class ToolView;
@class ItemShopController;
@class Draw;
@class Feed;
@interface OfflineGuessDrawController : PPViewController<CommonDialogDelegate,UIScrollViewDelegate,DrawDataServiceDelegate, AvatarViewDelegate>
{
    ShowDrawView *showView;
    NSString *_candidateString;
    ItemShopController *_shopController;
    ToolView *toolView;
    UIButton *moveButton;
    UIButton *lastScaleTarget;
    
    NSInteger numberPerPage;
    NSInteger pageCount;
    ShareImageManager *shareImageManager;

    Word *_word;
    LanguageType languageType;
    Feed *_feed;
    NSMutableArray *_guessWords;
    
    NSString *_opusId;
    Draw *_draw;
    UIViewController *_supperController;

}
@property (retain, nonatomic) NSString *candidateString;
@property (retain, nonatomic) ShowDrawView *showView;
@property (retain, nonatomic) UIViewController *superController;

@property (retain, nonatomic) IBOutlet UIImageView *drawBackground;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIPageControl *pageControl;
@property (retain, nonatomic) IBOutlet UIButton *leftPageButton;
@property (retain, nonatomic) IBOutlet UIButton *rightPageButton;
@property (retain, nonatomic) Word *word;
@property (retain, nonatomic) Feed *feed;
@property (retain, nonatomic) IBOutlet UIButton *quitButton;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;

@property (assign, nonatomic) id<OfflineGuessDelegate>delegate;

- (IBAction)clickRunAway:(id)sender;
- (void)bomb:(id)sender;
- (void)commitAnswer:(NSString *)answer;
- (IBAction)clickLeftPage:(id)sender;
- (IBAction)clickRightPage:(id)sender;


- (void)setButton:(UIButton *)button title:(NSString *)title enabled:(BOOL)enabled;
- (NSString *)realValueForButton:(UIButton *)button;
- (void)initShowView;
- (void)initBomb;

- (void)initTargetViews;
- (void)updateCandidateViews:(Word *)word lang:(LanguageType)lang;
- (void)updateTargetViews:(Word *)word;

- (void)scrollToPage:(NSInteger)pageIndex;

//the feed should be draw type
- (id)initWithFeed:(Feed *)feed;
//+ (void)startOfflineGuess:(UIViewController *)fromController;
+ (OfflineGuessDrawController *)startOfflineGuess:(Feed *)feed 
                                   fromController:(UIViewController *)fromController;
@end


