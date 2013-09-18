//
//  ShakeNumberController.h
//  Draw
//
//  Created by qqn_pipi on 13-7-24.
//
//

#import <UIKit/UIKit.h>
#import "PPViewController.h"

@class CPMotionRecognizingWindow;

@interface ShakeNumberController : PPViewController
@property (retain, nonatomic) IBOutlet UIView *shakeMainView;
@property (retain, nonatomic) IBOutlet UIView *shakeResultView;

@property (retain, nonatomic) IBOutlet UIButton *shakeButton;
@property (retain, nonatomic) IBOutlet UILabel *shakeMainTipsLabel;
@property (retain, nonatomic) IBOutlet UIButton *mainShakeButton;
@property (retain, nonatomic) IBOutlet UILabel *shakeResultTipsLabel;
@property (retain, nonatomic) IBOutlet UILabel *shakeResultNumberLabel;
@property (retain, nonatomic) IBOutlet UIButton *reshakeButton;
@property (retain, nonatomic) IBOutlet UIButton *takeNumberButton;
@property (retain, nonatomic) IBOutlet UIView *shakeImageHolderView;

@property (retain, nonatomic) IBOutlet UIImageView *padImageView;
@property (retain, nonatomic) IBOutlet UIImageView *leftShakeImageView;
@property (retain, nonatomic) IBOutlet UIImageView *rightShakeImageView;
@property (retain, nonatomic) IBOutlet UIView *bgView;

@property (retain, nonatomic) NSString* currentNumber;
@property (retain, nonatomic) IBOutlet UILabel *chanceLeftLabel;
@property (retain, nonatomic) IBOutlet UIButton *closeButton;

//@property (retain, nonatomic) CPMotionRecognizingWindow* motionWindow;

- (IBAction)clickShakeButton:(id)sender;
- (IBAction)clickTakeNumberButton:(id)sender;
- (IBAction)clickClose:(id)sender;

@end
