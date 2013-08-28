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
#import "UIViewUtils.h"
#import "CommentCell.h"
#import "UIImageUtil.h"

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
#define DESC_WIDTH ([DeviceDetection isIPAD] ?  400 : 181)
#define DESC_HEIGHT ([DeviceDetection isIPAD] ?  120 : 43)
#define NON_DESC_HEIGHT (FEED_CELL_HEIGHT - DESC_HEIGHT)

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

+ (CGFloat)getCellHeight:(Feed *)feed
{
    if ([Feed isKindOfClass:[CommentFeed class]]){
        NSString *comment = [feed desc];
        UIFont *font = DESC_FONT; //[UIFont systemFontOfSize:DESC_FONT];
//        PPDebug(@"start to cal height, comment = %@",comment);
        CGSize commentSize = [comment sizeWithFont:font constrainedToSize:CGSizeMake(DESC_WIDTH, 10000000) lineBreakMode:UILineBreakModeCharacterWrap];
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
    UIFont *font = DESC_FONT;
    CGSize maxSize = CGSizeMake(DESC_WIDTH, DESC_HEIGHT);
    CGSize labelSize = [feed.desc sizeWithFont:font constrainedToSize:maxSize 
         lineBreakMode:UILineBreakModeCharacterWrap];
    CGRect rect = CGRectMake(origin.x, origin.y, DESC_WIDTH, labelSize.height);
    self.descLabel.frame = rect;
    
    [self.descLabel setText:[feed displayText]];
    
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
    DrawFeed* drawFeed = [self drawFeed:feed];
    if (feed.isDrawType) {
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
        if (feed.isDrawType) {
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
    
//    if (feed.isDrawType) {
//        return drawFeed.feedId;        
//    }else if(feed.isGuessType){
//        return [[(GuessFeed *)feed drawFeed] feedId];
//    }
//    else if ([feed respondsToSelector:@selector(drawFeed)]){
//        return [[feed performSelector:@selector(drawFeed)] feedId];
//    }
//    return nil;
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
//    if (feed.isDrawType) {
//        drawFeed = (DrawFeed *)feed;
//    }else if(feed.feedType == FeedTypeGuess)
//    {
//        drawFeed = [(GuessFeed *) feed drawFeed];
//    }
//    else if ([feed respondsToSelector:@selector(drawFeed)]){
//        drawFeed = [feed performSelector:@selector(drawFeed)];
//    }

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
//                    self.drawImageView setImageW
//                    [self.drawImageView scaleWithSize:image.size anchorType:AnchorTypeCenter constType:ConstTypeHeight];
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
//            [self.drawImageView scaleWithSize:image.size anchorType:AnchorTypeCenter constType:ConstTypeHeight];            
            [self.drawImageView setImage:image];
        }else {
            
            //TODO Show View with Data
//            [self cleanShowView];
//            [self addSubview:self.showView];
//            [self.showView show];
//            drawFeed.drawImage = [self.showView createImage];
//
//            [self.drawImageView setImage:drawFeed.drawImage];
//            
//            [self cleanShowView];
//
//            drawFeed.drawData = nil;
//
//            [[FeedManager defaultManager] saveFeed:[self opusIdForFeed:feed] largeImage:drawFeed.drawImage];
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
    self.descLabel.textColor = COLOR_ORANGE;
    self.timeLabel.textColor = COLOR_YELLOW;
    self.guessLabel.textColor = COLOR_GREEN;
    self.correctLabel.textColor = COLOR_GREEN;
    
    SET_VIEW_ROUND_CORNER(self.drawImageView);
    self.avatarView.layer.borderWidth = (ISIPAD ? 4 : 2);
    self.avatarView.layer.borderColor = [COLOR_GREEN CGColor];
    
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
