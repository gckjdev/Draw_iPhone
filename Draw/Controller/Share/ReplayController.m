//
//  ReplayController.m
//  Draw
//
//  Created by  on 12-4-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ReplayController.h"
#import "MyPaint.h"
#import "ShowDrawView.h"
#import "UINavigationController+UINavigationControllerAdditions.h"
#import "LocaleUtils.h"
#import "ShareImageManager.h"

@implementation ReplayController

@synthesize paint = _paint;
@synthesize titleLabel = _titleLabel;
@synthesize shareButton = _shareButton;
@synthesize backButton = _backButton;
@synthesize showHolderView = _showHolderView;
@synthesize wordLabel = _wordLabel;

- (id)initWithPaint:(MyPaint*)paint
{
    self = [super init];
    self.paint = paint;
    return self;
}

- (IBAction)clickShareButton:(id)sender {
}

- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimatedWithTransition:UIViewAnimationTransitionCurlUp];
}

- (void)dealloc
{
    [_paint release];
    [_titleLabel release];
    [_shareButton release];
    [_backButton release];
    [_showHolderView release];
    [_wordLabel release];
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
    MyPaint* currentPaint = self.paint;
    NSData* currentData = [NSKeyedUnarchiver unarchiveObjectWithData:currentPaint.data ];
    NSArray* drawActionList = (NSArray*)currentData;
    
//    UIImageView* background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
//    [background setImage:[UIImage imageNamed:@"wood_bg.png"]];
//    background.tag = BACK_GROUND_TAG;
//    UIImageView* paper = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 400)];
//    [paper setImage:[UIImage imageNamed:@"paper.png"]];
//    [background addSubview:paper];
    
    int REPLAY_TAG = 1234;
    ShowDrawView* replayView = [[ShowDrawView alloc] initWithFrame:CGRectMake(10, 15, 300, 370)];   
    replayView.backgroundColor = [UIColor clearColor];
    replayView.tag = REPLAY_TAG;
    replayView.frame = self.showHolderView.bounds;
    [self.showHolderView addSubview:replayView];
    [replayView release];            

    NSMutableArray *actionList = [NSMutableArray arrayWithArray:drawActionList];
    [replayView setDrawActionList:actionList];
    [replayView play];
    
    
    self.titleLabel.text = NSLS(@"kReplayTitle");
    [self.shareButton setTitle:NSLS(@"kReplayShare") forState:UIControlStateNormal];
    [self.shareButton setBackgroundImage:[[ShareImageManager defaultManager] orangeImage] 
                                forState:UIControlStateNormal];

    if (_paint.drawWord == nil){
        self.wordLabel.text = @"";
    }
    else{
        self.wordLabel.text = [_paint drawWord];
    }
    

//    [self.view addSubview:background];
//    [background release];
    
//    UIImageView* paperClip = [[UIImageView alloc] initWithFrame:CGRectMake(53, -2, 194, 40)];
//    [paperClip setImage:[UIImage imageNamed:@"paperclip.png"]];
//    [background addSubview:paperClip];
//    
//    UIButton* quit = [[UIButton alloc] initWithFrame:CGRectMake(10, 410, 80, 40)];
//    [quit setTitle:NSLS(@"Back") forState:UIControlStateNormal];
//    [quit addTarget:self action:@selector(quitReplay) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:quit];
//    [quit setBackgroundImage:[[ShareImageManager defaultManager] greenImage] forState:UIControlStateNormal];
//    quit.tag = QUIT_BUTTON_TAG;    
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setShareButton:nil];
    [self setBackButton:nil];
    [self setShowHolderView:nil];
    [self setWordLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
