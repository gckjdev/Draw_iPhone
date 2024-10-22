//
//  StageAlertViewController.h
//  Draw
//
//  Created by ChaoSo on 14-8-6.
//
//

#import <UIKit/UIKit.h>
#import "PBTutorial+Extend.h"
#import "PPViewController.h"
#import "UIViewController+CommonHome.h"

@interface StageAlertViewController : PPViewController<CommonDialogDelegate>

@property (retain, nonatomic) IBOutlet UIImageView *stageExampleImageView;
@property (retain, nonatomic) IBOutlet UILabel *bestScore;
@property (retain, nonatomic) IBOutlet UITextView *stageDesc;
@property (retain, nonatomic) IBOutlet UIButton *rankingButton;


//显示dialog
+(void)show:(PPViewController *)superController
userTutorial:(PBUserTutorial *)pbUserTutorial
 stageIndex:(NSInteger)stageIndex;

@end
