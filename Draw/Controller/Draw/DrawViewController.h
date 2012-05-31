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
#import "PickColorView.h"
#import "PickEraserView.h"
#import "PickPenView.h"
#import "CommonDialog.h"
#import "SuperDrawViewController.h"
#import "ColorShopView.h"

@class Word;
@class ShareImageManager;
@class ColorShopController;
@class PenView;

@interface DrawViewController : SuperDrawViewController<DrawViewDelegate,PickViewDelegate,CommonDialogDelegate,ColorShopViewDelegate> {
    DrawView *drawView;
    PickColorView *pickColorView;
    PickEraserView *pickEraserView;
    NSInteger penWidth;
    NSInteger eraserWidth;
}

- (IBAction)clickChangeRoomButton:(id)sender;
- (IBAction)clickRedraw:(id)sender;
- (IBAction)clickEraserButton:(id)sender;
- (IBAction)clickPenButton:(id)sender;

@property (retain, nonatomic) IBOutlet UIButton *eraserButton;
@property (retain, nonatomic) IBOutlet UIButton *wordButton;
@property (retain, nonatomic) IBOutlet UIButton *cleanButton;
@property (retain, nonatomic) IBOutlet PenView *penButton;
@property (retain, nonatomic) IBOutlet ColorView *colorButton;

+ (void)startDraw:(Word *)word fromController:(UIViewController*)fromController;

- (id)initWithWord:(Word *)word lang:(LanguageType)lang;
- (void)initEraser;
- (void)initPens;
- (void)initDrawView;

@end

