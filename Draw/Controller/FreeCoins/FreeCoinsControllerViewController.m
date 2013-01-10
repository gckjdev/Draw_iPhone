//
//  FreeCoinsControllerViewController.m
//  Draw
//
//  Created by 王 小涛 on 13-1-10.
//
//

#import "FreeCoinsControllerViewController.h"

@interface FreeCoinsControllerViewController ()

@end

@implementation FreeCoinsControllerViewController

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
    [_titleTlabel release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setTitleTlabel:nil];
    [super viewDidUnload];
}

- (IBAction)clickWatchVideoButton:(id)sender {
}

- (IBAction)clickDownloadAppsButton:(id)sender {
}

- (IBAction)clickHelpButton:(id)sender {
}

@end
