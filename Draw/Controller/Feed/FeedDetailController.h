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

@class AvatarView;
@class Feed;
@class ShowDrawView;
@interface FeedDetailController : PPTableViewController
{
    Feed *_feed;
    AvatarView *_avatarView;
    ShowDrawView *_drawView;
    
}
@property (retain, nonatomic) IBOutlet UIImageView *inputViewBg;
@property (retain, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (retain, nonatomic) IBOutlet UITextView *commentInput;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *actionButton;
@property (retain, nonatomic) IBOutlet UIButton *sendButton;
@property (retain, nonatomic) IBOutlet UILabel *guessStatLabel;
@property (retain, nonatomic) IBOutlet UILabel *noCommentTipsLabel;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) Feed *feed;
@property (retain, nonatomic) AvatarView *avatarView;
@property (retain, nonatomic) ShowDrawView *drawView;



- (IBAction)clickActionButton:(id)sender;
- (IBAction)clickBackButton:(id)sender;
- (IBAction)clickSendButton:(id)sender;

- (id)initWithFeed:(Feed *)feed;
@end
