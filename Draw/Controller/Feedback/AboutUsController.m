//
//  AboutUsController.m
//  Draw
//
//  Created by Orange on 12-4-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AboutUsController.h"
#import "LocaleUtils.h"

@interface AboutUsController ()

@end

@implementation AboutUsController
@synthesize aboutTitle;

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
    [self.aboutTitle setText:NSLS(@"kAbout_us_title")];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setAboutTitle:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (IBAction)clickBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
    [aboutTitle release];
    [super dealloc];
}
@end
