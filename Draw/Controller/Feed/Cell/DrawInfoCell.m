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
#import "StringUtil.h"

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
    cell.backgroundColor = [UIColor clearColor];
    
    cell.timeLabel.font = CELL_REPLY_SOURCE_FONT;
    cell.drawToButton.titleLabel.font = CELL_REPLY_SOURCE_FONT;
    
    [cell createReplayButton];
    
    return cell;
}

+ (id)createCellWithFullScreen:(id<DrawInfoCellDelegate>)delegate{
    
    NSString* cellId = [self getCellIdentifier];
    
    DrawInfoCell *cell = [DrawInfoCell createViewWithXibIdentifier:cellId ofViewIndex:2];
    cell.delegate = delegate;
    
    return cell;
}

- (void)createReplayButton
{
    // create PLAY button
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect buttonFrame = self.frame;
    buttonFrame.size = ISIPAD ? CGSizeMake(120, 120) : CGSizeMake(50, 50);
    [button setBackgroundImage:[UIImage imageNamed:@"play3.png"] forState:UIControlStateNormal];
    [button setFrame:buttonFrame];
    [button setCenter:self.drawImage.center];
    [button setAlpha:0.0];
    [button addTarget:self action:@selector(replay) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:button];
    [UIView animateWithDuration:0.8 delay:0.8 options:UIViewAnimationOptionCurveEaseIn animations:^{
        button.alpha = 0.8;
    } completion:^(BOOL finished) {
    }];
}

- (void)replay
{
    if (_delegate && [_delegate respondsToSelector:@selector(didClickPlayButton)]) {
        [_delegate didClickPlayButton];
    }
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
    CGSize size = [desc sizeWithMyFont:[UIFont systemFontOfSize:DESC_FONT_SIZE] constrainedToSize:CGSizeMake(DESC_WIDTH, 9999999) lineBreakMode:NSLineBreakByCharWrapping];
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
    
    return ISIPAD ? 823 : 366;
}

- (void)configurePlayerButton
{
    if (self.audioButton == nil) {
        // use initWithFrame to drawRect instead of initWithCoder from xib
        CGRect frame = ISIPAD ? CGRectMake(64, 739, 69, 69) :CGRectMake(7, 328, 32, 32);
        self.audioButton = [[[AudioButton alloc] initWithFrame:frame] autorelease];
        [self.contentView addSubview:self.audioButton];
        
        self.slider.bgColor = COLOR255(0, 0, 0, 0.45*255);
        self.slider.loaderColor = COLOR255(28, 243, 230, 0.8*255);
        self.slider.pointColor = COLOR_YELLOW;
        self.slider.pointImage = [[ShareImageManager defaultManager] playProgressPoint];
        self.slider.value = 0.0f;
    }
}

- (void)initTargetUser:(NSString *)userId nickName:(NSString *)nickName
{
    if (_targetUser == nil) {
        _targetUser = [[FeedUser alloc] initWithUserId:userId
                                              nickName:nickName
                                                avatar:nil
                                                gender:NO
                                             signature:nil
                                                   vip:0];
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
        
        if ([feed isDrawCategory]) {
            targetUserName = [NSString stringWithFormat:NSLS(@"kDrawToUserByUser"), targetUserName];
        }else if ([feed isSingCategory]){
            targetUserName = [NSString stringWithFormat:NSLS(@"kGiftToUserByUser"), targetUserName];
        }
        

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

- (BOOL)isSmallImageUrl:(NSString *)url
{
    return [url hasSuffix:@"_m.jpg"] || [url hasSuffix:@"_m.png"];
}

- (void)updateShowView:(DrawFeed *)feed
{
    if ([feed.drawImageUrl length] != 0){
        
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
            if (image) {
                [self.drawImage setImage:image];
            }
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
    [self updateTime:feed];
    [self updateDesc:feed.opusDesc];
    [self updateDrawToUserInfo:feed];
    [self updateDrawWithScene:scene];
    
    if ([feed isSingCategory]) {
        [self updateWhisperStyleView];
    }else if ([feed isDrawCategory]){
        [self updateShowView:feed];
    }else{
        [self updateShowView:feed];
    }
}

- (void)updateWhisperStyleView{
    
    [self.drawImage setImage:nil];
    [[self.drawImage viewWithTag:8808723459] removeFromSuperview];
    WhisperStyleView *v = [WhisperStyleView createWithFrame:self.drawImage.bounds
                                                       feed:self.feed
                                                useBigImage:YES];
    v.tag = 8808723459;
    [self.drawImage addSubview:v];
    [v setFeedDetailStyle];
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


@end
