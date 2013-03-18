//
//  UserDetailViewController.m
//  Draw
//
//  Created by Kira on 13-3-18.
//
//

#import "UserDetailViewController.h"

@interface UserDetailViewController ()

@end

@implementation UserDetailViewController

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
    [_backgroundImageView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setBackgroundImageView:nil];
    [super viewDidUnload];
}
@end
