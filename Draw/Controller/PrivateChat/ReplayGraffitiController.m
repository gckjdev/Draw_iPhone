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

@interface ReplayGraffitiController ()
@property(nonatomic, retain) NSArray *drawActionList;
@end

@implementation ReplayGraffitiController
@synthesize titleLabel = _titleLabel;
@synthesize drawActionList = _drawActionList;

- (void)dealloc
{
    PPRelease(_drawActionList);
    [_titleLabel release];
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
    showDrawView.frame = DRAW_VEIW_FRAME;
    NSMutableArray *scaleActionList = nil;
    if ([DeviceDetection isIPAD]) {
        scaleActionList = [DrawAction scaleActionList:drawActionList 
                                               xScale:IPAD_WIDTH_SCALE 
                                               yScale:IPAD_HEIGHT_SCALE];
    } else {
        scaleActionList = [NSMutableArray arrayWithArray:drawActionList];
    }
    [showDrawView setDrawActionList:scaleActionList]; 
    [showDrawView setShowPenHidden:NO];
    
    return showDrawView;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.titleLabel setText:NSLS(@"kGraffiti")];
    
    ShowDrawView *showDrawView = [self createShowDrawView:_drawActionList];
    showDrawView.center = self.view.center;
    [showDrawView setPlaySpeed:1.0/30.0];
    [showDrawView play];
    [self.view addSubview:showDrawView];
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (IBAction)clickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
