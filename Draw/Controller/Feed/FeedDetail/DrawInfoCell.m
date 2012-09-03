//
//  DrawInfoCell.m
//  Draw
//
//  Created by  on 12-9-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DrawInfoCell.h"
#import "ShareImageManager.h"
#import "CommonMessageCenter.h"
#import "DrawUtils.h"
#import "Draw.h"
#import "DrawAction.h"
#import "TimeUtils.h"
#import <QuartzCore/QuartzCore.h>

@implementation DrawInfoCell
@synthesize drawImage;
@synthesize timeLabel;
@synthesize actionButton;
@synthesize loadingActivity;
@synthesize drawBG;
@synthesize feed = _feed;
@synthesize showView = _showView;
@synthesize delegate = _delegate;

+ (id)createCell:(id<DrawInfoCellDelegate>)delegate
{
    NSString* cellId = [self getCellIdentifier];
    //    NSLog(@"cellId = %@", cellId);
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).  
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create %@ but cannot find cell object from Nib", cellId);
        return nil;
    }
    DrawInfoCell *cell = [topLevelObjects objectAtIndex:0];
    cell.delegate = delegate;
    return cell;
}

+ (NSString*)getCellIdentifier
{
    return @"DrawInfoCell";
}

+ (CGFloat)getCellHeight
{
    return 321.0f;
}


- (void)updateTime:(DrawFeed *)feed
{
    NSString *timeString = nil;
    if ([LocaleUtils isChinese]) {
        timeString = chineseBeforeTime(feed.createDate);
    } else {
        timeString = englishBeforeTime(feed.createDate);
    }
    
    if (timeString) {
        [self.timeLabel setText:timeString];
    }else {
        NSString *formate = @"yy-MM-dd HH:mm";
        timeString = dateToStringByFormat(feed.createDate, formate);
        [self.timeLabel setText:timeString];
    }
}


- (void)setCellInfo:(DrawFeed *)feed
{
    self.drawBG.layer.cornerRadius = 7.0;
    self.drawBG.layer.masksToBounds = YES;
    self.drawBG.center = self.drawImage.center;
    
    self.actionButton.hidden = YES;
    [self setFeed:feed];
    [[FeedService defaultService] getFeedByFeedId:feed.feedId delegate:self];
    [self updateTime:self.feed];
}



#define ACTION_TAG_GUESS 2012070201
#define ACTION_TAG_CHALLENGE 2012070202

- (void)updateActionButton:(DrawFeed *)feed
{
    if (feed.drawData == nil) {
        self.actionButton.hidden = YES;
        return;
    }
    
    ShareImageManager* imageManager = [ShareImageManager defaultManager];
    self.actionButton.hidden = NO;
    [self.actionButton setBackgroundImage:[imageManager greenImage] forState:UIControlStateNormal];
    self.actionButton.userInteractionEnabled = YES;
    self.actionButton.selected = NO;
    
    
    ActionType type = feed.actionType;
    if (type == ActionTypeGuess) {
        [self.actionButton setTitle:NSLS(@"kIGuessAction") forState:UIControlStateNormal];
        self.actionButton.tag = ACTION_TAG_GUESS;
        self.actionButton.hidden = NO;
    }else if(type == ActionTypeChallenge)
    {
        [self.actionButton setTitle:NSLS(@"kChallenge") forState:UIControlStateNormal];        
        self.actionButton.tag = ACTION_TAG_CHALLENGE;
        self.actionButton.hidden = NO;
    }else{
        self.actionButton.hidden = YES;
    }
    
}

- (void)updateShowView:(DrawFeed *)feed
{
    
//    self.drawImage.layer.cornerRadius = 10.0;
//    self.drawImage.layer.masksToBounds = YES;

    CGRect frame = self.drawImage.frame;
    
    self.showView = [[[ShowDrawView alloc] initWithFrame:frame] autorelease];
    self.showView.playSpeed = 1.0/36.0;
    [self.showView setShowPenHidden:YES];
    self.showView.delegate = self;
    [self.showView setBackgroundColor:[UIColor whiteColor]];
    [self.showView cleanAllActions];
    [self addSubview:self.showView];
    [self.drawImage setHidden:YES];
    [self.loadingActivity stopAnimating];
    
    CGRect normalFrame = DRAW_VIEW_FRAME;
    
    CGFloat xScale = frame.size.width / normalFrame.size.width;
    CGFloat yScale = frame.size.height / normalFrame.size.height;
    if (xScale == 1 && yScale == 1) {
        self.showView.drawActionList = [NSMutableArray arrayWithArray:self.feed.drawData.drawActionList];
    }else{
        self.showView.drawActionList = [DrawAction scaleActionList:_feed.drawData.drawActionList xScale:xScale yScale:yScale];
    }
    [self.showView show]; 
//    [self.drawBG setCenter:self.showView.center];
//    self.showView.layer.cornerRadius = 10.0;
//    self.showView.layer.masksToBounds = YES;
    
//    self.showView.tag = SHOW_VIEW_TAG_SMALL;
//    [self setShowshowView:SHOW_DRAW_VIEW_FRAME animated:NO];
}



- (void)didGetFeed:(DrawFeed *)feed
        resultCode:(NSInteger)resultCode
{
    if (resultCode == 0 && feed != nil) {        
        PPDebug(@"get draw feed succ: feedId = %@",feed.feedId);
        self.feed.timesSet = feed.timesSet;
        self.feed.drawData = feed.drawData;
        [self updateShowView:feed];
//        [self updateActionButton:feed];
        [self updateTime:feed];
        if (self.delegate && [self.delegate respondsToSelector:@selector(didUpdateShowView)]) {
            [self.delegate didUpdateShowView];
        }
    }else{
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kGetFeedFail") delayTime:1 isHappy:NO];
    }
}
- (void)didClickShowDrawView:(ShowDrawView *)showDrawView
{
    
}

- (void)dealloc {
    [drawImage release];
    [actionButton release];
    [timeLabel release];
    [loadingActivity release];
    PPRelease(_feed);
    [drawBG release];
    [super dealloc];
}
@end
