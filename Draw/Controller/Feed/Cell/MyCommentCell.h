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

@protocol CommentCellDelegate <NSObject>

@optional
- (void)didStartToReplyToFeed:(CommentFeed *)feed;

@end

@class AvatarView;
@interface MyCommentCell : PPTableViewCell<AvatarViewDelegate>
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

+ (CGFloat)getCellHeight:(CommentFeed *)feed;
- (void)setCellInfo:(CommentFeed *)feed;
@property (retain, nonatomic) IBOutlet UIButton *sourceButton;

@end
