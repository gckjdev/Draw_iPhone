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
#import "UIImageView+WebCache.h"
#import "DrawUserInfoView.h"

@implementation DrawInfoCell
@synthesize drawImage;
@synthesize timeLabel;
@synthesize drawToButton = _drawToButton;
@synthesize loadingActivity;
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
    if ([DeviceDetection isIPAD]) {
        return 520.0f;
    }
    return 252.0f;
}

- (void)initTargetUser:(NSString *)userId nickName:(NSString *)nickName
{
    if (_targetUser == nil) {
        _targetUser = [[FeedUser alloc] initWithUserId:userId nickName:nickName avatar:nil gender:NO];
    }else{
        [_targetUser setUserId:userId];
        [_targetUser setNickName:nickName];
    }
}

- (void)updateDrawToUserInfo:(DrawFeed*)feed
{
    if ([feed isKindOfClass:[DrawToUserFeed class]]) {
        DrawToUserFeed *drawToUserFeed = (DrawToUserFeed*)feed;
        [self initTargetUser:[[drawToUserFeed targetUser] userId] nickName:[[drawToUserFeed targetUser] nickName]]; 
        NSString *targetUserName = nil;
        if ([[UserManager defaultManager] isMe:_targetUser.userId]) {
            targetUserName = NSLS(@"kMe");
        }else{
            targetUserName = _targetUser.nickName;
        }
        targetUserName = [NSString stringWithFormat:NSLS(@"kDrawToUserByUser"), targetUserName];

        [self.drawToButton setTitle:targetUserName forState:UIControlStateNormal];
    } else {
        [self.drawToButton setTitle:nil forState:UIControlStateNormal];
    }
    
}


- (void)updateTime:(DrawFeed *)feed
{
    NSString *timeString = dateToTimeLineString(feed.createDate);
    [self.timeLabel setText:timeString];    
}


- (void)showDrawView:(DrawFeed *)feed
{
        if (![feed hasDrawActions]) {
            return;
        }

        [feed parseDrawData];
        CGRect frame = self.drawImage.frame;
        self.showView = [[[ShowDrawView alloc] initWithFrame:frame] autorelease];
        self.showView.playSpeed = 1.0/50.0;
        [self.showView setShowPenHidden:YES];
        self.showView.delegate = self;
        [self.showView setBackgroundColor:[UIColor whiteColor]];
        [self.showView cleanAllActions];
        [self addSubview:self.showView];
        [self.drawImage setHidden:YES];
        
        CGRect normalFrame = DRAW_VIEW_FRAME;
        
        CGFloat xScale = frame.size.width / normalFrame.size.width;
        CGFloat yScale = frame.size.height / normalFrame.size.height;
        if (xScale == 1 && yScale == 1) {
            self.showView.drawActionList = [NSMutableArray arrayWithArray:feed.drawData.drawActionList];
        }else{
            self.showView.drawActionList = [DrawAction scaleActionList:feed.drawData.drawActionList xScale:xScale yScale:yScale];
        }
        [self.showView show];
        UIImage *image = [self.showView createImage];
        //remove the show view after create the image.
        [self.showView removeFromSuperview];
        self.showView = nil;
        self.feed.largeImage = image;
        [self.drawImage setImage:self.feed.largeImage];
        [self.drawImage setHidden:NO];

        [self.loadingActivity stopAnimating];
    
        //cache image
        [[FeedManager defaultManager] saveFeed:feed.feedId largeImage:image];
        feed.drawData = nil;
}

- (void)updateShowView:(DrawFeed *)feed
{
    if ([feed.drawImageUrl length] != 0 /*&& (![DeviceDetection isIPAD] || feed.deviceType == DeviceTypeIPad)*/) {
        [self.drawImage setImageWithURL:[NSURL URLWithString:feed.drawImageUrl] placeholderImage:[[ShareImageManager defaultManager] unloadBg] success:^(UIImage *image, BOOL cached) {
            PPDebug(@"<download image> %@ success", feed.drawImageUrl);
            self.feed.largeImage = nil;
            [self loadImageFinish];
        } failure:^(NSError *error) {
            PPDebug(@"<download image> %@ failure, error=%@", feed.drawImageUrl, [error description]);
            [self.loadingActivity stopAnimating];
        }];
    }else if (self.feed.largeImage) {
        [self.drawImage setImage:self.feed.largeImage];
        [self loadImageFinish];
    }else{
        [self showDrawView:feed];
        [self loadImageFinish];
    }

}

- (void)loadImageFinish
{
    [self.loadingActivity stopAnimating];
    if (_delegate && [_delegate respondsToSelector:@selector(didLoadDrawPicture)]) {
        [_delegate didLoadDrawPicture];
    }
}



- (IBAction)clickToUser:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(didClickDrawToUser:nickName:)]) {
        [_delegate didClickDrawToUser:_targetUser.userId nickName:_targetUser.nickName];
    }
}

- (void)setCellInfo:(DrawFeed *)feed
{    
    [self setFeed:feed];
    [self updateTime:self.feed];
    [self updateDrawToUserInfo:feed];
    [self.loadingActivity setCenter:self.drawImage.center];
    if ([feed hasDrawActions]) {
        PPDebug(@"<setCellInfo>:DrawInfoCell have drawData. start to showView");
        [self updateShowView:feed];
        [self updateTime:feed];
        return;
    } 
    PPDebug(@"<setCellInfo>:DrawInfoCell have no drawData. start to load data");
    
//    if (self.feed.largeImage == nil) {
//        self.feed.largeImage = [[FeedManager defaultManager] largeImageForFeedId:self.feed.feedId];
//        if(self.feed.largeImage){
//            [self.drawImage setImage:self.feed.largeImage];
//        }
//    }
    if (!_isLoading) {
        _getTimes = 1;
        [[FeedService defaultService] getFeedByFeedId:feed.feedId delegate:self];
        _isLoading = YES;
    }
}


#define TRY_GET_FEED_TIMES 3
- (void)didGetFeed:(DrawFeed *)feed
        resultCode:(NSInteger)resultCode
         fromCache:(BOOL)fromCache
{
    _isLoading = NO;
    if (resultCode == 0 && feed != nil) {        
        
        PPDebug(@"get draw feed succ: feedId = %@, image url = %@",feed.feedId,
                feed.drawImageUrl);
        if (!fromCache) {
            self.feed.timesSet = feed.timesSet;
        }
        self.feed.pbDraw = feed.pbDraw;
        self.feed.feedUser = feed.feedUser;
        self.feed.createDate = feed.createDate;
        [self updateShowView:feed];
        [self updateTime:feed];
        [self updateDrawToUserInfo:feed];
        if (self.delegate && [self.delegate respondsToSelector:@selector(didUpdateShowView)]) {
            [self.delegate didUpdateShowView];
        }
    }else if(resultCode != 0){
        if (_getTimes < TRY_GET_FEED_TIMES) {
            PPDebug(@"warnning:<didGetFeed> try again, feed id = %@",feed.feedId);
            [[FeedService defaultService] getFeedByFeedId:feed.feedId delegate:self];
            _getTimes ++;            
        }else{
            PPDebug(@"warnning:<didGetFeed> fail to get feed, feed id = %@",feed.feedId);
        }
    }
}

- (void)dealloc {
    [_showView stop];
    self.feed.drawData = nil;
    PPRelease(_showView);
    PPRelease(drawImage);
    PPRelease(timeLabel);
    PPRelease(loadingActivity);
    PPRelease(_feed);
    PPRelease(_drawToButton);
    PPRelease(_targetUser);
    [super dealloc];
}
@end
