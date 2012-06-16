//
//  FeedDetailController.m
//  Draw
//
//  Created by  on 12-6-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FeedDetailController.h"
#import "PPDebug.h"
#import "LocaleUtils.h"
#import "FeedManager.h"
#import "TimeUtils.h"
#import "StableView.h"
#import "ShowDrawView.h"
#import "DrawAction.h"
#import "Draw.h"
#import "ShareImageManager.h"

@implementation FeedDetailController
@synthesize commentInput;
@synthesize inputViewBg;
@synthesize nickNameLabel;
@synthesize titleLabel;
@synthesize actionButton;
@synthesize sendButton;
@synthesize guessStatLabel;
@synthesize noCommentTipsLabel;
@synthesize timeLabel;
@synthesize feed = _feed;
@synthesize drawView = _drawView;
@synthesize avatarView = _avatarView;


#define AVATAR_VIEW_FRAME CGRectMake(14, 64, 82, 85)
#define SHOW_DRAW_VIEW_FRAME CGRectMake(215, 65, 90, 106)


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

- (id)initWithFeed:(Feed *)feed
{
    self = [super init];
    if (self) {
        self.feed = feed;
    }
    return self;
}


- (void)updateTime:(Feed *)feed
{
    NSString *timeString = dateToString(feed.createDate);
    [self.timeLabel setText:timeString];
}


- (void)updateUser:(Feed *)feed
{
    //avatar
//    [self.avatarView removeFromSuperview];
    self.avatarView = [[[AvatarView alloc] initWithUrlString:feed.avatar frame:AVATAR_VIEW_FRAME gender:feed.gender level:0] autorelease];
    [self.view addSubview:self.avatarView];
    
    //name
    [self.nickNameLabel setText:[FeedManager userNameForFeed:feed]];
}

- (void)updateGuessDesc:(Feed *)feed
{
    if (feed.matchTimes == 0) {
        [self.guessStatLabel setText:NSLS(@"kNoGuess")];
    }else{
        NSInteger guessTimes = feed.matchTimes;
        NSInteger correctTimes = feed.correctTimes;
        NSString *desc = [NSString stringWithFormat:NSLS(@"kGuessStat"),guessTimes, correctTimes];
        [self.guessStatLabel setText:desc];        
    }
}




- (void)updateActionButton:(Feed *)feed
{
    UIImage *bgImage = [[ShareImageManager defaultManager] greenImage];
    [self.actionButton setBackgroundImage:bgImage forState:UIControlStateNormal];
    
    self.actionButton.hidden = NO;
    ActionType type = [FeedManager actionTypeForFeed:feed];
    if (type == ActionTypeGuess) {
        [self.actionButton setTitle:NSLS(@"kIGuessAction") forState:UIControlStateNormal];
    }else if(type == ActionTypeOneMore)
    {
        [self.actionButton setTitle:NSLS(@"kOneMoreAction") forState:UIControlStateNormal];        
    }else{
        self.actionButton.hidden = YES;
    }
}


- (void)updateDrawView:(Feed *)feed
{
    self.drawView = [[[ShowDrawView alloc] initWithFrame:SHOW_DRAW_VIEW_FRAME] autorelease];
    [self.drawView setShowPenHidden:YES];
    [self.view addSubview:_drawView];
    [self.drawView cleanAllActions];
    CGRect normalFrame = DRAW_VEIW_FRAME;
    CGRect currentFrame = SHOW_DRAW_VIEW_FRAME;
    CGFloat xScale = currentFrame.size.width / normalFrame.size.width;
    CGFloat yScale = currentFrame.size.height / normalFrame.size.height;
    
    self.drawView.drawActionList = [DrawAction scaleActionList:feed.drawData.drawActionList xScale:xScale yScale:yScale];
    [self.drawView play];
}

#define INPUT_BG_TAG 2012061501
- (void)updateInputView:(Feed *)feed
{
    self.inputViewBg.image = [[ShareImageManager defaultManager] inputImage];
}

- (void)updateCommentTableView:(Feed *)feed
{
    //load data.
}

- (void)updateSendButton:(Feed *)feed
{
    //load data.
    [self.sendButton setBackgroundImage:[[ShareImageManager defaultManager] greenImage]forState:UIControlStateNormal];
    [self.sendButton setTitle:NSLS(@"kComment") forState:UIControlStateNormal];

}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self updateTime:_feed];
    [self updateUser:_feed];
    [self updateGuessDesc:_feed];
    [self updateActionButton:_feed];
    [self updateDrawView:_feed];
    [self updateInputView:_feed];
    [self updateCommentTableView:_feed];
    [self updateSendButton:_feed];
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setNoCommentTipsLabel:nil];
    [self setTimeLabel:nil];
    [self setGuessStatLabel:nil];
    [self setActionButton:nil];
    [self setNickNameLabel:nil];
    [self setCommentInput:nil];
    [self setSendButton:nil];
    [self setInputViewBg:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)clickActionButton:(id)sender {
}

- (IBAction)clickBackButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)dealloc {
    PPRelease(_feed);
    PPRelease(_avatarView);
    PPRelease(_drawView);
    [titleLabel release];
    [noCommentTipsLabel release];
    [timeLabel release];
    [guessStatLabel release];
    [actionButton release];
    [nickNameLabel release];
    [commentInput release];
    [sendButton release];
    [inputViewBg release];
    [super dealloc];
}
- (IBAction)clickSendButton:(id)sender {
}
@end
