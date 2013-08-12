//
//  AboutUsController.m
//  Draw
//
//  Created by Orange on 12-4-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AboutUsController.h"
#import "LocaleUtils.h"
#import "ConfigManager.h"

@interface AboutUsController ()

@end

@implementation AboutUsController
@synthesize aboutTitle;
@synthesize contentTextView;
@synthesize backgroundImageView;

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
    [self.backgroundImageView setImage:[UIImage imageNamed:[GameApp background]]];
    
    [self.aboutTitle setText:NSLS(@"kAbout_us_title")];

    [CommonTitleView createTitleView:self.view];
    CommonTitleView* titleView = [CommonTitleView titleView:self.view];
    [titleView setTitle:NSLS(@"kAbout_us_title")];
    [titleView setTarget:self];
    [titleView setBackButtonSelector:@selector(clickBack:)];

    
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
Old13\n\
\n\
\n\
";
 
    infoString = [infoString stringByAppendingFormat:@"App Version : %@" ,[ConfigManager currentVersion]];
    
    contentTextView.text = infoString;
}

- (void)viewDidUnload
{
    [self setAboutTitle:nil];
    [self setContentTextView:nil];
    [self setBackgroundImageView:nil];
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
    [backgroundImageView release];
    [super dealloc];
}
@end
