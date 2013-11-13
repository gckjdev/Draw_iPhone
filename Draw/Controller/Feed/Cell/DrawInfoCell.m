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
#import "UIViewUtils.h"
#import "UserService.h"
//#import "AudioStreamer.h"
#import "UITextView+Extend.h"
#import "UILabel+Extend.h"
#import "WhisperStyleView.h"


#define DESC_FONT_SIZE (ISIPAD ? 20 : 11)
#define DESC_WIDTH (ISIPAD ? 481 : 220)
#define CELL_HEIGHT_BASE (ISIPAD ? 563 : 252)
#define DESC_HEIGHT_SPACE (ISIPAD ? 18 : 8)

@interface DrawInfoCell()

//@property (retain, nonatomic) AudioStreamer *player;
//@property (retain, nonatomic) NSTimer *timer;

@end

@implementation DrawInfoCell
@synthesize drawImage;
@synthesize timeLabel;
@synthesize drawToButton = _drawToButton;
@synthesize loadingActivity;
@synthesize feed = _feed;
@synthesize delegate = _delegate;


- (void)dealloc {
    PPDebug(@"%@ dealloc",self);
    _feed.largeImage = nil;
    _feed.drawImage = nil;
    PPRelease(drawImage);
    PPRelease(timeLabel);
    PPRelease(loadingActivity);
    PPRelease(_feed);
    PPRelease(_drawToButton);
    PPRelease(_targetUser);
    PPRelease(_opusDesc);
    [_slider release];
    [_audioButton release];
    [super dealloc];
}

+ (id)createCell:(id<DrawInfoCellDelegate>)delegate
            feed:(DrawFeed *)feed
{
    NSString* cellId = [self getCellIdentifier];

    int index = 0;
    if ([feed isSingCategory]) {
        index = 1;
    }

    DrawInfoCell *cell = [DrawInfoCell createViewWithXibIdentifier:cellId ofViewIndex:index];
    cell.delegate = delegate;
    return cell;
}

+ (id)createCellWithFullScreen:(id<DrawInfoCellDelegate>)delegate{
    
    NSString* cellId = [self getCellIdentifier];
    
    DrawInfoCell *cell = [DrawInfoCell createViewWithXibIdentifier:cellId ofViewIndex:2];
    cell.delegate = delegate;
    
    return cell;
}



+ (NSString*)getCellIdentifier
{
    return @"DrawInfoCell";
}

+ (CGSize)labelSizeWithText:(NSString *)desc
{
    if ([desc length] == 0) {
        return CGSizeZero;
    }
    CGSize size = [desc sizeWithFont:[UIFont systemFontOfSize:DESC_FONT_SIZE] constrainedToSize:CGSizeMake(DESC_WIDTH, 9999999) lineBreakMode:NSLineBreakByCharWrapping];
    size.height += DESC_HEIGHT_SPACE;
    return size;
}

+ (CGFloat)cellHeightWithFeed:(DrawFeed *)feed
{
    NSString *desc = feed.opusDesc;
    if ([feed isDrawCategory]) {
        if ([desc length] == 0) {
            return CELL_HEIGHT_BASE;
        }else{
            CGSize size = [DrawInfoCell labelSizeWithText:desc];
            return CELL_HEIGHT_BASE + size.height;
        }
    }else if ([feed isSingCategory]){
        
        return ISIPAD ? 606 :278;
    }else{
        
        return 0;
    }
}

+ (CGFloat)cellHeightWithFullScreen{
    
    return ISIPAD ? 858 : 366;
}


- (void)configurePlayerButton
{
    if (self.audioButton == nil) {
        // use initWithFrame to drawRect instead of initWithCoder from xib
        CGRect frame = ISIPAD ? CGRectMake(50, 763, 69, 69) :CGRectMake(7, 328, 32, 32);
        self.audioButton = [[[AudioButton alloc] initWithFrame:frame] autorelease];
        [self.contentView addSubview:self.audioButton];
        
        self.slider.bgColor = COLOR255(0, 0, 0, 0.45*255);
        self.slider.loaderColor = COLOR255(28, 243, 230, 0.8*255);
        self.slider.pointColor = COLOR_YELLOW;
        self.slider.pointImage = [[ShareImageManager defaultManager] playProgressPoint];
    }
}

- (void)initTargetUser:(NSString *)userId nickName:(NSString *)nickName
{
    if (_targetUser == nil) {
        _targetUser = [[FeedUser alloc] initWithUserId:userId nickName:nickName avatar:nil gender:NO signature:nil];
    }else{
        [_targetUser setUserId:userId];
        [_targetUser setNickName:nickName];
    }
}

- (void)updateDrawToUserInfo:(DrawFeed*)feed
{
    if ([feed isKindOfClass:[DrawToUserFeed class]]) {
        DrawToUserFeed *drawToUserFeed = (DrawToUserFeed*)feed;
        if (drawToUserFeed.targetUser == nil) {
            [self.drawToButton setHidden:YES];
            return;
        }
        [self.drawToButton setHidden:NO];
        
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
    
    [self.drawToButton setTitleColor:COLOR_GRAY_TEXT forState:UIControlStateNormal];
    
}


- (void)updateTime:(DrawFeed *)feed
{
    NSString *timeString = dateToTimeLineString(feed.createDate);
    [self.timeLabel setText:timeString];
    
    self.timeLabel.textColor = COLOR_GRAY_TEXT;
}



- (void)updateDesc:(NSString *)desc
{
    [self.opusDesc setText:desc];
    self.opusDesc.textColor = COLOR_BROWN;
    CGSize size = [DrawInfoCell labelSizeWithText:desc];
    [self.opusDesc updateHeight:size.height];
}

- (void)updateDrawImageView:(UIImage *)image
{
    if (image) {
        [self.drawImage setImage:image];
    }
}

- (BOOL)isSmallImageUrl:(NSString *)url
{
    return [url hasSuffix:@"_m.jpg"] || [url hasSuffix:@"_m.png"];
}

- (void)updateShowView:(DrawFeed *)feed
{
    if ([feed.drawImageUrl length] != 0){
//        PPDebug(@"<updateShowView> draw feed url = %@", feed.drawImageUrl);
//        [self addMaskView];
        
        __block UIImage *placeholderImage = nil;
        
        
        [[SDWebImageManager sharedManager] downloadWithURL:feed.thumbURL options:SDWebImageRetryFailed progress:NULL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
            
            if (finished && error == nil) {
                placeholderImage = image;
            }
        }];

        if (self.feed.largeImage == nil) {
            placeholderImage = [[ShareImageManager defaultManager] unloadBg];
        }else{
            placeholderImage = self.feed.largeImage;
        }
        
        [self.drawImage setImageWithURL:[NSURL URLWithString:feed.drawImageUrl] placeholderImage:placeholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            
            self.feed.largeImage = image;
            [self updateDrawImageView:image];
            if (![self isSmallImageUrl:feed.drawImageUrl]) {
                [self loadImageFinish];
            }
        }];
        
        return;
    }
}


#define MASKVIEW_TAG 20130130

- (void)changeColor:(UIControl *)control
{
    control.backgroundColor = [UIColor whiteColor];
    control.alpha = 0.7;
}

- (void)removeColor:(UIControl *)control
{
    control.backgroundColor = [UIColor clearColor];
    control.alpha = 1;
}

- (IBAction)clickDrawImageMask:(UIControl *)control
{
    [self removeColor:control];
    if (_delegate && [_delegate respondsToSelector:@selector(didClickDrawImageMaskView)]) {
        [_delegate didClickDrawImageMaskView];
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

- (void)setCellInfo:(DrawFeed *)feed feedScene:(id<ShowFeedSceneProtocol>)scene
{    
    [self setFeed:feed];
    [self updateTime:self.feed];
    [self.loadingActivity setCenter:self.drawImage.center];
    [self updateShowView:feed];
    [self updateTime:feed];
    [self updateDesc:feed.opusDesc];
    [self updateDrawToUserInfo:feed];
    [self updateDrawWithScene:scene];
    
    if ([feed isSingCategory]) {
        [self updateWhisperStyleView];
    }
}

- (void)updateWhisperStyleView{
    
    [[self.drawImage viewWithTag:8808723459] removeFromSuperview];
    WhisperStyleView *v = [WhisperStyleView createWithFrame:self.drawImage.bounds feed:self.feed];
    [self.drawImage addSubview:v];
}

- (void)updateDrawWithScene:(id<ShowFeedSceneProtocol>)scene
{
    [scene initContentImageView:self.drawImage withFeed:self.feed];
}


- (IBAction)clickFullScreenButton:(id)sender {
    
    
    if ([_delegate respondsToSelector:@selector(didClickFullScreenButton)]) {
        [_delegate didClickFullScreenButton];
    }
}

- (IBAction)clickNonFullScreenButton:(id)sender {
    
    
    if ([_delegate respondsToSelector:@selector(didClickNonFullScreenButton)]) {
        [_delegate didClickNonFullScreenButton];
    }
}

//- (void)play{
//    
//    if (self.player == nil) {
//        self.player = [[[AudioStreamer alloc] initWithURL:[NSURL URLWithString:self.feed.drawDataUrl]] autorelease];
//        
//        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1
//                                                      target:self
//                                                    selector:@selector(updateProgress)
//                                                    userInfo:nil
//                                                     repeats:YES];
//        
//        // register the streamer on notification
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(playbackStateChanged:)
//                                                     name:ASStatusChangedNotification
//                                                   object:_player];
//    }
//    
//    if (_player.isPlaying) {
//        [self.player pause];
//    }else{
//        [self.player start];
//    }
//}
//
//- (void)stop
//{
//    [self.audioButton setProgress:0];
//    [self.audioButton stopSpin];
//    
//    self.audioButton.image = [UIImage imageNamed:playImage];
//    self.audioButton = nil; // 避免播放器的闪烁问题
//    [self.audioButton release];
//    
//    // release streamer
//	if (_player)
//	{
//		[_player stop];
//		[_player release];
//		_player = nil;
//        
//        // remove notification observer for streamer
//		[[NSNotificationCenter defaultCenter] removeObserver:self
//                                                        name:ASStatusChangedNotification
//                                                      object:_player];
//        [_timer invalidate];
//        [_timer release];
//        _timer = nil;
//	}
//}
//
//
///*
// *  observe the notification listener when loading an audio
// */
//- (void)playbackStateChanged:(NSNotification *)notification
//{
//	if ([_player isWaiting])
//	{
//        self.audioButton.image = [UIImage imageNamed:stopImage];
//        [self.audioButton startSpin];
//    } else if ([_player isIdle]) {
//        self.audioButton.image = [UIImage imageNamed:playImage];
//		[self stop];
//	} else if ([_player isPaused]) {
//        self.audioButton.image = [UIImage imageNamed:playImage];
//        [self.audioButton stopSpin];
//        [self.audioButton setColourR:0.0 G:0.0 B:0.0 A:0.0];
//    } else if ([_player isPlaying]) {
//        self.audioButton.image = [UIImage imageNamed:stopImage];
//        [self.audioButton stopSpin];
//	} else {
//        
//    }
//    
//    [self.audioButton setNeedsLayout];
//    [self.audioButton setNeedsDisplay];
//}
//
//
//
//- (void)updateProgress
//{
//    NSLog(@"progress: %f, duration: %f", _player.progress, _player.duration);
//    if (_player.progress <= _player.duration ) {
//        [self.slider setValue:_player.progress/_player.duration];
//    } else {
//        [self.slider setValue:0];
//    }
//}

@end
