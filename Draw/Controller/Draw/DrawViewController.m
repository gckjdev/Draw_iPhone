//
//  DrawViewController.m
//  Draw
//
//  Created by gamy on 12-3-4.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "DrawViewController.h"
#import "DrawView.h"
#import "DrawGameService.h"
#import "DrawColor.h"
#import "GameMessage.pb.h"
@implementation DrawViewController
@synthesize playButton;
@synthesize widthSlider;
@synthesize redButton;
@synthesize greenButton;
@synthesize blueButton;
@synthesize whiteButton;
@synthesize blackButton;

- (void)dealloc
{
    [widthSlider release];
    [playButton release];
    [redButton release];
    [greenButton release];
    [blueButton release];
    [whiteButton release];
    [blackButton release];
    [showView release];
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
    drawView = [[DrawView alloc] initWithFrame:CGRectMake(0, 50, 320, 190)];
    [self.view addSubview:drawView];
    drawView.delegate = self;
    [drawView setLineWidth:self.widthSlider.value];
    [drawView release];
    
    
    showView = [[DrawView alloc] initWithFrame:CGRectMake(0, 245, 320, 190)];
    [self.view addSubview:showView];
    [showView release];
    
    _drawGameService = [DrawGameService defaultService];
    _drawGameService.drawDelegate = self;
    
    
}


- (void)viewDidUnload
{
    [self setWidthSlider:nil];
    [self setPlayButton:nil];
    [self setRedButton:nil];
    [self setGreenButton:nil];
    [self setBlueButton:nil];
    [self setWhiteButton:nil];
    [self setBlackButton:nil];
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
    if (button == redButton) {
        [drawView setLineColor:[DrawColor redColor]];
    }else if (button == greenButton) {
        [drawView setLineColor:[DrawColor greenColor]];
    }else if (button == blueButton) {
        [drawView setLineColor:[DrawColor blueColor]];
    }else if (button == whiteButton) {
        [drawView setLineColor:[DrawColor whiteColor]];
    }else if (button == blackButton) {
        [drawView setLineColor:[DrawColor blackColor]];
    }
}

- (IBAction)clickPlay:(id)sender {
    [drawView play];
}

- (IBAction)clickRedraw:(id)sender {
    //send clean request.
    [drawView clear];
}

- (IBAction)changeSlider:(id)sender {
    UISlider *slider = (UISlider *)sender;
    [drawView setLineWidth:slider.value];
}

- (void)didDrawedPaint:(Paint *)paint
{
    NSInteger count = [paint pointCount];
    [self.playButton setTitle:[NSString stringWithFormat:@"%d",count] forState:UIControlStateNormal];

    NSInteger intColor  = [DrawUtils compressDrawColor:paint.color];    
    
    NSMutableArray *pointList = [[[NSMutableArray alloc] init] autorelease];
    for (NSValue *pointValue in paint.pointList) {
        CGPoint point = [pointValue CGPointValue];
        NSNumber *pointNumber = [NSNumber numberWithInt:[DrawUtils compressPoint:point]];
        [pointList addObject:pointNumber];
    }
    [[DrawGameService defaultService]sendDrawDataRequestWithPointList:pointList color:intColor width:paint.width];
}

- (void)didReceiveDrawData:(GameMessage *)message
{
    NSInteger intColor = [[message notification] color];
    CGFloat lineWidth = [[message notification] width];        
    NSArray *pointList = [[message notification] pointsList];
    Paint *paint = [[Paint alloc] initWithWidth:lineWidth intColor:intColor numberPointList:pointList];
    [showView addPaint:paint play:YES];
}

- (void)didReceiveRedrawResponse:(GameMessage *)message
{
    [showView clear];
}

@end
