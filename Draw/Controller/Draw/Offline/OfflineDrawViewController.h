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

@class Word;
@class ShareImageManager;
@class ColorShopController;
@class PenView;
@class PickPenView;
@class PickEraserView;
@class PickColorView;

@interface OfflineDrawViewController : PPViewController<DrawViewDelegate,PickViewDelegate,CommonDialogDelegate,ColorShopViewDelegate> {
    DrawView *drawView;
    PickColorView *pickColorView;
    PickEraserView *pickEraserView;
    PickPenView *pickPenView;
    NSInteger penWidth;
    NSInteger eraserWidth;
    PenView *_willBuyPen;
    
    Word *_word;
    LanguageType languageType;
    
    ShareImageManager *shareImageManager;
    
}

- (IBAction)clickRedraw:(id)sender;
- (IBAction)clickEraserButton:(id)sender;
- (IBAction)clickPenButton:(id)sender;
- (IBAction)clickColorButton:(id)sender;

@property (retain, nonatomic) IBOutlet UIButton *eraserButton;
@property (retain, nonatomic) IBOutlet UIButton *wordButton;
@property (retain, nonatomic) IBOutlet UIButton *cleanButton;
@property (retain, nonatomic) IBOutlet PenView *penButton;
@property (retain, nonatomic) IBOutlet ColorView *colorButton;
@property (retain, nonatomic) Word *word;

+ (void)startDraw:(Word *)word fromController:(UIViewController*)fromController;

- (id)initWithWord:(Word *)word lang:(LanguageType)lang;
- (void)initEraser;
- (void)initPens;
- (void)initDrawView;

@end

