//
//  ReportController.m
//  Draw
//
//  Created by Orange on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ReportController.h"
#import "SNSServiceDelegate.h"

@interface ReportController ()

@end

@implementation ReportController
@synthesize submitButton;
@synthesize backButton;
@synthesize contentText;

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [self.contentText resignFirstResponder];
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self.contentText setFrame:CGRectMake(26, 20, 268, 160)];
    [self.backButton setFrame:CGRectOffset(self.backButton.frame, 0, -200)];
    [self.submitButton setFrame:CGRectOffset(self.submitButton.frame, 0, -200)];
    return YES;
}

#pragma mark - publish weibo delegate
- (void)didPublishWeibo:(int)result
{
    
}

- (IBAction)submit:(id)sender
{
    switch (_reportType) {
        case SNS_SHARE:
            [[SinaSNSService defaultService] publishWeibo:self.contentText.text delegate:self];
            break;
            
        default:
            break;
    }
}

- (IBAction)clickBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initWithType:(ReportType)aType
{
    self = [super init];
    if (self) {
        _reportType = aType;
    }
    return self;
}

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

- (void)viewDidUnload
{
    [self setContentText:nil];
    [self setSubmitButton:nil];
    [self setBackButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [contentText release];
    [submitButton release];
    [backButton release];
    [super dealloc];
}
@end
