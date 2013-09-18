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
#import "CPMotionRecognizingWindow.h"
#import "StringUtil.h"
#import "UserService.h"

#define SET_BUTTON_ROUND_STYLE_USE_BUTTON(view)                              \
{                                                           \
    [ShareImageManager setButtonStyle:view normalTitleColor:COLOR_WHITE selectedTitleColor:COLOR_BROWN highlightedTitleColor:COLOR_BROWN font:LOGIN_FONT_BUTTON normalColor:COLOR_ORANGE selectedColor:COLOR_ORANGE highlightedColor:COLOR_ORANGE round:YES];         \
}


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
//    self.motionWindow = [[[CPMotionRecognizingWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
//    self.motionWindow.rootViewController = self;
//    [self.view addSubview:self.motionWindow];
//    
//    [self.view sendSubviewToBack:self.motionWindow];
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
//    self.shakeMainView.frame = self.view.bounds;
    [self.view addSubview:self.shakeMainView];
    
    SET_VIEW_ROUND_CORNER(self.bgView);
    self.view.backgroundColor = COLOR_GREEN;

    self.shakeMainTipsLabel.textColor = COLOR_RED;
    self.shakeResultTipsLabel.textColor = COLOR_RED;
    self.shakeResultNumberLabel.textColor = COLOR_BROWN;
    self.chanceLeftLabel.textColor = COLOR_BROWN;
    
    SET_BUTTON_ROUND_STYLE_USE_BUTTON(self.takeNumberButton);
    
    [self becomeFirstResponder];
    
    [self updateChanceLeftLabel];

    [self.view bringSubviewToFront:self.closeButton];
    
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
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
    
//    PPRelease(_motionWindow);
    PPRelease(_closeButton);
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
    [_padImageView release];
    [_leftShakeImageView release];
    [_rightShakeImageView release];
    [_chanceLeftLabel release];
    [_bgView release];
    [_shakeImageHolderView release];
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
    [self setPadImageView:nil];
    [self setLeftShakeImageView:nil];
    [self setRightShakeImageView:nil];
    [self setChanceLeftLabel:nil];
    [self setBgView:nil];
    [self setShakeImageHolderView:nil];
    [super viewDidUnload];
}

- (void) motionEnded:(UIEventSubtype)motion withEvent:(UIEvent*)event {
	if (event.type == UIEventTypeMotion && event.subtype == UIEventSubtypeMotionShake) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CPDeviceShaken" object:self];
	}
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

- (void)updateChanceLeftLabel
{
    int times = [[UserManager defaultManager] shakeTimesLeft];
    NSString* text = [NSString stringWithFormat:NSLS(@"kChanceLeftShake"), times];
    
    self.chanceLeftLabel.text = text;
    
    if (times <= 0){
        [self disableShake];
        self.shakeButton.enabled = NO;
    }
}

- (void)showOrUpdateShakeResultView:(NSString*)number
{
    self.shakeMainView.hidden = YES;
    if (self.shakeResultView.superview == nil){
//        self.shakeResultView.frame = self.view.bounds;
        [self.view addSubview:self.shakeResultView];
    }

    self.shakeResultView.alpha = 0.0f;
    self.shakeResultNumberLabel.text = [number formatNumber];
    [self updateChanceLeftLabel];

    [UIView animateWithDuration:1.5 animations:^{
        self.shakeResultView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        self.shakeResultView.alpha = 1.0f;
    }];
    
    [self.view bringSubviewToFront:self.closeButton];
    
}

- (void)getOneNumber
{
    
//    [self showActivityWithText:NSLS(@"kLoading")];
    [[UserNumberService defaultService] shakeOneNumber:^(int resultCode, NSString *number) {

//        [self hideActivity];
        
        // update view and show new view
        if (resultCode == 0 && [number length] > 0){
            [[UserManager defaultManager] incShakeTimes];
            self.currentNumber = number;
            [self showOrUpdateShakeResultView:number];
        }
        else{
            POSTMSG(NSLS(@"kShakeNumberFail"));
        }
    }];
}

- (void) motionWasRecognized:(NSNotification*)notif {
    
    PPDebug(@"<motionWasRecognized> %@", [notif description]);

    self.shakeImageHolderView.transform = CGAffineTransformMakeRotation(-M_PI/32);
    [UIView animateWithDuration:0.8 animations:^{
        [UIView setAnimationDuration:0.1];
        [UIView setAnimationRepeatAutoreverses:YES];
        [UIView setAnimationRepeatCount:4];
        self.shakeImageHolderView.transform = CGAffineTransformMakeRotation(M_PI/32);
    } completion:^(BOOL finished) {
        self.shakeImageHolderView.transform = CGAffineTransformIdentity;
        [self clickShakeButton:nil];
    }];
    
}


- (IBAction)clickShakeButton:(id)sender {
    
    [self getOneNumber];
}

- (IBAction)clickTakeNumberButton:(id)sender {
    
    if ([self.currentNumber length] == 0){
        [CommonDialog showSimpleDialog:NSLS(@"kTakeNumberFail")  inView:self.view];
        return;
    }
    
    [self showActivityWithText:NSLS(@"kLoading")];
    [[UserNumberService defaultService] takeUserNumber:self.currentNumber block:^(int resultCode, NSString *number) {
        
        [self hideActivity];
        
        // update view and show new view
        if (resultCode == 0){
            
            [[UserService defaultService] dismissShakeNumberView];
            [CommonDialog showSimpleDialog:NSLS(@"kTakeNumberSuccess")  inView:self.view.superview];
        }
        else{
            [CommonDialog showSimpleDialog:NSLS(@"kTakeNumberFail")  inView:self.view];
        }
    }];
}

- (IBAction)clickClose:(id)sender
{
    if ([self.currentNumber length] == 0){
        [[UserService defaultService] dismissShakeNumberView];
        return;
    }
    
    CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kMessage") message:NSLS(@"kGiveupNumber") style:CommonDialogStyleDoubleButton];
    
    [dialog setClickOkBlock:^(id infoView){
        [[UserService defaultService] dismissShakeNumberView];
    }];
    
    [dialog showInView:self.view];
    
}


@end
