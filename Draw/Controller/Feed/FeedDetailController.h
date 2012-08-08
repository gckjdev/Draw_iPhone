//
//  FeedDetailController.h
//  Draw
//
//  Created by  on 12-6-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTableViewController.h"
#import "FeedService.h"
#import "ShowDrawView.h"
#import "OfflineGuessDrawController.h"
#import "StableView.h"

@class AvatarView;
@class Feed;

@interface FeedDetailController : PPTableViewController<FeedServiceDelegate, 
ShowDrawViewDelegate,OfflineGuessDelegate, AvatarViewDelegate>
{
    AvatarView *_avatarView;
    ShowDrawView *_drawView;
    DrawFeed *_feed;
    FeedService *_feedService;
    NSInteger _startIndex;
    UIButton *_maskView;
}
@property (retain, nonatomic) IBOutlet UILabel *commentLabel;
@property (retain, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (retain, nonatomic) IBOutlet UITextView *commentInput;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *actionButton;
@property (retain, nonatomic) IBOutlet UIButton *sendButton;
@property (retain, nonatomic) IBOutlet UILabel *guessStatLabel;
@property (retain, nonatomic) IBOutlet UILabel *noCommentTipsLabel;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) DrawFeed *feed;
@property (retain, nonatomic) AvatarView *avatarView;
@property (retain, nonatomic) ShowDrawView *drawView;

@property (retain, nonatomic) IBOutlet UIView *inputBackgroundView;
@property (retain, nonatomic) IBOutlet UIImageView *inputBackground;
@property (retain, nonatomic) IBOutlet UIImageView *paperImage;


- (IBAction)clickActionButton:(id)sender;
- (IBAction)clickBackButton:(id)sender;
- (IBAction)clickSendButton:(id)sender;

- (id)initWithFeed:(DrawFeed *)feed;
@end
