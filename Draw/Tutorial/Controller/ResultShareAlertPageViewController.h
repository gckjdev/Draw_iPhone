//
//  ResultShareAlertPageViewController.h
//  Draw
//
//  Created by ChaoSo on 14-7-22.
//
//

#import <UIKit/UIKit.h>

typedef void(^ResultShareAlertPageViewResultBlock)();

@class PBUserStage;

@interface ResultShareAlertPageViewController : UIViewController

@property (retain, nonatomic) IBOutlet UIImageView *opusImageView;
@property (retain, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UILabel *decsLabel;
@property (retain, nonatomic) IBOutlet UIButton *shareButton;
@property (retain, nonatomic) IBOutlet UIButton *continueButton;

+ (void)show:(PPViewController*)superController
       image:(UIImage*)resultImage
   userStage:(PBUserStage*)userStage
       score:(int)score
   nextBlock:(ResultShareAlertPageViewResultBlock)nextBlock
  retryBlock:(ResultShareAlertPageViewResultBlock)retryBlock
   backBlock:(ResultShareAlertPageViewResultBlock)backBlock;

@end
