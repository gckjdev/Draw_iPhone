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
#import "ConfigManager.h"

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
    PPRelease(_showDrawView);
    PPRelease(_showDrawView);
    PPRelease(_titleLabel);
    PPRelease(_drawActionList);
    PPRelease(_playEndButton);
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
    ShowDrawView *showDrawView = [ShowDrawView showView];
    if ([drawActionList isKindOfClass:[NSMutableArray class]]) {
        [showDrawView setDrawActionList:(NSMutableArray *)drawActionList];
    }else{
        NSMutableArray *scaleActionList = [NSMutableArray arrayWithArray:drawActionList];
        [showDrawView setDrawActionList:scaleActionList];
    }
    [showDrawView setShowPenHidden:NO];
    
    return showDrawView;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.titleLabel setText:NSLS(@"kGraffitiMessage")];

    [self.showDrawView removeFromSuperview];
    self.showDrawView = [self createShowDrawView:_drawActionList];
    self.showDrawView.center = self.view.center;
    [self.showDrawView setShowPenHidden:YES];
    [self.view addSubview:self.showDrawView];
    [self.showDrawView play];
    
    [self.playEndButton setBackgroundImage:[[ShareImageManager defaultManager] greenImage] forState:UIControlStateNormal];
    [self.playEndButton setTitle:NSLS(@"kPlayEnd") forState:UIControlStateNormal];

    if (self.drawDataVersion > [ConfigManager currentDrawDataVersion]) {
        [self popupMessage:NSLS(@"kNewDrawVersionTip") title:nil];
    }
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
