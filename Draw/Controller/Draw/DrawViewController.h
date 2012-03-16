//
//  DrawViewController.h
//  Draw
//
//  Created by gamy on 12-3-4.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DrawView.h"

@interface DrawViewController : UIViewController<DrawViewDelegate> {
    DrawView *drawView;
}
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

@end
