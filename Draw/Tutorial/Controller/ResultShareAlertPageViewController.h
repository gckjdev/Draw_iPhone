//
//  ResultShareAlertPageViewController.h
//  Draw
//
//  Created by ChaoSo on 14-7-22.
//
//

#import <UIKit/UIKit.h>
#import "StableView.h"
typedef void(^ResultShareAlertPageViewResultBlock)();

@class PBUserStage;

@interface ResultShareAlertPageViewController : UIViewController<CommonDialogDelegate>

@property (retain, nonatomic) IBOutlet UIImageView *opusImageView;
@property (retain, nonatomic) IBOutlet AvatarView *avatarImageView;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UIButton *shareButton;
@property (retain, nonatomic) IBOutlet UIButton *continueButton;
@property (retain, nonatomic) IBOutlet UILabel *lineOneLabel;
@property (retain, nonatomic) IBOutlet UILabel *lineTwoLabel;
@property (retain, nonatomic) IBOutlet UILabel *lineThreeLabel;
@property (retain, nonatomic) IBOutlet UILabel *lineFourLabel;

+ (void)show:(PPViewController*)superController
       image:(UIImage*)resultImage
   userStage:(PBUserStage*)userStage
       score:(int)score
   nextBlock:(ResultShareAlertPageViewResultBlock)nextBlock
  retryBlock:(ResultShareAlertPageViewResultBlock)retryBlock
   backBlock:(ResultShareAlertPageViewResultBlock)backBlock;

@end
