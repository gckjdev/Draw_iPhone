//
//  ReplayContestDrawController.m
//  Draw
//
//  Created by haodong on 12-9-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ReplayContestDrawController.h"
#import "DrawFeed.h"
#import "ShowDrawView.h"
#import "Draw.h"
#import "DrawAction.h"
#import "ShowDrawView.h"

#define KEY_

@interface ReplayContestDrawController ()
@property (retain, nonatomic) DrawFeed *feed;
@end

@implementation ReplayContestDrawController
@synthesize holderView = _holderView;
@synthesize feed = _feed;
@synthesize showView = _showView;

- (void)dealloc
{
    [_showView stop];
    PPRelease(_showView);
    [_feed release];
    [_holderView release];
    [super dealloc];
}

- (id)initWithFeed:(DrawFeed *)feed
{
    self = [super init];
    if (self) {
        self.feed = feed;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.showView = [[[ShowDrawView alloc] initWithFrame:self.holderView.frame] autorelease];
    
    NSMutableArray *list =  [NSMutableArray
                             arrayWithArray:
                             self.feed.drawData.drawActionList];
    [_showView setDrawActionList:list];
    double speed = [DrawAction calculateSpeed:_showView.drawActionList defaultSpeed:1.0/40.0 maxSecond:45];
    _showView.playSpeed = speed;
    [self.view addSubview:_showView];
    [self.holderView removeFromSuperview];
    [_showView play];
}

- (void)viewDidUnload
{
    [self setHolderView:nil];
    [super viewDidUnload];
}

- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickUpButton:(id)sender {
}

- (IBAction)clickShareButton:(id)sender {
}

- (IBAction)clickDownButton:(id)sender {
}
@end
