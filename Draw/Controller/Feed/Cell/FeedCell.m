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
#import "UIImageView+WebCache.h"
@implementation FeedCell
@synthesize guessStatLabel;
@synthesize descLabel;
@synthesize userNameLabel;
@synthesize timeLabel;
@synthesize drawImageView;
@synthesize avatarView = _avatarView;
@synthesize showView = _showView;
@synthesize feed = _feed;

#define AVATAR_VIEW_FRAME ([DeviceDetection isIPAD] ?  CGRectMake(24, 18, 88, 88) : CGRectMake(12, 9, 36, 36))
#define FEED_CELL_HEIGHT ([DeviceDetection isIPAD] ?  228 : 100)
#define DESC_WIDTH ([DeviceDetection isIPAD] ?  400 : 181)
#define DESC_HEIGHT ([DeviceDetection isIPAD] ?  120 : 43)

#define DESC_FONT ([DeviceDetection isIPAD] ? [UIFont systemFontOfSize:25] : [UIFont systemFontOfSize:12])

+ (id)createCell:(id)delegate
{

    NSString* cellId = [self getCellIdentifier];
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        return nil;
    }
    FeedCell *cell = ((FeedCell*)[topLevelObjects objectAtIndex:0]);
    
    cell.delegate = delegate;
//    cell.drawImageView.callbackOnSetImage = cell;
//    cell.drawImageView.callbackOnCancel = cell;
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
    NSString *timeString = dateToTimeLineString(feed.createDate);
    [self.timeLabel setText:timeString];
}


- (void)updateDesc:(Feed *)feed
{
    CGPoint origin = self.descLabel.frame.origin;
    UIFont *font = DESC_FONT;
    CGSize maxSize = CGSizeMake(DESC_WIDTH, DESC_HEIGHT);
    CGSize labelSize = [feed.desc sizeWithFont:font constrainedToSize:maxSize 
         lineBreakMode:UILineBreakModeCharacterWrap];
    CGRect rect = CGRectMake(origin.x, origin.y, DESC_WIDTH, labelSize.height);
    self.descLabel.frame = rect;
    [self.descLabel setText:feed.desc];
    PPDebug(@"rect = %@, desc = %@", NSStringFromCGRect(rect),feed.desc);
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

- (void)cleanShowView
{
    [self.showView stop];
    [self.showView removeFromSuperview];
    [self setShowView:nil];
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

    if (drawFeed) {
        NSString *imageUrl = drawFeed.drawImageUrl;
        UIImage *image = drawFeed.drawImage;
        [self.drawImageView setImage:[[ShareImageManager defaultManager] 
                                      unloadBg]];
        if ([imageUrl length] != 0) {
            NSURL *url = [NSURL URLWithString:imageUrl];
            UIImage *defaultImage = [[ShareImageManager defaultManager] unloadBg];
            
            [self.drawImageView setImageWithURL:url placeholderImage:defaultImage success:^(UIImage *image, BOOL cached) {
                if (!cached) {
                    self.drawImageView.alpha = 0;
                    [UIView animateWithDuration:1 animations:^{
                    self.drawImageView.alpha = 1.0;
                    }];
                }else{
                    //                self.drawImage.alpha = 1.0;
                }
            } failure:^(NSError *error) {

            }];
            drawFeed.drawImage = nil;
        }else if(image){
            [self.drawImageView setImage:image];
        }else {//if(drawFeed.drawData){
//            [drawFeed ]
            [self cleanShowView];
            [drawFeed parseDrawData];
            Draw *draw = drawFeed.drawData;
            CGRect normalFrame = DRAW_VIEW_FRAME;
            CGRect currentFrame = self.drawImageView.frame;

            CGFloat xScale = currentFrame.size.width / normalFrame.size.width;
            CGFloat yScale = currentFrame.size.height / normalFrame.size.height;        
            self.showView = [[[ShowDrawView alloc] initWithFrame:self.drawImageView.frame] autorelease];
            self.showView.drawActionList = [DrawAction scaleActionList:draw.drawActionList xScale:xScale yScale:yScale];
            [self addSubview:self.showView];
            [self.showView show];
            drawFeed.drawImage = [self.showView createImage];

            [self.drawImageView setImage:drawFeed.drawImage];
            
            [self cleanShowView];

            drawFeed.drawData = nil;

            [[FeedManager defaultManager] saveFeed:[self opusIdForFeed:feed] largeImage:drawFeed.drawImage];

        }
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
    PPRelease(_showView);
    [super dealloc];
}
@end
