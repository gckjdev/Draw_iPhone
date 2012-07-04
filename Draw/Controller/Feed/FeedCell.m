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


- (void)updateDesc:(Feed *)feed
{
    NSString *desc = @"";
    NSString *creatorNick = [FeedManager opusCreatorForFeed:feed];
    NSString *word = feed.drawData.word.text;
    
    NSString *targetNick= [FeedManager targetNameForFeed:feed];
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
            
        case FeedActionDescDrawedToUser:
            desc = [NSString stringWithFormat:NSLS(@"kDrawToUserDesc"), word, targetNick];  
            break;
            
        case FeedActionDescDrawedToUserNoWord:
            desc = [NSString stringWithFormat:NSLS(@"kDrawToUserNoWordDesc"),targetNick];  
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
    
    PPDebug(@"<UpdateUser> before: retainCount = %d", [self.avatarView retainCount]);
    
    [self.avatarView removeFromSuperview];
    [self.avatarView setDelegate:nil];
    self.avatarView = [[[AvatarView alloc] initWithUrlString:feed.avatar frame:AVATAR_VIEW_FRAME gender:feed.gender level:0] autorelease];
    self.avatarView.userId = feed.userId;
    self.avatarView.delegate = self;
    [self addSubview:self.avatarView];
    
    //name
    [self.userNameLabel setText:[FeedManager userNameForFeed:feed]];
    
    PPDebug(@"<UpdateUser> after: retainCount = %d", [self.avatarView retainCount]);
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

- (void)didClickOnAvatar:(NSString*)userId
{
    if (delegate && [delegate respondsToSelector:@selector(didClickAvatar:nickName:gender:atIndexPath:)]) {
        [delegate didClickAvatar:self.feed.userId 
                        nickName:self.feed.nickName 
                          gender:self.feed.gender 
                     atIndexPath:self.indexPath];
    }
}


- (void)dealloc {
    [_drawView cleanAllActions];
    PPRelease(timeLabel);
    PPRelease(descLabel);
    PPRelease(userNameLabel);
    PPRelease(guessStatLabel);
    PPRelease(_drawView);
    PPRelease(_avatarView);
    PPRelease(_feed);
    [super dealloc];
}
@end
