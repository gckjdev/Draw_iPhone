//
//  ShareEditController.m
//  Draw
//
//  Created by Orange on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShareEditController.h"

@interface ShareEditController ()

@end

@implementation ShareEditController
@synthesize myImageView = _myImageView;
@synthesize myImage = _myImage;

- (void)dealloc
{
    [_myImage release];
    [_myImageView release];
    [super dealloc];
}

- (IBAction)clickBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (id)initWithImage:(UIImage*)anImage
{
    self = [super init];
    if (self) {
        self.myImage = anImage;
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
    [self.myImageView setImage:self.myImage];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setMyImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
