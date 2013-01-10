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
#import "DeviceDetection.h"
#import <QuartzCore/QuartzCore.h>
#import "DrawAction.h"
#import "UIImageExt.h"
#import "MyPaintManager.h"

#define REPLAY_TAG 1234
#define COMPRESS_SCALE 0.6
#define POINT_COUNT_PER_FRAME 30
#define IPAD_SHOW_DRAW_VIEW_FRAME CGRectMake(0, 0, 280*2.4, 295*2.13)
#define IPHONE_SHOW_DRAW_VIEW_FRAME CGRectMake(0, 0, 280, 295)
#define SHOW_DRAW_VIEW_FRAME ([DeviceDetection isIPAD] ? IPAD_SHOW_DRAW_VIEW_FRAME : IPHONE_SHOW_DRAW_VIEW_FRAME)

@implementation ReplayController

@synthesize paint = _paint;
@synthesize titleLabel = _titleLabel;
@synthesize shareButton = _shareButton;
@synthesize backButton = _backButton;
@synthesize showHolderView = _showHolderView;
@synthesize wordLabel = _wordLabel;
@synthesize playEndButton = _playEndButton;
@synthesize replayForCreateGif = _replayForCreateGif;
@synthesize shareAction = _shareAction;
@synthesize tempGIFFilePath = _tempGIFFilePath;
@synthesize gifImages = _gifImages;
@synthesize replayView = _replayView;

- (IBAction)clickPlayEndButton:(id)sender {
    [self.replayView show];
    [self.replayView setShowPenHidden:YES];
    self.playEndButton.hidden = YES;
}

- (id)initWithPaint:(MyPaint*)paint
{
    self = [super init];
    self.paint = paint;
    _gifImages = [[NSMutableArray alloc] init];
    return self;
}

- (IBAction)clickShareButton:(id)sender {
    
    [self.view endEditing:YES];
    
    NSString* path = nil;
    if (_replayForCreateGif)
        path = _tempGIFFilePath;
    else
        path = _paint.imageFilePath;
    
    self.shareAction = [[[ShareAction alloc] initWithDrawImageFile:path
                                                             isGIF:_replayForCreateGif
                                                         drawWord:_paint.drawWord
                                                             drawUserId:_paint.drawUserId] autorelease];
    [_shareAction displayWithViewController:self];
}

- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimatedWithTransition:UIViewAnimationTransitionCurlUp];
}

- (void)dealloc
{
    PPRelease(_shareAction);
    PPRelease(_gifImages);
    PPRelease(_tempGIFFilePath);
    PPRelease(_paint);
    PPRelease(_titleLabel);
    PPRelease(_shareButton);
    PPRelease(_backButton);
    PPRelease(_showHolderView);
    PPRelease(_wordLabel);
    PPRelease(_playEndButton);
    [_replayView stop];
    PPRelease(_replayView);
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
//    MyPaint* currentPaint = self.paint;

//    NSArray* drawActionList = (NSArray*)currentData;
    
//    CGFloat xScale = self.showHolderView.frame.size.width/DRAW_VIEW_FRAME.size.width;
//    CGFloat yScale = self.showHolderView.frame.size.height/DRAW_VIEW_FRAME.size.height;
    
    self.replayView = [[[ShowDrawView alloc]initWithFrame:
                                self.showHolderView.frame] autorelease];
    if (self.replayForCreateGif) {
        [_replayView setShowPenHidden:YES];
    }
    
//    NSMutableArray *actionList = [DrawAction scaleActionList:self.paint.drawActionList
//                                                      xScale:xScale 
//                                                      yScale:yScale];
    [_replayView setDrawActionList:self.paint.drawActionList];
    _replayView.backgroundColor = [UIColor whiteColor];
    _replayView.tag = REPLAY_TAG;
    
    double speed = [DrawAction calculateSpeed:self.replayView.drawActionList];
    self.replayView.playSpeed = speed;

    _replayView.delegate = self;    
    if (_replayForCreateGif){
        
        [self.shareButton setHidden:YES];
        [self.backButton setHidden:YES];
    }

    [self.view addSubview:_replayView];
    [_replayView play];
    
    
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
        self.playEndButton.hidden = YES;
    }else{
        self.playEndButton.hidden = NO;
        [self.playEndButton setBackgroundImage:[[ShareImageManager defaultManager] greenImage] forState:UIControlStateNormal];
        [self.playEndButton setTitle:NSLS(@"kPlayEnd") forState:UIControlStateNormal];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [_replayView resume];
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [_replayView stop];
    [super viewDidDisappear:animated];
}


//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    [_replayView pause];
//}
//
//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    [_replayView resume];
//}

- (void)viewDidUnload
{   
    [self setTitleLabel:nil];
    [self setShareButton:nil];
    [self setBackButton:nil];
    [self setShowHolderView:nil];
    [self setWordLabel:nil];
    [self setPlayEndButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



- (void)didPlayDrawView:(ShowDrawView *)showDrawView
{
    if (_replayForCreateGif){
        UIImage *image = [showDrawView createImage];
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, NULL);
        [self hideActivity];
        [self.backButton setHidden:NO];
        [self.shareButton setHidden:NO];
        // create gif files here
        if (_gifImages == nil || [_gifImages count] == 0){
            [self popupMessage:NSLS(@"kFailCreateGIF") title:nil];
        }
        else{
            self.tempGIFFilePath = [NSString stringWithFormat:@"%@/%@.gif", NSTemporaryDirectory(), [NSString GetUUID]];
            [GifManager createGifToPath:self.tempGIFFilePath byImages:_gifImages];
            if ([[NSFileManager defaultManager] fileExistsAtPath:self.tempGIFFilePath] == NO){
                [self popupMessage:NSLS(@"kFailCreateGIF") title:nil];
            }
            else{
                [self clickShareButton:nil];
            }
        }
    }else{
        self.playEndButton.hidden = YES;
    }
}

- (void)createImageAndSave:(ShowDrawView *)showView
{
    UIImage *image = [showView createImage];
    if ([DeviceDetection isIPAD]) {
        image = [image imageByScalingAndCroppingForSize:CGSizeMake(image.size.width/2, image.size.height/2)];
    }
    [_gifImages addObject:image];
    
}

- (void)didPlayDrawView:(ShowDrawView *)showDrawView AtActionIndex:(NSInteger)actionIndex pointIndex:(NSInteger)pointIndex
{
    if (_replayForCreateGif) {
        NSInteger actionCount = [showDrawView.drawActionList count];
        
        if (showDrawView.tag == REPLAY_TAG) {
            if (actionIndex < actionCount && actionIndex >= 0) {
                DrawAction *action = [showDrawView.drawActionList objectAtIndex:actionIndex];
                NSInteger pointCount = [action pointCount];
                if (pointCount < 1) {
                    return;
                }
                
                if (pointCount < POINT_COUNT_PER_FRAME) {
                    if (pointIndex == pointCount - 1) {
                        [self createImageAndSave:showDrawView];
                        NSLog(@"action Index: %d; point index: %d",actionIndex,pointIndex);
                    }
                    return;
                }
                
                if (pointIndex == pointCount - 1) 
                {
                    NSLog(@"action Index: %d; point index: %d",actionIndex,pointIndex);
                    [self createImageAndSave:showDrawView];
                }else if((pointIndex % POINT_COUNT_PER_FRAME) == (POINT_COUNT_PER_FRAME - 1 ) && (pointIndex + POINT_COUNT_PER_FRAME / 2) < pointCount)
                {
                    NSLog(@"action Index: %d; point index: %d",actionIndex,pointIndex);
                    [self createImageAndSave:showDrawView];
                }
            }
            
        }        
    }
}


@end
