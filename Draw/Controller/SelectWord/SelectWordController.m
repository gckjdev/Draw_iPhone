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

@implementation SelectWordController
@synthesize clockLabel = _clockLabel;
@synthesize changeWordButton = _changeWordButton;
@synthesize titleLabel = _titleLabel;
@synthesize wordTableView = _wordTableView;
@synthesize wordArray = _wordArray;
@synthesize gameType = _gameType;
@synthesize timeBg = _timeBg;
@synthesize myWordsButton = _myWordsButton;

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
}


- (id)initWithType:(GameType)gameType
{
    self = [super init];
    if (self) {
        self.gameType = gameType;
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
            [OfflineDrawViewController startDraw:word fromController:self];
        }
    }
    [self resetTimer];
}

- (void)handleTimer:(NSTimer *)theTimer
{
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
    [super viewDidLoad];
    toolView = [[ToolView alloc] initWithNumber:0];
    toolView.number = [[ItemManager defaultManager] tipsItemAmount];
    toolView.center = TOOLVIEW_CENTER;
       
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
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [drawGameService registerObserver:self];
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
//    [self clearUnPopupMessages];
//    [drawGameService unregisterObserver:self];
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
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
    [_wordTableView release];
    [_clockLabel release];
    [_changeWordButton release];
    [_titleLabel release];
    [toolView release];
    [_wordArray release];
    [_timeBg release];
    [_myWordsButton release];
    [super dealloc];
}
- (IBAction)clickChangeWordButton:(id)sender {
    if (toolView.number > 0 ) {
        if ([self hasClock]) {
            [self startTimer];
        }
        self.wordArray = [[WordManager defaultManager]randDrawWordList];
        [self.wordTableView reloadData];
        [[AccountService defaultService] consumeItem:ITEM_TYPE_TIPS amount:1];
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
    Word *word = [Word wordWithText:aWord level:WordLeveLMedium];
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
