//
//  ShakeNumberController.m
//  Draw
//
//  Created by qqn_pipi on 13-7-24.
//
//

#import "ShakeNumberController.h"
#import "UIResponder+MotionRecognizers.h"
#import "UserNumberService.h"

@interface ShakeNumberController ()
{
    BOOL _enableShake;
}


@end

@implementation ShakeNumberController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self enableShake];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    self.shakeMainView.frame = self.view.bounds;
    [self.view addSubview:self.shakeMainView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    if (_enableShake){
        [self removeMotionRecognizer];
    }
    
    [_shakeButton release];
    [_shakeMainTipsLabel release];
    [_mainShakeButton release];
    [_shakeResultTipsLabel release];
    [_shakeResultNumberLabel release];
    [_reshakeButton release];
    [_takeNumberButton release];
    [_shakeMainView release];
    [_shakeResultView release];
    [_currentNumber release];
    [super dealloc];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self disableShake];
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload {
    [self disableShake];
    [self setShakeButton:nil];
    [self setShakeMainTipsLabel:nil];
    [self setMainShakeButton:nil];
    [self setShakeResultTipsLabel:nil];
    [self setShakeResultNumberLabel:nil];
    [self setReshakeButton:nil];
    [self setTakeNumberButton:nil];
    [self setShakeMainView:nil];
    [self setShakeResultView:nil];
    [super viewDidUnload];
}

- (void)enableShake
{
	// Step 2 - Register for motion event:
    if (!_enableShake){
        _enableShake = YES;
        [self addMotionRecognizerWithAction:@selector(motionWasRecognized:)];
    }
}

- (void)disableShake
{
	// Step 3 - Unregister:
    if (_enableShake){
        _enableShake = NO;
        [self removeMotionRecognizer];
    }
}

- (void)showOrUpdateShakeResultView:(NSString*)number
{
    self.shakeMainView.hidden = YES;
    if (self.shakeResultView.superview == nil){
        self.shakeResultView.frame = self.view.bounds;
        [self.view addSubview:self.shakeResultView];
    }

    self.shakeResultNumberLabel.text = number;    
}

- (void)getOneNumber
{
    
    [self showActivityWithText:NSLS(@"kLoading")];
    [[UserNumberService defaultService] getOneNumber:^(int resultCode, NSString *number) {

        [self hideActivity];
        
        // update view and show new view
        if (resultCode == 0){
            self.currentNumber = number;
            [self showOrUpdateShakeResultView:number];
        }
        else{
            // TODO
        }
    }];
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
    
    [self getOneNumber];
}

- (IBAction)clickTakeNumberButton:(id)sender {
    
    if ([self.currentNumber length] == 0){
        // TODO show error
        return;
    }
    
    [self showActivityWithText:NSLS(@"kLoading")];
    [[UserNumberService defaultService] takeUserNumber:self.currentNumber block:^(int resultCode, NSString *number) {
        
        [self hideActivity];
        
        // update view and show new view
        if (resultCode == 0){
            [self showOrUpdateShakeResultView:number];
        }
        else{
            // TODO
        }
    }];
}


@end
