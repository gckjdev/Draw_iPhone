//
//  DrawInfoCell.h
//  Draw
//
//  Created by  on 12-9-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PPTableViewCell.h"
#import "DrawFeed.h"
#import "FeedService.h"
#import "ShowFeedSceneProtocol.h"
#import "AudioButton.h"
#import "CustomSlider.h"
#import "StrokeLabel.h"

@protocol DrawInfoCellDelegate <NSObject>

@optional
- (void)didUpdateShowView;
- (void)didClickDrawToUser:(NSString *)userId nickName:(NSString *)nickName;
- (void)didLoadDrawPicture;
- (void)didClickDrawImageMaskView;
- (void)didClickFullScreenButton;
- (void)didClickNonFullScreenButton;

@end

@interface DrawInfoCell : PPTableViewCell<FeedServiceDelegate>//, HJManagedImageVDelegate>
{
    id<DrawInfoCellDelegate> _delegate;
    DrawFeed *_feed;
    BOOL _isLoading;
    FeedUser *_targetUser;
//    UIControl *mask;
}

@property (assign, nonatomic) id<DrawInfoCellDelegate> delegate;
@property (retain, nonatomic) DrawFeed *feed;
@property (retain, nonatomic) IBOutlet UIImageView *drawImage;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UIButton *drawToButton;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivity;
@property (retain, nonatomic) IBOutlet UILabel *opusDesc;
@property (retain, nonatomic) IBOutlet CustomSlider *slider;
@property (retain, nonatomic) AudioButton *audioButton;
@property (retain, nonatomic) IBOutlet StrokeLabel *opusDescLabel;

+ (id)createCell:(id<DrawInfoCellDelegate>)delegate feed:(DrawFeed *)feed;
+ (id)createCellWithFullScreen:(id<DrawInfoCellDelegate>)delegate;

+ (CGFloat)cellHeightWithFeed:(DrawFeed *)feed;
+ (CGFloat)cellHeightWithFullScreen;


- (void)setCellInfo:(DrawFeed *)feed feedScene:(id<ShowFeedSceneProtocol>)scene;
+ (NSString*)getCellIdentifier;

- (void)configurePlayerButton;

@end

