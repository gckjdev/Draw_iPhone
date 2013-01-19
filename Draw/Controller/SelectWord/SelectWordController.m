//
//  SelectWordController.m
//  Draw
//
//  Created by  on 12-3-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SelectWordController.h"
#import "Word.h"
#import "WordManager.h"
#import "SelectWordCell.h"
#import "OnlineDrawViewController.h"
#import "DrawGameService.h"
#import "LocaleUtils.h"
#import "UserManager.h"
#import "ShareImageManager.h"
#import "StableView.h"
#import "RoomController.h"
#import "ItemManager.h"
#import "AccountService.h"
#import "ItemType.h"
#import "DeviceDetection.h"
#import "OfflineDrawViewController.h"
#import "CustomWordManager.h"
#import "AdService.h"

@implementation SelectWordController
@synthesize clockLabel = _clockLabel;
@synthesize changeWordButton = _changeWordButton;
@synthesize titleLabel = _titleLabel;
@synthesize wordTableView = _wordTableView;
@synthesize wordArray = _wordArray;
@synthesize gameType = _gameType;
@synthesize timeBg = _timeBg;
@synthesize myWordsButton = _myWordsButton;
@synthesize targetUid = _targetUid;
@synthesize adView = _adView;

+ (void)startSelectWordFrom:(UIViewController *)controller gameType:(GameType)gameType
{
    SelectWordController *sc = [[SelectWordController alloc] initWithType:gameType];
    [controller.navigationController pushViewController:sc animated:YES];
    [sc release];
    
}

+ (void)startSelectWordFrom:(UIViewController *)controller targetUid:(NSString *)targetUid
{
    SelectWordController *sc = [[SelectWordController alloc] initWithTargetUid:targetUid];
    [controller.navigationController pushViewController:sc animated:YES];
    [sc release];
}


#define PICK_WORD_TIME 10

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        hasPushController = NO;
        drawGameService = [DrawGameService defaultService];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    [[AdService defaultService] clearAdView:_adView];
    [self setAdView:nil];
}


- (id)initWithType:(GameType)gameType
{
    self = [super init];
    if (self) {
        self.gameType = gameType;
    }
    return self;
}

- (id)initWithTargetUid:(NSString *)targetUid
{
    self = [super init];
    if (self) {
        self.gameType = OfflineDraw;
        self.targetUid = targetUid;
    }
    return self;    
}

- (id)init
{
    self = [super init];
    if (self) {
        self.gameType = OnlineDraw;
    }
    return self;
}


- (void)resetTimer
{
    if (_timer) {
        if ([_timer isValid]) {
            [_timer invalidate];
        }
        _timer = nil;
    }
    retainCount = PICK_WORD_TIME;
}

- (void)startTimer
{
    [self resetTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
}

- (void)startGameWithWord:(Word *)word
{
    [self clearUnPopupMessages];
    [drawGameService unregisterObserver:self];
    if (!hasPushController) {
        hasPushController = YES;        
        if (self.gameType == OnlineDraw) {
            [OnlineDrawViewController startDraw:word fromController:self];            
        }else{
//            [OfflineDrawViewController startDraw:word fromController:self targetUid:self.targetUid];
            [OfflineDrawViewController startDraw:word fromController:self startController:nil targetUid:self.targetUid];
        }
    }
    [self resetTimer];
}

- (void)handleTimer:(NSTimer *)theTimer
{
    PPDebug(@"<SelectWordController> handle timer");    
    
    --retainCount;
    if (retainCount <= 0) {
        [self startGameWithWord:[self.wordArray objectAtIndex:1]];
        [self resetTimer];
    }
    [self.clockLabel setText:[NSString stringWithFormat:@"%d",retainCount]];
}

- (void)localeViewText
{
    [self.titleLabel setText:NSLS(@"kPickWordTitle")];
    [self.changeWordButton setTitle:NSLS(@"kChangeWords") forState:UIControlStateNormal];
    [self.myWordsButton setTitle:NSLS(@"kMyWords") forState:UIControlStateNormal];
}


- (BOOL)hasClock
{
    return  (self.gameType == OnlineDraw);
}

#pragma mark - View lifecycle

#define TOOLVIEW_CENTER ([DeviceDetection isIPAD] ? CGPointMake(615, 780) : CGPointMake(272, 344))
- (void)viewDidLoad
{
    CGFloat originY = [DeviceDetection screenSize].height - 50 - 20;
    /*
    self.adView = [[AdService defaultService] createAdInView:self
                                                       frame:CGRectMake(0, originY, 320, 50) 
                                                   iPadFrame:CGRectMake(112, 883, 320, 50)
                                                     useLmAd:NO];        
    */
    
    [super viewDidLoad];
    toolView = [[ToolView alloc] initWithNumber:0];
    toolView.number = [[ItemManager defaultManager] tipsItemAmount];
    toolView.center = TOOLVIEW_CENTER;
    toolView.autoresizingMask = !UIViewAutoresizingFlexibleBottomMargin |UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    
    [self.view addSubview:toolView];

    self.wordArray = [[WordManager defaultManager]randDrawWordList];
    
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    [self.changeWordButton setBackgroundImage:[imageManager orangeImage] forState:UIControlStateNormal];
    [self.myWordsButton setBackgroundImage:[imageManager greenImage] forState:UIControlStateNormal];
    
    [self localeViewText];
    
    if ([self hasClock]) {
        retainCount = PICK_WORD_TIME;
        [self.clockLabel setText:[NSString stringWithFormat:@"%d",retainCount]];    
        [self startTimer];        
    }else{
        self.timeBg.hidden = YES;
        self.clockLabel.hidden = YES;
    }
    
    
    if ([[UserManager defaultManager] getLanguageType] == EnglishType) {
        self.myWordsButton.hidden = YES;
    }
}


- (void)viewDidAppear:(BOOL)animated
{
    
    [drawGameService registerObserver:self];
    [super viewDidAppear:animated];

    /*
    if (self.adView == nil){
        CGFloat originY = [DeviceDetection screenSize].height - 50 - 20;
        self.adView = [[AdService defaultService] createAdInView:self
                                                           frame:CGRectMake(0, originY, 320, 50) 
                                                       iPadFrame:CGRectMake(112, 883, 320, 50)
                                                         useLmAd:NO];
    }
    */
}

- (void)viewDidDisappear:(BOOL)animated
{
//    [self clearUnPopupMessages];
//    [drawGameService unregisterObserver:self];
    
    [[AdService defaultService] clearAdView:_adView];
    [self setAdView:nil];

    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [[AdService defaultService] clearAdView:_adView];
    [self setAdView:nil];
    
    [self setWordTableView:nil];
    [self setWordArray:nil];
    [self setClockLabel:nil];
    [self setChangeWordButton:nil];
    [self setTitleLabel:nil];
    [self setTimeBg:nil];
    [self setMyWordsButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc {
    
    [[AdService defaultService] clearAdView:_adView];
    PPRelease(_adView);    
    PPRelease(_wordTableView);
    PPRelease(_clockLabel);
    PPRelease(_changeWordButton);
    PPRelease(_titleLabel);
    PPRelease(toolView);
    PPRelease(_wordArray);
    PPRelease(_myWordsButton);
    PPRelease(_timeBg);
    PPRelease(_targetUid);
    [super dealloc];
}
- (IBAction)clickChangeWordButton:(id)sender {
    if (toolView.number > 0 ) {
        if ([self hasClock]) {
            [self startTimer];
        }
        self.wordArray = [[WordManager defaultManager]randDrawWordList];
        [self.wordTableView reloadData];
        [[AccountService defaultService] consumeItem:ItemTypeTips amount:1];
        [toolView setNumber:[[ItemManager defaultManager]tipsItemAmount]];        
    }else{
        [self popupUnhappyMessage:NSLS(@"kNoTipItem") title:nil];
    }    
}

- (IBAction)clickMyWordsButton:(id)sender {
    if ([[[CustomWordManager defaultManager] findAllWords] count] == 0) {
        [self popupUnhappyMessage:NSLS(@"kNoCustomWords") title:nil];
    }else {
        SelectCustomWordView *customWordView = [SelectCustomWordView createView:self];
        [customWordView showInView:self.view];
    }
}

- (void)didSelecCustomWord:(NSString *)aWord
{
    Word *word = [Word cusWordWithText:aWord];
    [self startGameWithWord:word];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SelectWordCell *cell = [tableView dequeueReusableCellWithIdentifier:[SelectWordCell getCellIdentifier]];
    if (cell == nil) {
        cell = [SelectWordCell createCell:self];
    }
    
    Word *word = [self.wordArray objectAtIndex:indexPath.row];
    [cell setCellInfo:word];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Word *word = [self.wordArray objectAtIndex:indexPath.row];
    [self startGameWithWord:word];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [SelectWordCell getCellHeight];
}

- (void)didGameTurnComplete:(GameMessage *)message
{
    [self popupUnhappyMessage:NSLS(@"kAllUserQuit") title:nil];
    [RoomController returnRoom:self startNow:NO];
}



@end
