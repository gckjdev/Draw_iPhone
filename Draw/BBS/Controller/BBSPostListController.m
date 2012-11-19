//
//  BBSPostListController.m
//  Draw
//
//  Created by gamy on 12-11-17.
//
//

#import "BBSPostListController.h"
#import "Bbs.pb.h"
@interface BBSPostListController ()

@end

@implementation BBSPostListController

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
    [_backButton release];
    [_createPostButton release];
    [_rankButton release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setBackButton:nil];
    [self setCreatePostButton:nil];
    [self setRankButton:nil];
    [super viewDidUnload];
}
- (IBAction)clickCreatePostButton:(id)sender {
}

- (IBAction)clickRankButton:(id)sender {
}
@end
