//
//  CommentCell.h
//  Draw
//
//  Created by  on 12-6-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTableViewCell.h"
#import "FeedManager.h"
#import "StableView.h"
#import "PPViewController.h"

@class MyFriend;

@protocol CommentCellDelegate <NSObject>

@optional
- (void)didStartToReplyToFeed:(CommentFeed *)feed;
- (void)didClickAvatar:(MyFriend *)myFriend;
@end

@class AvatarView;
@interface CommentCell : PPTableViewCell<AvatarViewDelegate>
{
    AvatarView *_avatarView;
    CommentFeed *_feed;
}

@property (retain, nonatomic) IBOutlet UILabel *commentLabel;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (retain, nonatomic) IBOutlet UIImageView *itemImage;
@property (retain, nonatomic) IBOutlet UIView *splitLine;
@property (retain, nonatomic) CommentFeed *feed;
//@property (retain, nonatomic) PPViewController *superViewController;

+ (CGFloat)getCellHeight:(CommentFeed *)feed;
- (void)setCellInfo:(CommentFeed *)feed;
- (IBAction)clickReplyButton:(id)sender;

@end
