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
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)startGameWithWord:(Word *)word
{
    DrawGameService *gameService = [DrawGameService defaultService];
    if (!hasPushController) {
        hasPushController = YES;
        DrawViewController *vc = [DrawViewController instance];
        vc.word = word;
        int language = 1; // TODO, use formal language from UserManager
        [gameService startDraw:word.text level:word.level language:language];
        [self.navigationController pushViewController:vc animated:NO];        
    }
    
}

- (void)handleTimer:(NSTimer *)theTimer
{
    --retainCount;
    if (retainCount <= 0) {
        [theTimer invalidate];
        theTimer = nil;
        [self startGameWithWord:[self.wordArray objectAtIndex:1]];
        retainCount = 0;
    }
    [self.clockLabel setText:[NSString stringWithFormat:@"%d",retainCount]];
    
}


- (void)localeViewText
{
    [self.titleLabel setText:NSLS(@"kPickWordTitle")];
    [self.changeWordButton setTitle:NSLS(@"kChangeWords") forState:UIControlStateNormal];
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    toolView = [[ToolView alloc] initWithNumber:2];
//    toolView.frame = CGRectMake(228, 318, 39, 52);
    toolView.center = CGPointMake(248, 344);
    [self.changeWordButton setEnabled:(toolView.number > 0)];    
    [self.view addSubview:toolView];

    self.wordArray = [[WordManager defaultManager]randDrawWordList];
    retainCount = PICK_WORD_TIME;
    [self.clockLabel setText:[NSString stringWithFormat:@"%d",retainCount]];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
    
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    [self.changeWordButton setBackgroundImage:[imageManager orangeImage] forState:UIControlStateNormal];
    [self localeViewText];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    self.wordArray = [[WordManager defaultManager]randDrawWordList];
    [self.wordTableView reloadData];
    [toolView decreaseNumber];
    [self.changeWordButton setEnabled:(toolView.number > 0)];    
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
@end
