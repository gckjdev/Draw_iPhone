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
#import "HJManagedImageV.h"
#import "PPApplication.h"
#import "UIImageView+WebCache.h"

@implementation DrawInfoCell
@synthesize drawImage;
@synthesize timeLabel;
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
        return 530.0f;
    }
    return 252.0f;
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


- (void)showDrawView:(DrawFeed *)feed
{
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
    self.feed.largeImage = [self.showView createImage];
    [self.drawImage setImage:self.feed.largeImage];
    [self.drawImage setHidden:NO];
    //remove the show view after create the image.
    [self.showView removeFromSuperview];
    self.showView = nil;
}

- (void)updateShowView:(DrawFeed *)feed
{
//    [self.drawImage setCallbackOnSetImage:self];
    
    if (self.feed.largeImage) {
//        [self.drawImage clear];
        [self.drawImage setImage:self.feed.largeImage];
        [self.loadingActivity stopAnimating];
//        [GlobalGetImageCache() manage:self.drawImage];
    }else if ([feed.drawImageUrl length] != 0 && ![DeviceDetection isIPAD]) {
//        [self.drawImage clear];
        //if the draw image is not null
//        [self.drawImage setCallbackOnSetImage:self];
//        [self.drawImage setUrl:[NSURL URLWithString:feed.drawImageUrl]];
        [self.drawImage setImageWithURL:[NSURL URLWithString:feed.drawImageUrl] placeholderImage:[[ShareImageManager defaultManager] unloadBg] success:^(UIImage *image, BOOL cached) {
            PPDebug(@"<managedImageSet>: set large image");
            self.feed.largeImage = image;
            [self.loadingActivity stopAnimating];
        } failure:^(NSError *error) {
            PPDebug(@"<managedImageSet Failed>: set large image failed!");
            [self.loadingActivity stopAnimating];
        }];
        
//        [GlobalGetImageCache() manage:self.drawImage];
    }else{
        [self showDrawView:feed];
    }

}

-(void) managedImageSet:(HJManagedImageV*)mi
{
    PPDebug(@"<managedImageSet>: set large image");
    self.feed.largeImage = mi.image;
    [self.loadingActivity stopAnimating];
}

-(void) managedImageCancelled:(HJManagedImageV*)mi
{
    
}

- (void)setCellInfo:(DrawFeed *)feed
{    
    [self setFeed:feed];
    [self updateTime:self.feed];
    
    if (feed.drawData) {
        [self updateShowView:feed];
        [self updateTime:feed];
        return;
    }    
    if (!_isLoading) {
        _getTimes = 1;
        [[FeedService defaultService] getFeedByFeedId:feed.feedId delegate:self];        
    }
    
//    UIImage *defaultImage = [[ShareImageManager defaultManager] unloadBg];
//    [self.drawImage setImage:defaultImage];
}

#define TRY_GET_FEED_TIMES 3
- (void)didGetFeed:(DrawFeed *)feed
        resultCode:(NSInteger)resultCode
{
    _isLoading = NO;
    if (resultCode == 0 && feed != nil) {        
        
        PPDebug(@"get draw feed succ: feedId = %@",feed.feedId);
        self.feed.timesSet = feed.timesSet;
        self.feed.drawData = feed.drawData;
        self.feed.feedUser = feed.feedUser;
        
        [self updateShowView:feed];
        [self updateTime:feed];
        if (self.delegate && [self.delegate respondsToSelector:@selector(didUpdateShowView)]) {
            [self.delegate didUpdateShowView];
        }
    }else if(resultCode != 0){
        if (_getTimes < TRY_GET_FEED_TIMES) {
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
    [super dealloc];
}
@end
