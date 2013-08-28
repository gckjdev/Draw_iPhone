//
//  GuessModesController.h
//  Draw
//
//  Created by 王 小涛 on 13-7-19.
//
//

#import "PPViewController.h"
#import "GuessService.h"
#import "CommonTitleView.h"

@interface GuessModesController : PPViewController <GuessServiceDelegate>
@property (retain, nonatomic) IBOutlet CommonTitleView *titleView;
@property (retain, nonatomic) IBOutlet UILabel *happyModeLabel;
@property (retain, nonatomic) IBOutlet UILabel *genuisModeLabel;
@property (retain, nonatomic) IBOutlet UILabel *contestModeLabel;
@property (retain, nonatomic) IBOutlet UIButton *contestModeButton;
@property (retain, nonatomic) IBOutlet UILabel *rankListLabel;
@property (retain, nonatomic) IBOutlet UILabel *rulesLabel;
@property (retain, nonatomic) IBOutlet UILabel *hourLabel;
@property (retain, nonatomic) IBOutlet UILabel *minusLabel;
@property (retain, nonatomic) IBOutlet UILabel *secondLabel;
@property (retain, nonatomic) IBOutlet UIImageView *countDownImageView;
@property (retain, nonatomic) IBOutlet UIButton *happyModeButton;
@property (retain, nonatomic) IBOutlet UIButton *geniusModeButton;
@property (retain, nonatomic) IBOutlet UIButton *rankButton;
@property (retain, nonatomic) IBOutlet UIButton *rulesButton;
@property (retain, nonatomic) IBOutlet UIView *contentModeHolderView;

@end
