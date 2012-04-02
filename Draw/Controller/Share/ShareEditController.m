//
//  ShareEditController.m
//  Draw
//
//  Created by Orange on 12-3-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShareEditController.h"
#import "SynthesisView.h"

@interface ShareEditController ()

@end

@implementation ShareEditController
@synthesize myImage = _myImage;
@synthesize patternsGallery = _patternsGallery;
@synthesize patternsArray = _patternsArray;

- (void)dealloc
{
    [_myImage release];
    [_patternsGallery release];
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
    UIImageView* view1 = [[[UIImageView alloc] initWithFrame:CGRectMake(130, 400, 60, 60)] autorelease];
    NSArray* patternsImageArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"guess_pattern.png"], nil];
    [self.view addSubview:view1];
    SynthesisView* view = [[SynthesisView alloc] initWithFrame:CGRectMake(20, 75, 280, 280)];
    view.drawImage = self.myImage;
    view.patternImage = [UIImage imageNamed:@"guess_pattern.png"];
    [self.view addSubview:view];
    [view1 setImage:[view createImage]];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setPatternsGallery:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
