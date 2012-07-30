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
#import "SuperGameViewController.h"
#import "ColorShopView.h"
#import "LevelService.h"

@class Word;
@class ShareImageManager;
@class ColorShopController;
@class PenView;
@class PickPenView;
@class PickEraserView;
@class PickColorView;

@interface OnlineDrawViewController : SuperGameViewController<DrawViewDelegate,PickViewDelegate,CommonDialogDelegate,ColorShopViewDelegate,LevelServiceDelegate> {
    DrawView *drawView;
    PickColorView *pickColorView;
    PickEraserView *pickEraserView;
    PickPenView *pickPenView;
    NSInteger penWidth;
    NSInteger eraserWidth;
    PenView *_willBuyPen;
    
    DrawColor *_bgColor;
    DrawColor *_eraserColor;

}

- (IBAction)clickChangeRoomButton:(id)sender;
- (IBAction)clickRedraw:(id)sender;
- (IBAction)clickEraserButton:(id)sender;
- (IBAction)clickPenButton:(id)sender;
- (IBAction)clickColorButton:(id)sender;
- (IBAction)changeBackground:(id)sender;

@property (retain, nonatomic) IBOutlet UIButton *eraserButton;
@property (retain, nonatomic) IBOutlet UIButton *wordButton;
@property (retain, nonatomic) IBOutlet UIButton *cleanButton;
@property (retain, nonatomic) IBOutlet PenView *penButton;
@property (retain, nonatomic) IBOutlet ColorView *colorButton;
@property (retain, nonatomic) GameMessage *gameCompleteMessage;
@property (retain, nonatomic) DrawColor* eraserColor;
@property (retain, nonatomic) DrawColor* bgColor;


+ (void)startDraw:(Word *)word fromController:(UIViewController*)fromController;

- (id)initWithWord:(Word *)word lang:(LanguageType)lang;
- (void)initEraser;
- (void)initPens;
- (void)initDrawView;

@end

