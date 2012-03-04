//
//  DrawViewController.m
//  Draw
//
//  Created by gamy on 12-3-4.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "DrawViewController.h"
#import "DrawView.h"

@implementation DrawViewController
@synthesize widthSlider;

- (void)dealloc
{
    [widthSlider release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    drawView = [[DrawView alloc] initWithFrame:CGRectMake(0, 50, 320, 410)];
    [self.view addSubview:drawView];
    [drawView setLineWidth:self.widthSlider.value];
    [drawView release];
}


- (void)viewDidUnload
{
    [self setWidthSlider:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)pickColor:(id)sender {
    UIButton *button = (UIButton *)sender;
    [drawView setLineColor:button.backgroundColor];
}

- (IBAction)clickPlay:(id)sender {
    [drawView play];
}

- (IBAction)clickRedraw:(id)sender {
    [drawView clear];
}

- (IBAction)changeSlider:(id)sender {
    UISlider *slider = (UISlider *)sender;
    [drawView setLineWidth:slider.value];
}
@end
