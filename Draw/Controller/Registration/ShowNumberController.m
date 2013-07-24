//
//  ShowNumberController.m
//  Draw
//
//  Created by qqn_pipi on 13-7-24.
//
//

#import "ShowNumberController.h"

@interface ShowNumberController ()

@end

@implementation ShowNumberController

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
    [_showNumberTipsLabel release];
    [_numberLabel release];
    [_okButton release];
    [_completeUserInfoButton release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setShowNumberTipsLabel:nil];
    [self setNumberLabel:nil];
    [self setOkButton:nil];
    [self setCompleteUserInfoButton:nil];
    [super viewDidUnload];
}
@end
