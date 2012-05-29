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
#import "PickPenView.h"
#import "CommonDialog.h"
#import "SuperDrawViewController.h"
#import "ColorShopView.h"

@class Word;
@class ShareImageManager;
@class ColorShopController;
@class PenView;

@interface DrawViewController : SuperDrawViewController<DrawViewDelegate,PickPenDelegate,CommonDialogDelegate,ColorShopViewDelegate> {
    DrawView *drawView;
    PickPenView *pickPenView;

//    Word *_word;
    NSInteger penWidth;
    NSInteger eraserWidth;

    NSAutoreleasePool *autoReleasePool;

                
}

- (IBAction)clickChangeRoomButton:(id)sender;
- (IBAction)clickRedraw:(id)sender;
- (IBAction)clickEraserButton:(id)sender;
- (IBAction)clickPenButton:(id)sender;

@property (retain, nonatomic) IBOutlet UIButton *eraserButton;
@property (retain, nonatomic) IBOutlet UIButton *wordButton;
@property (retain, nonatomic) IBOutlet UIButton *cleanButton;
@property (retain, nonatomic) IBOutlet PenView *penButton;

+ (void)startDraw:(Word *)word fromController:(UIViewController*)fromController;
- (void)setToolButtonEnabled:(BOOL)enabled;

- (id)initWithWord:(Word *)word lang:(LanguageType)lang;
- (void)initEraser;
- (void)initPens;
- (void)initDrawView;

@end

