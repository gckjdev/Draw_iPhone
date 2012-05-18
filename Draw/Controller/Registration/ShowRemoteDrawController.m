//
//  ShowRemoteDrawController.m
//  Draw
//
//  Created by haodong qiu on 12年5月17日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "ShowRemoteDrawController.h"
#import "GameBasic.pb.h"
#import "DrawAction.h"
#import "ShowDrawView.h"
#import "DrawUtils.h"

@interface ShowRemoteDrawController ()

@end

@implementation ShowRemoteDrawController
@synthesize draw;
@synthesize titleLabel;
@synthesize wordLabel;
@synthesize holderView;

- (void)dealloc
{
    [draw release];
    [titleLabel release];
    [wordLabel release];
    [holderView release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithPBDraw:(PBDraw *)pbDraw;
{
    self = [super init];
    if (self) {
        self.draw = pbDraw;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.titleLabel.text = NSLS(@"kReplayTitle");
    self.wordLabel.text = draw.word;
    
    
    NSMutableArray *drawActionList = [[NSMutableArray alloc] init];
    for (PBDrawAction *pbDrawAction in draw.drawDataList) {
        DrawAction *drawAction = [[DrawAction alloc] initWithPBDrawAction:pbDrawAction];
        [drawActionList addObject:drawAction];
        [drawAction release];
    }
    ShowDrawView *showDrawView = [[ShowDrawView alloc] init];
    [showDrawView setDrawActionList:drawActionList];
    [drawActionList release];
    showDrawView.frame = DRAW_VEIW_FRAME;
    CGFloat multiple = self.holderView.frame.size.width / showDrawView.frame.size.width;
    showDrawView.center = self.holderView.center;
    showDrawView.transform = CGAffineTransformMakeScale(multiple, multiple);
    [self.view addSubview:showDrawView];
    [showDrawView play];
    [showDrawView release];
}


- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setWordLabel:nil];
    [self setHolderView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.draw = nil;
}


- (IBAction)clickBackButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
