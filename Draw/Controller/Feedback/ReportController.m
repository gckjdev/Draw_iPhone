//
//  ReportController.m
//  Draw
//
//  Created by Orange on 12-3-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ReportController.h"
#import "PPViewController.h"
#import "ShareImageManager.h"
#import "DeviceDetection.h"
#import "StringUtil.h"
#import "CommonMessageCenter.h"

#define WORDS_SEPERATOR @"$"

@interface ReportController ()

- (IBAction)endEditingContact:(id)sender;

@end

@implementation ReportController
@synthesize contactBackground;
@synthesize reporterTitle;
@synthesize contentBackground;
@synthesize submitButton;
@synthesize backButton;
@synthesize contentText;
@synthesize contactText;
@synthesize backgroundImageView;
@synthesize doneButton;
@synthesize tips;
@synthesize lastReport = _lastReport;

#define BUTTON_TAG_NEXT 201204101
#define BUTTON_TAG_DONE 201204102

- (void)fitKeyboardComeOut
{
    if (![DeviceDetection isIPAD]) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.8];
        if (_reportType == ADD_WORD) {
            [self.contentText setFrame:CGRectMake(40, 103, 240, 99)];
            [self.contentBackground setFrame:self.contentText.frame];
        } else {
            [self.contentText setFrame:CGRectMake(40, 63, 240, 109)];
            [self.contentBackground setFrame:self.contentText.frame];
        }
        
        [self.contactText setFrame:CGRectMake(50, 175, 230, 31)];
        [self.contactBackground setFrame:CGRectMake(40, 175, 240, 31)];
        [UIView commitAnimations];
    }
    
}

- (void)resetFrame
{
    if (![DeviceDetection isIPAD]) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.8];
        if (_reportType == ADD_WORD) {
            [self.contentText setFrame:CGRectMake(40, 103, 240, 149)];
            [self.contentBackground setFrame:self.contentText.frame];
        } else {
            [self.contentText setFrame:CGRectMake(40, 93, 240, 159)];
            [self.contentBackground setFrame:self.contentText.frame];
        } 
        [self.contactText setFrame:CGRectMake(50, 260, 230, 31)];
        [self.contactBackground setFrame:CGRectMake(40, 260, 240, 31)];
        [UIView commitAnimations];
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
//    [self fitKeyboardComeOut];
    
    [doneButton setTag:BUTTON_TAG_NEXT];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
//    [self fitKeyboardComeOut];
    [self.doneButton setTag:BUTTON_TAG_DONE];
}




- (void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text length] == 0) {
        self.doneButton.hidden = YES;
    }else{
        self.doneButton.hidden = NO;
    }
}

- (BOOL)contentCheckForWords
{
    NSArray* array = [self.contentText.text componentsSeparatedByCharactersInSet:
                      [NSCharacterSet characterSetWithCharactersInString:@" \n"]];
    _formatWords = @"";
    for (NSString* str in array) {
        if (str.length <= 0) {
            continue;
        }
        if (str.length > 7) {
            [[CommonMessageCenter defaultCenter] postMessageWithText:[NSString stringWithFormat:NSLS(@"kWordTooLong"),str] delayTime:2 isHappy:NO];
            return NO;
        }
        if (!NSStringIsValidChinese(str)) {
            [[CommonMessageCenter defaultCenter] postMessageWithText:[NSString stringWithFormat:NSLS(@"kIllegalCharacter"),str] delayTime:2 isHappy:NO];
            return NO;
        }
        _formatWords = [_formatWords stringByAppendingFormat:@"%@%@", WORDS_SEPERATOR, str];

    }
    return YES;
}

- (IBAction)submit:(id)sender
{
    if ([self.contentText.text length] == 0) {
        [self popupMessage:NSLS(@"kContentNull") title:nil];
        [self.contentText becomeFirstResponder];
        return;
    }
    if ([self.contactText.text length] == 0 && _reportType != ADD_WORD) {
        [self popupMessage:NSLS(@"kContactNull") title:nil];
        [self.contactText becomeFirstResponder];
        return;
    }
    if ([self.contentText.text isEqualToString:_lastReport]) {
        [self popupMessage:NSLS(@"kContentRepeat") title:nil];
        return;
    }
    switch (_reportType) {   
        case SUBMIT_BUG: {
            [[UserService defaultService] reportBugs:self.contentText.text withContact:self.contactText.text viewController:self];
        } break;
        case SUBMIT_FEEDBACK: {
            [[UserService defaultService] feedback:self.contentText.text WithContact:self.contactText.text viewController:self];
            
        } break;
        case ADD_WORD: {
            if ([self contentCheckForWords]) {
                [[UserService defaultService] commitWords:_formatWords viewController:self];
            }   
        } break;
        default:
            break;
    }
    self.lastReport = [[self.contentText.text copy] autorelease];
}

- (IBAction)hideKeyboard:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (_reportType == ADD_WORD) {
        [self submit:nil];
        [self.contentText resignFirstResponder];
        return;
    }
    if(button.tag == BUTTON_TAG_NEXT){
        [self.contactText becomeFirstResponder];
    }else if(button.tag == BUTTON_TAG_DONE)
    {
        [self endEditingContact:nil];
    }
}

- (IBAction)endEditingContact:(id)sender
{    
    [self.contactText resignFirstResponder];
//    [self resetFrame];
    [self submit:nil];
    
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
        _lastReport = [[NSString alloc] init];
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
    [self.backgroundImageView setImage:[UIImage imageNamed:[GameApp background]]];
    
    [self.submitButton setBackgroundImage:[[ShareImageManager defaultManager] orangeImage] forState:UIControlStateNormal];
    [self.contentBackground setImage:[[ShareImageManager defaultManager] inputImage]];    
    [self.contactBackground setImage:[[ShareImageManager defaultManager] inputImage]];
    [self.doneButton setBackgroundImage:[[ShareImageManager defaultManager] orangeImage] forState:UIControlStateNormal];
    [self.doneButton setTitle:NSLS(@"kSubmit") forState:UIControlStateNormal];
    [self.submitButton setTitle:NSLS(@"kSubmit") forState:UIControlStateNormal];
    [self.contentText becomeFirstResponder];
    
    [self.contactText setPlaceholder:NSLS(@"kInput_your_contact")];
    [self.tips setBackgroundImage:[[ShareImageManager defaultManager] messageImage] forState:UIControlStateNormal];
    [self.tips.titleLabel setNumberOfLines:2];
    [self.contentText becomeFirstResponder];
    
    switch (_reportType) {
        case SUBMIT_BUG: {
            [self.reporterTitle setText:NSLS(@"kReport_bug")];
            [self.contentText setText:NSLS(@"kHave_problems?")];
            
            [self.tips setTitle:[GameApp feedbackTips] forState:UIControlStateNormal];
//            }else {
//                [self.tips setTitle:NSLS(@"kDiceFeedbackTips") forState:UIControlStateNormal];
//            }
        } break;
        case SUBMIT_FEEDBACK: {
            [self.reporterTitle setText:NSLS(@"kAdvices")];
            [self.contentText setText:NSLS(@"kSay something...")];
            [self.tips setTitle:[GameApp feedbackTips] forState:UIControlStateNormal];
//            if (isDrawApp()) {
//                [self.tips setTitle:NSLS(@"kFeedbackTips") forState:UIControlStateNormal];
//            }else {
//                [self.tips setTitle:NSLS(@"kDiceFeedbackTips") forState:UIControlStateNormal];
//            }
        } break;
        case ADD_WORD: {
            [self.reporterTitle setText:NSLS(@"kAddWords")];
            [self.contactBackground setHidden:YES];
            [self.contactText setHidden:YES];
            [self.tips setTitle:NSLS(@"kAddWordsTips") forState:UIControlStateNormal];   
            
            CGPoint origin = self.contentText.frame.origin;
            CGSize size = self.contentText.frame.size;
            CGFloat height = self.contactText.frame.size.height + self.contactText.frame.origin.y - origin.y;
            self.contentText.frame = CGRectMake(origin.x, origin.y, size.width, height);
            self.contentBackground.frame = self.contentText.frame;
            
//            [self.tips.titleLabel setFont:[UIFont systemFontOfSize:13]];
/*  
            
            UILabel* tips = [[UILabel alloc] init ];
            [tips setBackgroundColor:[UIColor clearColor]];
            [tips setText:NSLS(@"kAddWordsTips")];
            [tips setTextAlignment:UITextAlignmentCenter];
            UIImageView* tipsBackground = [[UIImageView alloc] initWithImage:[[ShareImageManager defaultManager] popupImage]];
            [self.view addSubview:tipsBackground];
            [self.view addSubview:tips];
            [tipsBackground release];
            [tips release];
            
            if (![DeviceDetection isIPAD]) {
                [self.contentText setFrame:CGRectMake(40, 103, 240, 99)];
                [self.contentBackground setFrame:self.contentText.frame];
                [tips setFrame:CGRectMake(40, 60, 240, 40)];
                [tips setFont:[UIFont systemFontOfSize:12]];
                [tipsBackground setFrame:CGRectMake(40, 55, 240, 40)];
            } else {
                [self.contentText setFrame:CGRectMake(96, 270, 576, 347)];
                [self.contentBackground setFrame:self.contentText.frame];
                [tips setFrame:CGRectMake(96, 170, 576, 100)];
                [tips setFont:[UIFont systemFontOfSize:24]];
                [tipsBackground setFrame:CGRectMake(96, 160, 576, 100)];
            }
            
       */     
            
        } break;
        default:
            break;
    }
    // Do any additional setup after loading the view from its nib.
}


- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (_reportType == SUBMIT_BUG && 
        [contentText.text isEqualToString:NSLS(@"kHave_problems?")]) {
        [contentText setText:nil];
        return;
    }
    
    if (_reportType == SUBMIT_FEEDBACK && 
        [contentText.text isEqualToString:NSLS(@"kSay something...")]) {
        [contentText setText:nil];
        return;
    }

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
    [self setContactBackground:nil];
    [self setTips:nil];
    [self setBackgroundImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [contentText release];
    [submitButton release];
    [backButton release];
    [contactText release];
    [contentBackground release];
    [doneButton release];
    [reporterTitle release];
    [contactBackground release];
    [_lastReport release];
    [tips release];
    [backgroundImageView release];
    [super dealloc];
}
@end
