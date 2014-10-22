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
#import "UIImageView+Extend.h"
#import "UIViewUtils.h"
#import "CommentCell.h"
#import "UIImageUtil.h"
#import "StringUtil.h"

@implementation FeedCell
@synthesize guessLabel;
@synthesize descLabel;
@synthesize userNameLabel;
@synthesize timeLabel;
@synthesize drawImageView;
@synthesize avatarView = _avatarView;
@synthesize showView = _showView;
@synthesize feed = _feed;

#define AVATAR_VIEW_FRAME ([DeviceDetection isIPAD] ?  CGRectMake(16, 20, 88, 88) : CGRectMake(8, 10, 36, 36))
#define FEED_CELL_HEIGHT ([DeviceDetection isIPAD] ?  235 : 108)
#define DESC_WIDTH ([DeviceDetection isIPAD] ?  360 : 170)
#define DESC_HEIGHT ([DeviceDetection isIPAD] ?  120 : 43)
#define NON_DESC_HEIGHT (FEED_CELL_HEIGHT - DESC_HEIGHT)


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

+ (CGFloat)getCellHeight:(Feed *)feed
{
    if ([Feed isKindOfClass:[CommentFeed class]]){
        NSString *comment = [feed desc];
        UIFont *font = [ShareUIManager timelineContentFont];
        CGSize commentSize = [comment sizeWithMyFont:font constrainedToSize:CGSizeMake(DESC_WIDTH, 10000000) lineBreakMode:NSLineBreakByCharWrapping];
        CGFloat height = NON_DESC_HEIGHT + commentSize.height;
        if (height <= FEED_CELL_HEIGHT){
            height = FEED_CELL_HEIGHT;
        }
        
//        PPDebug(@"comment = %@,height = %f", comment,height);
        return height;
    }
    else{
        return FEED_CELL_HEIGHT;
    }
    
}

- (DrawFeed*)drawFeed:(Feed *)feed
{
    if ([feed isKindOfClass:[DrawFeed class]]) {
        return (DrawFeed*)feed;
    }else if(feed.isGuessType){
        return [(GuessFeed *)feed drawFeed];
    }
    else if ([feed respondsToSelector:@selector(drawFeed)]){
        return [feed performSelector:@selector(drawFeed)];
    }
    else{
        return nil;
    }
}

- (void)updateTime:(Feed *)feed
{
    NSString *timeString = dateToTimeLineString(feed.createDate);
    [self.timeLabel setText:timeString];
}


- (void)updateDesc:(Feed *)feed
{
    CGPoint origin = self.descLabel.frame.origin;
    UIFont *font = [ShareUIManager timelineContentFont];
    CGSize maxSize = CGSizeMake(DESC_WIDTH, DESC_HEIGHT);
    CGSize labelSize = [feed.desc sizeWithMyFont:font constrainedToSize:maxSize 
         lineBreakMode:NSLineBreakByCharWrapping];
    CGRect rect = CGRectMake(origin.x, origin.y, DESC_WIDTH, labelSize.height);
    self.descLabel.frame = rect;
    
    [self.descLabel setText:[feed displayText]];
    
//    PPDebug(@"rect = %@, desc = %@", NSStringFromCGRect(rect),feed.desc);
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
                                                       level:0
                                                         vip:feed.feedUser.vip] autorelease];
    self.avatarView.userId = userId;
    self.avatarView.isVIP = feed.feedUser.vip;
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
    DrawFeed* drawFeed = [self drawFeed:feed];
    if (feed.isOpusType) {
        guessTimes = [drawFeed guessTimes];
    }else if(feed.isGuessType){
        guessTimes = [drawFeed guessTimes];
    }
    
    self.guessImageView.hidden = NO;
    self.correctImageView.hidden = NO;
    
    if ([drawFeed isContestFeed]){
        // for contest, no display
        [self.guessLabel setText:@""];
        [self.correctLabel setText:@""];
        self.guessImageView.hidden = YES;
        self.correctImageView.hidden = YES;
    }
    else if (guessTimes == 0) {
//        [self.guessStatLabel setText:NSLS(@"kNoGuess")];
        [self.guessLabel setText:@"0"];
        [self.correctLabel setText:@"0"];
    }else{
        NSInteger correctTimes = 0;
        if (feed.isOpusType) {
            correctTimes = [drawFeed correctTimes];
        }else if(feed.feedType == FeedTypeGuess){
            correctTimes = [drawFeed correctTimes];
        }
//        NSString *desc = [NSString stringWithFormat:NSLS(@"kGuessStat"),guessTimes, correctTimes];
//        [self.guessLabel setText:desc];
        
        [self.guessLabel setText:[NSString stringWithFormat:@"%d", guessTimes]];
        [self.correctLabel setText:[NSString stringWithFormat:@"%d", correctTimes]];
    }
}

- (NSString *)opusIdForFeed:(Feed *)feed
{
    DrawFeed* drawFeed = [self drawFeed:feed];
    return [drawFeed feedId];
}

- (void)cleanShowView
{
    [self.showView stop];
    [self.showView removeFromSuperview];
    [self setShowView:nil];
}
- (void)updateDrawView:(Feed *)feed
{
    DrawFeed *drawFeed = [self drawFeed:feed];
    if (drawFeed) {
        NSString *imageUrl = drawFeed.drawImageUrl;
        [self.drawImageView setImage:[[ShareImageManager defaultManager] 
                                      unloadBg]];
        PPDebug(@"<updateDrawView> image url = %@", imageUrl);
        
        if ([imageUrl length] != 0) {
            NSURL *url = [NSURL URLWithString:imageUrl];
            UIImage *defaultImage = [[ShareImageManager defaultManager] unloadBg];
            
            [self.drawImageView setImageWithUrl:url
                               placeholderImage:defaultImage
                                    showLoading:YES
                                       animated:YES];
//            drawFeed.drawImage = self.drawImageView.image;
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

    [self setCellAppearance];

}

- (void)setCellAppearance{
    
    self.userNameLabel.textColor = COLOR_BROWN;
    self.descLabel.textColor = COLOR_BROWN;
    self.timeLabel.textColor = COLOR_GRAY_TEXT;
    self.guessLabel.textColor = COLOR_GREEN;
    self.correctLabel.textColor = COLOR_GREEN;
    
    
    self.userNameLabel.font = [ShareUIManager timelineNickFont];
    self.timeLabel.font = [ShareUIManager timelineTimeFont];
    self.descLabel.font = [ShareUIManager timelineContentFont];
    self.guessLabel.font = [ShareUIManager timelineStatisticsFont];
    self.correctLabel.font = [ShareUIManager timelineStatisticsFont];

    
    SET_VIEW_ROUND_CORNER(self.drawImageView);
    [self.bgImageView setImage:[ShareImageManager bubleImage]];
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
    PPRelease(guessLabel);
    PPRelease(_avatarView);
    PPRelease(_feed);
    PPRelease(drawImageView);
    PPRelease(_showView);
    [_correctLabel release];
    [_bgImageView release];
    [_guessImageView release];
    [_correctImageView release];
    [super dealloc];
}
@end
