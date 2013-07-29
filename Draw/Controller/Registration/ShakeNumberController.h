//
//  ShakeNumberController.h
//  Draw
//
//  Created by qqn_pipi on 13-7-24.
//
//

#import <UIKit/UIKit.h>
#import "PPViewController.h"

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


@property (retain, nonatomic) NSString* currentNumber;

- (IBAction)clickShakeButton:(id)sender;
- (IBAction)clickTakeNumberButton:(id)sender;

@end
