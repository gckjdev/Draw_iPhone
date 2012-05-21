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
@synthesize contentTextView;

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
    NSString *infoString =  @"Program By\n\
-------------------------------\n\
PIPI Peng\n\
Gamy Huang\n\
Kira Ou\n\
Xiaotao\n\
Haodong\n\
\n\
\n\
Designed By\n\
-------------------------------\n\
Roy He\n\
\n\
\n\
";
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];  
    NSString *currentVersion = [infoDict objectForKey:@"CFBundleVersion"];
    infoString = [infoString stringByAppendingFormat:@"App Version : %@" ,currentVersion];
    
    contentTextView.text = infoString;
}

- (void)viewDidUnload
{
    [self setAboutTitle:nil];
    [self setContentTextView:nil];
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
    [contentTextView release];
    [super dealloc];
}
@end
