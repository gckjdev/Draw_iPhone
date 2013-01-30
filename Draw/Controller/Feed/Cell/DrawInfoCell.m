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

#define DESC_FONT_SIZE (ISIPAD ? 20 : 11)
#define DESC_WIDTH (ISIPAD ? 481 : 220)
#define CELL_HEIGHT_BASE (ISIPAD ? 520 : 252)
#define DESC_HEIGHT_SPACE (ISIPAD ? 18 : 8)

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
//+ (void)

//+ (CGSize)labelSizeWithText:(NSString *)text font:(UIFont *)font width:(CGFloat)width
//{
//    [text sizeWithFont:font forWidth:width lineBreakMode:<#(NSLineBreakMode)#>
//}

+ (CGSize)labelSizeWithText:(NSString *)desc
{
    if ([desc length] == 0) {
        return CGSizeZero;
    }
    CGSize size = [desc sizeWithFont:[UIFont systemFontOfSize:DESC_FONT_SIZE] constrainedToSize:CGSizeMake(DESC_WIDTH, 9999999) lineBreakMode:NSLineBreakByCharWrapping];
    size.height += DESC_HEIGHT_SPACE;
    return size;
}

+ (CGFloat)cellHeightWithDesc:(NSString *)desc
{
    if ([desc length] == 0) {
        return CELL_HEIGHT_BASE;
    }else{
        CGSize size = [DrawInfoCell labelSizeWithText:desc];
        return CELL_HEIGHT_BASE + size.height;
    }
}

//+ (CGFloat)getCellHeight
//{
//    if ([DeviceDetection isIPAD]) {
//        return 520.0f;
//    }
//    return 252.0f;
//}

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


- (void)updateDesc:(NSString *)desc
{
    [self.opusDesc setText:desc];
}

- (void)showDrawView:(DrawFeed *)feed
{
        if (![feed hasDrawActions]) {
            return;
        }

    if (self.showView == nil) {
        [self.drawImage setHidden:YES];
        [feed parseDrawData];
        self.showView = [ShowDrawView showView];
        self.showView.center = self.drawImage.center;
        [self.showView resetFrameSize:self.drawImage.frame.size];
        [self.showView setShowPenHidden:YES];
        self.showView.drawActionList = feed.drawData.drawActionList;
        [self addSubview:self.showView];
        
        [self.showView show];

        UIImage *image = [self.showView createImage];
        self.feed.largeImage = image;
        [self.drawImage setImage:image];
        [self.drawImage setHidden:NO];
        [[FeedManager defaultManager] saveFeed:self.feed.feedId largeImage:image];
        
        [self.showView removeFromSuperview];
        [self.loadingActivity stopAnimating];

        self.showView.drawActionList = nil;
        feed.drawData = nil;
        self.showView = nil;
    }

}

- (void)updateShowView:(DrawFeed *)feed
{
    if ([feed.drawImageUrl length] != 0 /*&& (![DeviceDetection isIPAD] || feed.deviceType == DeviceTypeIPad)*/) {
        [self.drawImage setImageWithURL:[NSURL URLWithString:feed.drawImageUrl] placeholderImage:[[ShareImageManager defaultManager] unloadBg] success:^(UIImage *image, BOOL cached) {
            PPDebug(@"<download image> %@ success", feed.drawImageUrl);
            self.feed.largeImage = image;
            [self loadImageFinish];
        } failure:^(NSError *error) {
            PPDebug(@"<download image> %@ failure, error=%@", feed.drawImageUrl, [error description]);
            [self.loadingActivity stopAnimating];
        }];
    }
    else if (self.feed.largeImage) {
        [self.drawImage setImage:self.feed.largeImage];
        [self loadImageFinish];
    }
    else if (feed.largeImage){
        self.feed.largeImage = feed.largeImage;
        [self.drawImage setImage:feed.largeImage];
        [self loadImageFinish];        
    }
    else{
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
    if (_targetUser.userId && _delegate && [_delegate respondsToSelector:@selector(didClickDrawToUser:nickName:)]) {
        [_delegate didClickDrawToUser:_targetUser.userId nickName:_targetUser.nickName];
    }
}

- (void)setCellInfo:(DrawFeed *)feed
{    
    [self setFeed:feed];
    [self updateTime:self.feed];
    [self updateDesc:feed.opusDesc];
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
        
        PPDebug(@"get draw feed succ: feedId = %@, image url = %@, opusDesc = %@",feed.feedId,
                feed.drawImageUrl, feed.opusDesc);
        if (!fromCache) {
            self.feed.timesSet = feed.timesSet;
        }
        self.feed.pbDraw = feed.pbDraw;
        self.feed.feedUser = feed.feedUser;
        self.feed.createDate = feed.createDate;
        self.feed.opusDesc = feed.opusDesc;
        self.feed.feedType = feed.feedType;
        if ([feed.drawImageUrl length] != 0) {
            self.feed.drawImageUrl = feed.drawImageUrl;
        }
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
    PPDebug(@"%@ dealloc",self);
    [_showView stop];
    self.feed.drawData = nil;
    PPRelease(_showView);
    PPRelease(drawImage);
    PPRelease(timeLabel);
    PPRelease(loadingActivity);
    PPRelease(_feed);
    PPRelease(_drawToButton);
    PPRelease(_targetUser);
    [_opusDesc release];
    [super dealloc];
}
@end
