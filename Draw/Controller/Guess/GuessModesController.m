//
//  GuessModesController.m
//  Draw
//
//  Created by 王 小涛 on 13-7-19.
//
//

#import "GuessModesController.h"
#import "GuessSelectController.h"

@interface GuessModesController ()

@end

@implementation GuessModesController

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

- (IBAction)clickHappyModeButton:(id)sender {
    
    GuessSelectController *vc = [[[GuessSelectController alloc] init] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)clickGeniusModeButton:(id)sender {
    
}

- (IBAction)clickContestModeButton:(id)sender {
    
}

@end
