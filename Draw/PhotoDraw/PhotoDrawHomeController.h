//
//  PhotoDrawHomeController.h
//  Draw
//
//  Created by haodong on 13-4-22.
//
//

#import "PPViewController.h"

@interface PhotoDrawHomeController : PPViewController

- (IBAction)clickDrawButton:(id)sender;
- (IBAction)clickShopButton:(id)sender;
- (IBAction)clickOpusButton:(id)sender;
- (IBAction)clickFeedbackButton:(id)sender;

@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;
@property (retain, nonatomic) IBOutlet UIImageView *paperImageView;
@property (retain, nonatomic) IBOutlet UIImageView *topImageView;
@property (retain, nonatomic) IBOutlet UIImageView *clipImageView;
@property (retain, nonatomic) IBOutlet UIButton *drawButton;
@property (retain, nonatomic) IBOutlet UIButton *shopButton;
@property (retain, nonatomic) IBOutlet UIButton *opusButton;
@property (retain, nonatomic) IBOutlet UIButton *feedbackButton;

@end
