//
//  ShakeNumberController.m
//  Draw
//
//  Created by qqn_pipi on 13-7-24.
//
//

#import "ShakeNumberController.h"
#import "UIResponder+MotionRecognizers.h"

@interface ShakeNumberController ()

@end

@implementation ShakeNumberController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_shakeButton release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setShakeButton:nil];
    [super viewDidUnload];
}

- (void)enableShake
{
	// Step 2 - Register for motion event:
	[self addMotionRecognizerWithAction:@selector(motionWasRecognized:)];
}

- (void)disableShake
{
	// Step 3 - Unregister:
	[self removeMotionRecognizer];
}

- (void) motionWasRecognized:(NSNotification*)notif {
//	CABasicAnimation* shake = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
//	shake.fromValue = [NSNumber numberWithFloat:-M_PI/32];
//	shake.toValue   = [NSNumber numberWithFloat:+M_PI/32];
//	shake.duration = 0.1;
//	shake.autoreverses = YES;
//	shake.repeatCount = 4;
//	[self.shakeFeedbackOverlay.layer addAnimation:shake forKey:@"shakeAnimation"];
//	
//	self.shakeFeedbackOverlay.alpha = 1.0;
//	[UIView animateWithDuration:2.0 delay:0.0
//						options:UIViewAnimationOptionCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
//					 animations:^{
//                         self.shakeFeedbackOverlay.alpha = 0.0;
//                     } completion:nil];
}


- (IBAction)clickShakeButton:(id)sender {
}
@end
