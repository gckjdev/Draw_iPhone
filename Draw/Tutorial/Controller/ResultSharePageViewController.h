//
//  ResultSharePageViewController.h
//  Draw
//
//  Created by ChaoSo on 14-7-22.
//
//

#import <UIKit/UIKit.h>
#import "StableView.h"
@interface ResultSharePageViewController : UIViewController
@property (retain, nonatomic) IBOutlet UIImageView *opusImageView;
@property (retain, nonatomic) IBOutlet UIImageView *headImageView;
@property (retain, nonatomic) IBOutlet UILabel *descLabel;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UIButton *shareButton;
@property (retain, nonatomic) IBOutlet UIButton *continueButton;

@end
