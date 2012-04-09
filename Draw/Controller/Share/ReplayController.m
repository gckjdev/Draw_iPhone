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
#import "GifManager.h"
#import "StringUtil.h"
#import "GifView.h"

@implementation ReplayController

@synthesize paint = _paint;
@synthesize titleLabel = _titleLabel;
@synthesize shareButton = _shareButton;
@synthesize backButton = _backButton;
@synthesize showHolderView = _showHolderView;
@synthesize wordLabel = _wordLabel;
@synthesize replayForCreateGif = _replayForCreateGif;
@synthesize shareAction = _shareAction;
@synthesize tempGIFFilePath = _tempGIFFilePath;

- (id)initWithPaint:(MyPaint*)paint
{
    self = [super init];
    self.paint = paint;
    return self;
}

- (IBAction)clickShareButton:(id)sender {
    
    [self.view endEditing:YES];
    
    NSString* path = nil;
    if (_replayForCreateGif)
        path = _tempGIFFilePath;
    else
        path = _paint.image;
    
    self.shareAction = [[[ShareAction alloc] initWithDrawImageFile:path
                                                             isGIF:_replayForCreateGif
                                                         drawWord:_paint.drawWord
                                                             isMe:[_paint.drawByMe boolValue]] autorelease];
    [_shareAction displayWithViewController:self];
}

- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimatedWithTransition:UIViewAnimationTransitionCurlUp];
}

- (void)dealloc
{
    [_tempGIFFilePath release];
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
    
    int REPLAY_TAG = 1234;
    ShowDrawView* replayView = [[ShowDrawView alloc] initWithFrame:CGRectMake(10, 15, 300, 370)];   
    replayView.backgroundColor = [UIColor clearColor];
    replayView.tag = REPLAY_TAG;
    if (_replayForCreateGif){
        replayView.delegate = self;
        replayView.shouldCreateGif = YES;
        replayView.playSpeed = 0.01;
    }
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
    
    if (_replayForCreateGif){
        [self showActivityWithText:NSLS(@"kCreating_gif")];
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

- (void)didPlayDrawView:(NSMutableArray*)gifFrameArray
{
    [self hideActivity];
    
    // create gif files here
    if (gifFrameArray == nil || [gifFrameArray count] == 0){
        [self popupMessage:NSLS(@"kFailCreateGIF") title:nil];
    }
    else{
        self.tempGIFFilePath = [NSString stringWithFormat:@"%@/%@.gif", NSTemporaryDirectory(), [NSString GetUUID]];
        [GifManager createGifToPath:self.tempGIFFilePath byImages:gifFrameArray];
        if ([[NSFileManager defaultManager] fileExistsAtPath:self.tempGIFFilePath] == NO){
            [self popupMessage:NSLS(@"kFailCreateGIF") title:nil];
        }
        else{
            [self clickShareButton:nil];
        }
    }
    
//    ShareGifController* controller = [[ShareGifController alloc] initWithGifFrames:gifFrameArray];
//    [self.navigationController pushViewController:controller animated:YES];
//    [controller release];
}

@end
