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

@class Word;
@class ShareImageManager;
@interface DrawViewController : UIViewController<DrawViewDelegate, 
            DrawGameServiceDelegate, PickPenDelegate> {
                
    DrawView *drawView;
    PickPenView *pickPenView;
    DrawGameService *drawGameService;
    Word *_word;
    NSTimer *drawTimer;
    NSInteger retainCount;
    BOOL gameComplete;
    ShareImageManager *shareImageManager;
    NSMutableArray *avatarArray;
}

- (IBAction)clickChangeRoomButton:(id)sender;
- (IBAction)clickRedraw:(id)sender;
- (IBAction)clickEraserButton:(id)sender;
- (IBAction)clickPenButton:(id)sender;

@property (retain, nonatomic) IBOutlet UIButton *turnNumberButton;
@property (retain, nonatomic) IBOutlet UIButton *popupButton;
@property (retain, nonatomic) IBOutlet UIButton *eraserButton;
@property (retain, nonatomic) IBOutlet UIButton *wordButton;
@property (retain, nonatomic) IBOutlet UIButton *clockButton;
@property (retain, nonatomic) IBOutlet UIButton *cleanButton;
@property (retain, nonatomic) IBOutlet UIButton *penButton;


@property (retain, nonatomic) Word *word;


+ (DrawViewController *)instance;

@end


extern DrawViewController *GlobalGetDrawViewController();
