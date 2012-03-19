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
#import "Word.h"
#import "PickColorView.h"
#import "PickLineWidthView.h"



@implementation DrawViewController
@synthesize playButton;
@synthesize redButton;
@synthesize greenButton;
@synthesize blueButton;
@synthesize widthButton;
@synthesize eraserButton;
@synthesize moreButton;
@synthesize blackButton;
@synthesize word = _word;
@synthesize pickColorView = _pickColorView;
@synthesize pickLineWidthView = _pickLineWidthView;

- (void)dealloc
{
    [playButton release];
    [redButton release];
    [greenButton release];
    [blueButton release];
    [blackButton release];
    [_word release];
    [widthButton release];
    [eraserButton release];
    [moreButton release];
    [_pickLineWidthView release];
    [_pickColorView release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
- (id)initWithWord:(Word *)word
{
    self = [super init];
    if (self) {
        self.word = word; 
    }
    return self;
    
}

- (void)addPickColorView
{
    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:[NSString stringWithFormat:@"画画中(%@)",self.word.text]];       

    
    drawView = [[DrawView alloc] initWithFrame:CGRectMake(0, 50, 320, 400)];
    [self.view addSubview:drawView];
    drawView.delegate = self;
    [drawView release];
    
    _drawGameService = [DrawGameService defaultService];
    _drawGameService.drawDelegate = self;
    
    
}


- (void)viewDidUnload
{
    [self setPlayButton:nil];
    [self setRedButton:nil];
    [self setGreenButton:nil];
    [self setBlueButton:nil];
    [self setBlackButton:nil];
    [self setWord:nil];
    [self setWidthButton:nil];
    [self setEraserButton:nil];
    [self setMoreButton:nil];
    [self setPickColorView:nil];
    [self setPickLineWidthView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)hidePickViews
{
    [self.pickLineWidthView setHidden:YES];
    [self.pickColorView setHidden:YES];
}



- (IBAction)pickColor:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (button == redButton) {
        [drawView setLineColor:[DrawColor redColor]];
    }else if (button == greenButton) {
        [drawView setLineColor:[DrawColor greenColor]];
    }else if (button == blueButton) {
        [drawView setLineColor:[DrawColor blueColor]];
    }else if (button == blackButton) {
        [drawView setLineColor:[DrawColor blackColor]];
    }
}

- (IBAction)clickPlay:(id)sender {
    [drawView play];
}

- (IBAction)clickRedraw:(id)sender {
    //send clean request.
    [_drawGameService cleanDraw];
    [drawView clear];
    [drawView setDrawEnabled:YES];
}

- (IBAction)clickMoreColorButton:(id)sender {
    
    NSLog(@"clickMoreColorButton");
}

- (IBAction)clickPickWidthButton:(id)sender {
    PickLineWidthView *widthView = [[PickLineWidthView alloc] initWithFrame:CGRectMake(100, 100, 120, 100)];
    NSMutableArray *widthArray = [[NSMutableArray alloc] init];
    for (int i = 5; i < 21; i += 5) {
        NSNumber *number = [NSNumber numberWithInt:i];
        [widthArray addObject:number];
    }
    [widthView setLineWidths:widthArray];
    [widthArray release];
    [self.view addSubview:widthView];
}

- (IBAction)clickEraserButton:(id)sender {
    NSLog(@"clickEraserButton");
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
//    NSLog(@"didDrawedPaint: %@",[paint toString]);
    
    [[DrawGameService defaultService]sendDrawDataRequestWithPointList:pointList color:intColor width:paint.width];
}

//- (void)didReceiveDrawData:(GameMessage *)message
//{
//    NSInteger intColor = [[message notification] color];
//    CGFloat lineWidth = [[message notification] width];        
//    NSArray *pointList = [[message notification] pointsList];
//    Paint *paint = [[Paint alloc] initWithWidth:lineWidth intColor:intColor numberPointList:pointList];
////    NSLog(@"didReceiveDrawData: %@",[paint toString]);
//}
//
//- (void)didReceiveRedrawResponse:(GameMessage *)message
//{
//    
//}

@end
