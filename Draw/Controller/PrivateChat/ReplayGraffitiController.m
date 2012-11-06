//
//  ReplayGraffitiController.m
//  Draw
//
//  Created by haodong on 12-6-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ReplayGraffitiController.h"
#import "ShowDrawView.h"
#import "DrawAction.h"
#import "ShareImageManager.h"

@interface ReplayGraffitiController ()
@property(nonatomic, retain) NSArray *drawActionList;
@end

@implementation ReplayGraffitiController
@synthesize playEndButton = _playEndButton;
@synthesize titleLabel = _titleLabel;
@synthesize drawActionList = _drawActionList;
@synthesize showDrawView = _showDrawView;

- (void)dealloc
{
    [_showDrawView stop];
    PPRelease(_showDrawView);
    PPRelease(_titleLabel);
    PPRelease(_drawActionList);
    [_playEndButton release];
    [super dealloc];
}

- (id)initWithDrawActionList:(NSArray *)drawActionList
{
    self = [super init];
    if (self) {
        self.drawActionList = drawActionList;
    }
    return self;
}

- (ShowDrawView *)createShowDrawView:(NSArray *)drawActionList
{
    ShowDrawView *showDrawView = [[[ShowDrawView alloc] init] autorelease];
    showDrawView.frame = DRAW_VIEW_FRAME;
    NSMutableArray *scaleActionList = nil;
    
    scaleActionList = [NSMutableArray arrayWithArray:drawActionList];
    [showDrawView setDrawActionList:scaleActionList]; 
    [showDrawView setShowPenHidden:NO];
    
    return showDrawView;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.titleLabel setText:NSLS(@"kGraffitiMessage")];
    
    self.showDrawView = [self createShowDrawView:_drawActionList];
    self.showDrawView.center = self.view.center;
    [self.showDrawView setShowPenHidden:YES];
    [self.showDrawView setPlaySpeed:1.0/80.0];
    [self.view addSubview:self.showDrawView];
    [self.showDrawView play];
    
    [self.playEndButton setBackgroundImage:[[ShareImageManager defaultManager] greenImage] forState:UIControlStateNormal];
    [self.playEndButton setTitle:NSLS(@"kPlayEnd") forState:UIControlStateNormal];

}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setPlayEndButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (IBAction)clickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickPlayEndButton:(id)sender {
    [self.showDrawView show];
    [self.showDrawView setShowPenHidden:YES];
    self.playEndButton.hidden = YES;

}
@end
