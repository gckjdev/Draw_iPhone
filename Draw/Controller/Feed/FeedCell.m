//
//  FeedCell.m
//  Draw
//
//  Created by  on 12-6-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FeedCell.h"
#import "TimeUtils.h"
#import "Feed.h"
#import "Draw.h"
#import "UserManager.h"
#import "ShareImageManager.h"
#import "StableView.h"
#import "ShowDrawView.h"
#import "DrawAction.h"
#import "FeedManager.h"
#import "WordManager.h"
#import "Word.h"
#import "DeviceDetection.h"

@implementation FeedCell
@synthesize guessStatLabel;
@synthesize descLabel;
@synthesize userNameLabel;
@synthesize timeLabel;
@synthesize actionButton;
@synthesize avatarView = _avatarView;
@synthesize drawView = _drawView;
@synthesize feed = _feed;

#define AVATAR_VIEW_FRAME ([DeviceDetection isIPAD] ?  CGRectMake(12, 20, 83, 82) : CGRectMake(5, 9, 35, 36))
#define SHOW_DRAW_VIEW_FRAME ([DeviceDetection isIPAD] ?  CGRectMake(530, 9, 170, 170) :CGRectMake(222, 4, 70, 72))
#define FEED_CELL_HEIGHT ([DeviceDetection isIPAD] ?  228 : 100)
#define DESC_WIDTH ([DeviceDetection isIPAD] ?  400 : 170)
#define DESC_FONT ([DeviceDetection isIPAD] ? [UIFont systemFontOfSize:14 * 2] : [UIFont systemFontOfSize:14])

+ (id)createCell:(id)delegate
{

    NSString* cellId = [self getCellIdentifier];
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    FeedCell *cell = ((FeedCell*)[topLevelObjects objectAtIndex:0]);
    
    cell.delegate = delegate;
    
    if (cell) {

        cell.drawView = [[[ShowDrawView alloc] initWithFrame:SHOW_DRAW_VIEW_FRAME]autorelease];
        [cell addSubview:cell.drawView];
        [cell.drawView setShowPenHidden:YES];
        cell.drawView.backgroundColor = [UIColor clearColor];
    }
    return cell;
}



+ (NSString*)getCellIdentifier
{
    return @"FeedCell";
}

+ (CGFloat)getCellHeight
{
    return FEED_CELL_HEIGHT;
    
}


- (void)updateTime:(Feed *)feed
{
    NSString *formate = @"yy-MM-dd HH:mm";
    NSString *timeString = dateToStringByFormat(feed.createDate, formate);
    [self.timeLabel setText:timeString];
}


- (void)updateDesc:(Feed *)feed
{
    NSString *desc = nil;
    NSString *creatorNick = [FeedManager opusCreatorForFeed:feed];
    NSString *word = feed.drawData.word.text;
    if (feed.drawData.languageType == ChineseType 
        && [LocaleUtils isTraditionalChinese]) {
        word = [WordManager changeToTraditionalChinese:word];
    }
    
    FeedActionDescType descType = [FeedManager feedActionDescFor:feed];
    switch (descType) {
        case FeedActionDescDrawed:
            desc = [NSString stringWithFormat:NSLS(@"kDrawDesc"), word];  
            break;
        case FeedActionDescDrawedNoWord:
            desc = NSLS(@"kDrawDescNoWord");  
            break;
        case FeedActionDescGuessed:
            desc = [NSString stringWithFormat:NSLS(@"kGuessRightDesc"),creatorNick, word];  
            break;
        case FeedActionDescGuessedNoWord:
            desc = [NSString stringWithFormat:NSLS(@"kGuessRightDescNoWord"), creatorNick];  
            break;
        case FeedActionDescTried:
            desc = [NSString stringWithFormat:NSLS(@"kTryGuessDesc"),creatorNick , word];  
            break;
        case FeedActionDescTriedNoWord:
            desc = [NSString stringWithFormat:NSLS(@"kTryGuessDescNoWord"), creatorNick];  
            break;

        default:
            break;
    }
    
    
    CGPoint origin = self.descLabel.frame.origin;
    UIFont *font = DESC_FONT;
    CGSize maxSize = CGSizeMake(DESC_WIDTH, 1000000);
    
    CGSize labelSize = [desc sizeWithFont:font constrainedToSize:maxSize 
         lineBreakMode:UILineBreakModeWordWrap];

    CGRect rect = CGRectMake(origin.x, origin.y, DESC_WIDTH, labelSize.height);
    self.descLabel.frame = rect;
    
    [self.descLabel setText:desc];
}

- (void)updateUser:(Feed *)feed
{
    //avatar
    [self.avatarView removeFromSuperview];
    self.avatarView = [[[AvatarView alloc] initWithUrlString:feed.avatar frame:AVATAR_VIEW_FRAME gender:feed.gender level:0] autorelease];
    [self addSubview:self.avatarView];
    
    //name
    [self.userNameLabel setText:[FeedManager userNameForFeed:feed]];
}

- (void)updateGuessDesc:(Feed *)feed
{
    if (feed.guessTimes == 0) {
        [self.guessStatLabel setText:NSLS(@"kNoGuess")];
    }else{
        NSInteger guessTimes = feed.guessTimes;
        NSInteger correctTimes = feed.correctTimes;
        NSString *desc = [NSString stringWithFormat:NSLS(@"kGuessStat"),guessTimes, correctTimes];
        [self.guessStatLabel setText:desc];        
    }
}




- (void)updateActionButton:(Feed *)feed
{
    ShareImageManager* imageManager = [ShareImageManager defaultManager];
    //self.actionButton.hidden = NO;
    [self.actionButton setBackgroundImage:[imageManager greenImage] forState:UIControlStateNormal];
    self.actionButton.userInteractionEnabled = YES;
    self.actionButton.selected = NO;

    
    ActionType type = [FeedManager actionTypeForFeed:feed];
    if (type == ActionTypeGuess) {
        [self.actionButton setTitle:NSLS(@"kIGuessAction") forState:UIControlStateNormal];
    }else if(type == ActionTypeOneMore)
    {
        [self.actionButton setTitle:NSLS(@"kOneMoreAction") forState:UIControlStateNormal];        
    }else if(type == ActionTypeCorrect){
        [self.actionButton setTitle:NSLS(@"kIGuessCorrect") forState:UIControlStateSelected];
        [self.actionButton setBackgroundImage:[imageManager normalButtonImage] forState:UIControlStateNormal];
        self.actionButton.userInteractionEnabled = NO;
        self.actionButton.selected = YES;
    }
//    else{
//        self.actionButton.hidden = YES;
//    }
}


- (void)updateDrawView:(Feed *)feed
{
    [self.drawView cleanAllActions];
    CGRect normalFrame = DRAW_VIEW_FRAME;
    CGRect currentFrame = SHOW_DRAW_VIEW_FRAME;
    CGFloat xScale = currentFrame.size.width / normalFrame.size.width;
    CGFloat yScale = currentFrame.size.height / normalFrame.size.height;
    
    self.drawView.drawActionList = [DrawAction scaleActionList:feed.drawData.drawActionList xScale:xScale yScale:yScale];
    [self.drawView play];
}
- (void)setCellInfo:(Feed *)feed
{
    self.feed = feed;
    [self updateDesc:feed];
    [self updateTime:feed];
    [self updateUser:feed];
    [self updateGuessDesc:feed];
    [self updateActionButton:feed];
    [self updateDrawView:feed];
}


- (IBAction)clickActionButton:(id)sender {
    //
    ActionType type = [FeedManager actionTypeForFeed:self.feed];
    if (type == ActionTypeGuess) {
        if (delegate && [delegate respondsToSelector:@selector(didClickGuessButtonOnFeed:)]) {
            [delegate didClickGuessButtonOnFeed:self.feed];
        }
    }else if(type == ActionTypeOneMore){
        if (delegate && [delegate respondsToSelector:@selector(didClickDrawOneMoreButtonAtIndexPath:)]) {
            [delegate didClickDrawOneMoreButtonAtIndexPath:self.indexPath];
        }
    }
}

- (void)dealloc {
    [timeLabel release];
    [descLabel release];
    [userNameLabel release];
    [guessStatLabel release];
    [actionButton release];
    [_drawView release];
    [_feed release];
    [super dealloc];
}
@end
