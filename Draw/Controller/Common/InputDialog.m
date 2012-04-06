//
//  InputDialog.m
//  Draw
//
//  Created by  on 12-4-7.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "InputDialog.h"
#import "AnimationManager.h"
#import "ShareImageManager.h"


@implementation InputDialog
@synthesize cancelButton;
@synthesize contentView;
@synthesize okButton;
@synthesize bgView;
@synthesize titleLabel;
@synthesize targetTextField;


#define RUN_OUT_TIME 0.2
#define RUN_IN_TIME 0.4

- (IBAction)clickCancelButton:(id)sender {
    [self.view removeFromSuperview];
}

- (IBAction)clickOkButton:(id)sender {
        [self.view removeFromSuperview];
}

+ (InputDialog *)inputDialogWith:(NSString *)title delegate:(id<InputDialogDelegate>)delegate
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"InputDialog" owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create <InputDialog> but cannot find cell object from Nib");
        return nil;
    }
    InputDialog* view =  (InputDialog*)[topLevelObjects objectAtIndex:0];;    
    //init the button
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    [view.bgView setImage:[imageManager inputImage]];
    [view.titleLabel setBackgroundImage:[imageManager woodImage] forState:UIControlStateNormal];
    [view setDialogTitle:title];
    [view.cancelButton setBackgroundImage:[imageManager greenImage] forState:UIControlStateNormal];
    [view.cancelButton setTitle:NSLS(@"kCancel") forState:UIControlStateNormal];
    [view.okButton setTitle:NSLS(@"kOK") forState:UIControlStateNormal];
    [view.okButton setBackgroundImage:[imageManager redImage] forState:UIControlStateNormal];
    

//    [view.cancelButton addTarget:view action:@selector(clickCancelButton:) forControlEvents:UIControlEventTouchUpInside];
    
    return view;

}
- (void)showInView:(UIView *)view
{
    self.view.frame = view.bounds;
    [view addSubview:self.view];
    CAAnimation *runIn = [AnimationManager scaleAnimationWithFromScale:0.1 toScale:1 duration:RUN_IN_TIME delegate:view removeCompeleted:NO];
    [self.contentView.layer addAnimation:runIn forKey:@"runIn"];
}

- (void)setDialogTitle:(NSString *)title
{
    [self.titleLabel setTitle:title forState:UIControlStateNormal];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [self setCancelButton:nil];
    [self setOkButton:nil];
    [self setBgView:nil];
    [self setTitleLabel:nil];
    [self setTargetTextField:nil];
    [self setContentView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [cancelButton release];
    [okButton release];
    [bgView release];
    [titleLabel release];
    [targetTextField release];
    [contentView release];
    [super dealloc];
}
@end
