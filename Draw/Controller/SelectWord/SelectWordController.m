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
#import "DrawViewController.h"
#import "ShowDrawController.h"
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


@implementation SelectWordController
@synthesize clockLabel = _clockLabel;
@synthesize changeWordButton = _changeWordButton;
@synthesize titleLabel = _titleLabel;
@synthesize wordTableView = _wordTableView;
@synthesize wordArray = _wordArray;

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
    if (!hasPushController) {
        hasPushController = YES;        
        [DrawViewController startDraw:word fromController:self];
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
}


#pragma mark - View lifecycle

#define TOOLVIEW_CENTER ([DeviceDetection isIPAD] ? CGPointMake(605, 780) : CGPointMake(248, 344))
- (void)viewDidLoad
{
    [super viewDidLoad];
    toolView = [[ToolView alloc] initWithNumber:0];
    toolView.number = [[ItemManager defaultManager] tipsItemAmount];
    toolView.center = TOOLVIEW_CENTER;
       
    [self.view addSubview:toolView];

    self.wordArray = [[WordManager defaultManager]randDrawWordList];
    retainCount = PICK_WORD_TIME;
    [self.clockLabel setText:[NSString stringWithFormat:@"%d",retainCount]];
    
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    [self.changeWordButton setBackgroundImage:[imageManager orangeImage] forState:UIControlStateNormal];
    [self localeViewText];
    
    [self startTimer];
}


- (void)viewDidAppear:(BOOL)animated
{
    [drawGameService registerObserver:self];
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self clearUnPopupMessages];
    [drawGameService unregisterObserver:self];
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [self setWordTableView:nil];
    [self setWordArray:nil];
    [self setClockLabel:nil];
    [self setChangeWordButton:nil];
    [self setTitleLabel:nil];
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
    [super dealloc];
}
- (IBAction)clickChangeWordButton:(id)sender {
    if (toolView.number > 0 ) {
        [self startTimer];
        self.wordArray = [[WordManager defaultManager]randDrawWordList];
        [self.wordTableView reloadData];
        [[AccountService defaultService] consumeItem:ITEM_TYPE_TIPS amount:1];
        [toolView setNumber:[[ItemManager defaultManager]tipsItemAmount]];        
    }else{
        [self popupUnhappyMessage:NSLS(@"kNoTipItem") title:nil];
    }    
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
