//
//  DrawViewController.h
//  Draw
//
//  Created by gamy on 12-3-4.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DrawView.h"
#import "DrawGameService.h"
#import "PickView.h"
#import "CommonDialog.h"
#import "PPViewController.h" 
#import "ColorShopView.h"
#import "UserManager.h"
#import "DrawDataService.h"
#import "DrawConstants.h"
#import "LevelService.h"

@class Word;
@class ShareImageManager;
@class ColorShopController;
@class PenView;
@class PickPenView;
@class PickEraserView;
@class PickColorView;
@class PickBackgroundColorView;
@class MyPaint;
@class Contest;
@class OfflineDrawViewController;

@protocol OfflineDrawDelegate <NSObject>

@optional
- (void)didControllerClickBack:(OfflineDrawViewController *)controller;
- (void)didController:(OfflineDrawViewController *)controller
     submitActionList:(NSMutableArray*)drawActionList
            drawImage:(UIImage *)drawImage;

@end


@interface OfflineDrawViewController : PPViewController<DrawViewDelegate,PickViewDelegate,CommonDialogDelegate,ColorShopViewDelegate,DrawDataServiceDelegate,LevelServiceDelegate> {
    
    Word *_word;
    LanguageType languageType;
    TargetType targetType;
    
    NSString*_targetUid;
    DrawColor *_bgColor;
    DrawColor *_eraserColor;
    Contest *_contest;
    
    BOOL _isAutoSave;
}

- (IBAction)clickRedraw:(id)sender;
- (IBAction)clickEraserButton:(id)sender;
- (IBAction)clickPenButton:(id)sender;
- (IBAction)clickColorButton:(id)sender;
- (IBAction)clickSubmitButton:(id)sender;
- (IBAction)clickRedoButton:(id)sender;

@property (retain, nonatomic) IBOutlet UIButton *submitButton;
@property (retain, nonatomic) IBOutlet UIButton *eraserButton;
@property (retain, nonatomic) IBOutlet UIButton *wordButton;
@property (retain, nonatomic) IBOutlet UIButton *cleanButton;
@property (retain, nonatomic) IBOutlet PenView *penButton;
@property (retain, nonatomic) IBOutlet ColorView *colorButton;
@property (retain, nonatomic) Word *word;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *draftButton;
@property (assign, nonatomic) id<OfflineDrawDelegate> delegate;
@property (retain, nonatomic) NSString *targetUid;
@property (retain, nonatomic) DrawColor* eraserColor;
@property (retain, nonatomic) DrawColor* bgColor;
@property (retain, nonatomic) Contest *contest;

- (IBAction)clickDraftButton:(id)sender;
- (IBAction)clickRevokeButton:(id)sender;

- (IBAction)changeBackground:(id)sender;
+ (void)startDraw:(Word *)word fromController:(UIViewController*)fromController;

- (id)initWithTargetType:(TargetType)aTargetType 
                delegate:(id<OfflineDrawDelegate>)aDelegate;

- (id)initWithWord:(Word *)word 
              lang:(LanguageType)lang;

- (id)initWithDraft:(MyPaint *)draft;

+ (void)startDraw:(Word *)word 
   fromController:(UIViewController*)fromController 
        targetUid:(NSString *)targetUid;

- (id)initWithWord:(Word *)word
              lang:(LanguageType)lang 
         targetUid:(NSString *)targetUid;

- (id)initWithContest:(Contest *)contest;
+ (void)startDrawWithContest:(Contest *)contest    
              fromController:(UIViewController*)fromController
                    animated:(BOOL)animated;

@end

