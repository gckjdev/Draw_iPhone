//
//  AskPsHomeController.m
//  Draw
//
//  Created by haodong on 13-6-8.
//
//

#import "AskPsHomeController.h"
#import "AskPsController.h"

@interface AskPsHomeController ()

@end

@implementation AskPsHomeController

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

- (IBAction)clickAskPsButton:(id)sender {
    [self.navigationController pushViewController:[[[AskPsController alloc] init] autorelease] animated:YES];
}

@end