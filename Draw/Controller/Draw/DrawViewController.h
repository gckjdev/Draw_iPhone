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
#import "PickLineWidthView.h"
#import "PickColorView.h"


@class Word;

@interface DrawViewController : UIViewController<DrawViewDelegate, DrawGameServiceDelegate, PickLineWidthViewDelegate, PickColorViewDelegate> {
    DrawView *drawView;
    DrawGameService *_drawGameService;
    Word *_word;
    PickColorView *_pickColorView;
    PickLineWidthView *_pickLineWidthView;
    NSTimer *drawTimer;
    NSInteger retainCount;
}

- (IBAction)pickColor:(id)sender;
- (IBAction)clickPlay:(id)sender;
- (IBAction)clickRedraw:(id)sender;
- (IBAction)clickMoreColorButton:(id)sender;
- (IBAction)clickPickWidthButton:(id)sender;
- (IBAction)clickEraserButton:(id)sender;



@property (retain, nonatomic) IBOutlet UIButton *playButton;
@property (retain, nonatomic) IBOutlet UIButton *redButton;
@property (retain, nonatomic) IBOutlet UIButton *greenButton;
@property (retain, nonatomic) IBOutlet UIButton *blueButton;
@property (retain, nonatomic) IBOutlet UIButton *widthButton;
@property (retain, nonatomic) IBOutlet UIButton *eraserButton;
@property (retain, nonatomic) IBOutlet UIButton *moreButton;
@property (retain, nonatomic) IBOutlet UIButton *blackButton;
@property (retain, nonatomic) IBOutlet UILabel *guessMsgLabel;

@property (retain, nonatomic) Word *word;
@property (retain, nonatomic) PickLineWidthView *pickLineWidthView;
@property (retain, nonatomic) PickColorView *pickColorView;

- (id)initWithWord:(Word *)word;

@end
