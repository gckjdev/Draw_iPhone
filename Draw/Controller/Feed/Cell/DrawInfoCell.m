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
//#import "DrawUserInfoView.h"
#import "UIViewUtils.h"

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

- (void)updateDrawImageView:(UIImage *)image
{
    if (image) {
//        [self.drawImage scaleWithSize:image.size anchorType:AnchorTypeCenter constType:ConstTypeHeight];
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
        PPDebug(@"<updateShowView> draw feed url = %@", feed.drawImageUrl);

        
        __block UIImage *placeholderImage = nil;
        [[SDWebImageManager sharedManager] downloadWithURL:feed.thumbURL delegate:self options:SDWebImageCacheMemoryOnly success:^(UIImage *image, BOOL cached) {
            placeholderImage = image;
            
        } failure:NULL];

        if (self.feed.largeImage == nil) {
            placeholderImage = [[ShareImageManager defaultManager] unloadBg];
        }else{
            placeholderImage = self.feed.largeImage;
        }

        
        [self.drawImage setImageWithURL:[NSURL URLWithString:feed.drawImageUrl] placeholderImage:placeholderImage success:^(UIImage *image, BOOL cached) {
            
            self.feed.largeImage = image;
            [self updateDrawImageView:image];
            if (![self isSmallImageUrl:feed.drawImageUrl]) {
                [self loadImageFinish];
            }

        } failure:NULL];
        return;
    }
}


#define MASKVIEW_TAG 20130130
- (void)addMaskView
{
    UIControl *mask = (UIControl *)[self viewWithTag:MASKVIEW_TAG];
    if (mask == nil) {
        mask = [[UIControl alloc] initWithFrame:self.drawImage.frame];
        [mask setBackgroundColor:[UIColor clearColor]];
        [mask addTarget:self action:@selector(clickDrawImageMask:) forControlEvents:UIControlEventTouchUpInside];
        [mask addTarget:self action:@selector(changeColor:) forControlEvents:UIControlEventTouchDown];
        [mask addTarget:self action:@selector(removeColor:) forControlEvents:UIControlEventTouchUpOutside];
        [self addSubview:mask];
        PPRelease(mask);
    }
}

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

- (void)clickDrawImageMask:(UIControl *)control
{
    [self removeColor:control];
    if (_delegate && [_delegate respondsToSelector:@selector(didClickDrawImageMaskView)]) {
        [_delegate didClickDrawImageMaskView];
    }
}

- (void)loadImageFinish
{
    [self.loadingActivity stopAnimating];
    [self addMaskView];
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
    [self updateDesc:feed.opusDesc];
    [self.loadingActivity setCenter:self.drawImage.center];
    [self updateShowView:feed];
    [self updateTime:feed];
    [self updateDesc:feed.opusDesc];
    [self updateDrawToUserInfo:feed];
    [self updateDrawWithScene:scene];
}

- (void)updateDrawWithScene:(id<ShowFeedSceneProtocol>)scene
{
    [scene initContentImageView:self.drawImage withFeed:self.feed];
}


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
    [super dealloc];
}
@end
