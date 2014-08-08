//
//  StageAlertViewController.h
//  Draw
//
//  Created by ChaoSo on 14-8-6.
//
//

#import <UIKit/UIKit.h>
#import "PBTutorial+Extend.h"

@interface StageAlertViewController : UIViewController<CommonDialogDelegate>

@property (retain, nonatomic) IBOutlet UIImageView *stageExampleImageView;
@property (retain, nonatomic) IBOutlet UILabel *bestScore;
@property (retain, nonatomic) IBOutlet UITextView *stageDesc;


//显示dialog
+(void)show:(PPViewController *)superController
userTutorial:(PBUserTutorial *)pbUserTutorial
 stageIndex:(NSInteger)stageIndex;

@end
