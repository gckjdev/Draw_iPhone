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
#import "WordManager.h"
#import "Word.h"
#import "DeviceDetection.h"
#import "HJManagedImageV.h"
#import "PPApplication.h"

@implementation FeedCell
@synthesize guessStatLabel;
@synthesize descLabel;
@synthesize userNameLabel;
@synthesize timeLabel;
@synthesize drawImageView;
@synthesize avatarView = _avatarView;

@synthesize feed = _feed;

#define AVATAR_VIEW_FRAME ([DeviceDetection isIPAD] ?  CGRectMake(12, 20, 83, 82) : CGRectMake(5, 9, 35, 36))
#define SHOW_DRAW_VIEW_FRAME ([DeviceDetection isIPAD] ?  CGRectMake(530, 9, 175, 170) :CGRectMake(222, 4, 70, 72))
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
    cell.drawImageView.callbackOnSetImage = cell;
    cell.drawImageView.callbackOnCancel = cell;
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
    CGPoint origin = self.descLabel.frame.origin;
    UIFont *font = DESC_FONT;
    CGSize maxSize = CGSizeMake(DESC_WIDTH, 1000000);
    CGSize labelSize = [feed.desc sizeWithFont:font constrainedToSize:maxSize 
         lineBreakMode:UILineBreakModeWordWrap];
    CGRect rect = CGRectMake(origin.x, origin.y, DESC_WIDTH, labelSize.height);
    self.descLabel.frame = rect;
    [self.descLabel setText:feed.desc];
}


- (void)updateUser:(Feed *)feed
{
    //avatar
    NSString *avatar = [feed.feedUser avatar];
    NSString *userId = [feed.feedUser userId];
    BOOL gender = [feed.feedUser gender];
    [self.avatarView removeFromSuperview];
    [self.avatarView setDelegate:nil];
    self.avatarView = [[[AvatarView alloc] initWithUrlString:avatar 
                                                       frame:AVATAR_VIEW_FRAME 
                                                      gender:gender 
                                                       level:0] autorelease];
    self.avatarView.userId = userId;
    self.avatarView.delegate = self;
    [self addSubview:self.avatarView];
    
    //name
    if ([feed isMyFeed]) {
        [self.userNameLabel setText:NSLS(@"Me")];
    }else{
        [self.userNameLabel setText:feed.feedUser.nickName];
    }
}

- (void)updateGuessDesc:(Feed *)feed
{
    NSInteger guessTimes = 0;
    if (feed.isDrawType) {
        guessTimes = [(DrawFeed *)feed guessTimes];
    }else if(feed.isGuessType){
        guessTimes = [[(GuessFeed *)feed drawFeed] guessTimes];
    }
    if (guessTimes == 0) {
        [self.guessStatLabel setText:NSLS(@"kNoGuess")];
    }else{
        NSInteger correctTimes = 0;
        if (feed.isDrawType) {
            correctTimes = [(DrawFeed *)feed correctTimes];
        }else if(feed.feedType == FeedTypeGuess){
            correctTimes = [[(GuessFeed *)feed drawFeed] correctTimes];
        }
        NSString *desc = [NSString stringWithFormat:NSLS(@"kGuessStat"),guessTimes, correctTimes];
        [self.guessStatLabel setText:desc];        
    }
}

- (NSString *)opusIdForFeed:(Feed *)feed
{
    if (feed.isDrawType) {
        return feed.feedId;
    }else if(feed.isGuessType){
        return [[(GuessFeed *)feed drawFeed] feedId];
    }
    return nil;
}

-(void) managedImageSet:(HJManagedImageV*)mi
{
    [mi.loadingWheel stopAnimating];
}
-(void) managedImageCancelled:(HJManagedImageV*)mi
{
    [mi.loadingWheel stopAnimating];    
}


- (void)updateDrawView:(Feed *)feed
{
    DrawFeed *drawFeed = nil;
    if (feed.isDrawType) {
        drawFeed = (DrawFeed *)feed;
    }else if(feed.feedType == FeedTypeGuess)
    {
        drawFeed = [(GuessFeed *) feed drawFeed];
    }
    [self.drawImageView clear];
    if (drawFeed) {
        NSString *imageUrl = drawFeed.drawImageUrl;
        UIImage *image = drawFeed.drawImage;
        if ([imageUrl length] != 0) {
            [self.drawImageView showLoadingWheel];
            [self.drawImageView setUrl:[NSURL URLWithString:imageUrl]];    
        }else if(image){
            [self.drawImageView showLoadingWheel];
            [self.drawImageView setImage:image];
        }else if(drawFeed.drawData){
            Draw *draw = drawFeed.drawData;
            CGRect normalFrame = DRAW_VIEW_FRAME;
            CGRect currentFrame = self.drawImageView.frame;

            CGFloat xScale = currentFrame.size.width / normalFrame.size.width;
            CGFloat yScale = currentFrame.size.height / normalFrame.size.height;        
            ShowDrawView *showView = [[ShowDrawView alloc] initWithFrame:self.drawImageView.frame];
            showView.drawActionList = [DrawAction scaleActionList:draw.drawActionList xScale:xScale yScale:yScale];
            [self addSubview:showView];
            [showView release];
            drawFeed.drawImage = [showView createImage];
            //save image.
            [[ShareImageManager defaultManager] saveImage:drawFeed.drawImage withImageName:[self opusIdForFeed:feed] asyn:YES];
            [self.drawImageView setImage:drawFeed.drawImage];
            [showView removeFromSuperview];
            drawFeed.drawData = nil;
        }
        [GlobalGetImageCache() manage:self.drawImageView];
    }
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



- (void)didClickOnAvatar:(NSString*)userId
{
    if (delegate && [delegate respondsToSelector:@selector(didClickAvatar:nickName:gender:atIndexPath:)]) {
        FeedUser *author = self.feed.feedUser;
        [delegate didClickAvatar:author.userId 
                        nickName:author.nickName 
                          gender:author.gender 
                     atIndexPath:self.indexPath];
    }
}


- (void)dealloc {
    PPRelease(timeLabel);
    PPRelease(descLabel);
    PPRelease(userNameLabel);
    PPRelease(guessStatLabel);
    PPRelease(_avatarView);
    PPRelease(_feed);
    PPRelease(drawImageView);
    [super dealloc];
}
@end
