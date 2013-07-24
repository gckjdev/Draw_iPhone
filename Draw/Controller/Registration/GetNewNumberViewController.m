//
//  GetNewNumberViewController.m
//  Draw
//
//  Created by qqn_pipi on 13-7-24.
//
//

#import "GetNewNumberViewController.h"
#import "UserNumberService.h"
#import "LoginByNumberController.h"
#import "ShowNumberController.h"

@interface GetNewNumberViewController ()

@end

@implementation GetNewNumberViewController

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
    [_takeNumberButton release];
    [_loginButton release];
    [_loginController release];
    [_showNumberController release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTakeNumberButton:nil];
    [self setLoginButton:nil];
    [self setLoginController:nil];
    [self setShowNumberController:nil];
    [super viewDidUnload];
}

- (IBAction)clickLogin:(id)sender
{
    self.loginController = [[[LoginByNumberController alloc] init] autorelease];
    [self.view addSubview:self.loginController.view];    
}

- (IBAction)clickTakeNumber:(id)sender
{
    [self showActivityWithText:NSLS(@"kLoading")];
    [[UserNumberService defaultService] getAndRegisterNumber:^(int resultCode, NSString *number) {
        [self hideActivity];
        if (resultCode == 0){
            self.showNumberController = [[[ShowNumberController alloc] init] autorelease];
            [self.view addSubview:self.showNumberController.view];
        }
        else{
            // TODO show error information
        }
    }];      
}


@end
