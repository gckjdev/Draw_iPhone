//
//  ReportController.m
//  Draw
//
//  Created by Orange on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ReportController.h"
#import "SNSServiceDelegate.h"
#import "ShareImageManager.h"

@interface ReportController ()

@end

@implementation ReportController
@synthesize reporterTitle;
@synthesize contentBackground;
@synthesize submitButton;
@synthesize backButton;
@synthesize contentText;
@synthesize contactText;
@synthesize doneButton;

- (void)fitKeyboardComeOut
{
    [self.contentText setFrame:CGRectMake(40, 93, 240, 109)];
    [self.contentBackground setFrame:self.contentText.frame];
    [self.contactText setFrame:CGRectMake(40, 205, 240, 31)];
}

- (void)resetFrame
{
    [self.contentText setFrame:CGRectMake(40, 93, 240, 159)];
    [self.contentBackground setFrame:self.contentText.frame];
    [self.contactText setFrame:CGRectMake(40, 260, 240, 31)];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self fitKeyboardComeOut];
    [self.doneButton setHidden:NO];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self fitKeyboardComeOut];
}

- (IBAction)hideKeyboard:(id)sender
{
    [contentText resignFirstResponder];
    [self.doneButton setHidden:YES];
    [self resetFrame];
}

- (IBAction)endEditingContact:(id)sender
{    
    [self.contactText resignFirstResponder];
    [self resetFrame];
}

#pragma mark - publish weibo delegate
- (void)didPublishWeibo:(int)result
{
    
}

- (IBAction)submit:(id)sender
{
    switch (_reportType) {           
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
    [self.submitButton setBackgroundImage:[[ShareImageManager defaultManager] orangeImage] forState:UIControlStateNormal];
    [self.contentBackground setImage:[[ShareImageManager defaultManager] inputImage]];
    [self.contactText setBackground:[[ShareImageManager defaultManager] inputImage]];
    [self.doneButton setBackgroundImage:[[ShareImageManager defaultManager] woodImage] forState:UIControlStateNormal];
    [self.submitButton setTitle:NSLS(@"kSubmit") forState:UIControlStateNormal];
    [doneButton setTitle:NSLS(@"kDone") forState:UIControlStateNormal];
    [self.contactText setPlaceholder:NSLS(@"kInput_your_contact")];
    
    switch (_reportType) {
        case SUBMIT_BUG: {
            [self.reporterTitle setText:NSLS(@"kReport_bug")];
            [self.contentText setText:NSLS(@"kHave_problems?")];
            
        } break;
        case SUBMIT_FEEDBACK: {
            [self.reporterTitle setText:NSLS(@"kAdvices")];
            [self.contentText setText:NSLS(@"kSay something...")];
        } break;
        default:
            break;
    }
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setContentText:nil];
    [self setSubmitButton:nil];
    [self setBackButton:nil];
    [self setContactText:nil];
    [self setContentBackground:nil];
    [self setDoneButton:nil];
    [self setReporterTitle:nil];
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
    [contactText release];
    [contentBackground release];
    [doneButton release];
    [reporterTitle release];
    [super dealloc];
}
@end
