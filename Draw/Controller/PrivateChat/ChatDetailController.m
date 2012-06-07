//
//  ChatDetailController.m
//  Draw
//
//  Created by haodong qiu on 12年6月7日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "ChatDetailController.h"
#import "DeviceDetection.h"

@interface ChatDetailController ()

- (IBAction)clickBack:(id)sender;

@end

@implementation ChatDetailController
@synthesize titleLabel;
@synthesize graffitiButton;

- (void)dealloc {
    [titleLabel release];
    [graffitiButton release];
    [super dealloc];
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
    [self setTitleLabel:nil];
    [self setGraffitiButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#define BUBBLE_WIDTH_MAX_IPHONE 200.0
#define BUBBLE_WIDTH_MAX_IPAD   400.0
#define BUBBLE_WIDTH_MAX    (([DeviceDetection isIPAD])?(BUBBLE_WIDTH_MAX_IPAD):(BUBBLE_WIDTH_MAX_IPHONE))

- (UIView *)bubbleView:(UIImage *)image from:(BOOL)fromSelf
{
    UIView *returnView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
	returnView.backgroundColor = [UIColor clearColor];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    if (imageView.frame.size.width > 200) {
        CGRect rect = imageView.frame;
        CGFloat Multiple = BUBBLE_WIDTH_MAX / rect.size.width;
        imageView.frame = CGRectMake(0, 0, BUBBLE_WIDTH_MAX, rect.size.height * Multiple);
    }
    
//	UIImage *bubble = [UIImage imageNamed:@"TEST.PNG"];
//	UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[bubble stretchableImageWithLeftCapWidth:21 topCapHeight:14]];
//    bubbleImageView.backgroundColor =[UIColor clearColor];
    
    
    
    return returnView;
}


- (IBAction)clickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)clickGraffitiButton:(id)sender {
}

@end
