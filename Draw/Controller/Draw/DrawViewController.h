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

@class Word;
@interface DrawViewController : UIViewController<DrawViewDelegate, DrawGameServiceDelegate> {
    DrawView *drawView;
    DrawGameService *_drawGameService;
    Word *_word;
}
- (IBAction)clickStartButton:(id)sender;
- (IBAction)pickColor:(id)sender;
- (IBAction)clickPlay:(id)sender;
- (IBAction)clickRedraw:(id)sender;
- (IBAction)changeSlider:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *playButton;
@property (retain, nonatomic) IBOutlet UISlider *widthSlider;
@property (retain, nonatomic) IBOutlet UIButton *redButton;
@property (retain, nonatomic) IBOutlet UIButton *greenButton;
@property (retain, nonatomic) IBOutlet UIButton *blueButton;
@property (retain, nonatomic) IBOutlet UIButton *whiteButton;
@property (retain, nonatomic) IBOutlet UIButton *blackButton;

@property (retain, nonatomic) Word *word;
- (id)initWithWord:(Word *)word;

@end
