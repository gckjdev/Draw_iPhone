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

@class AvatarView;
@interface CommentCell : PPTableViewCell<AvatarViewDelegate>
{
    AvatarView *_avatarView;
}

@property (retain, nonatomic) IBOutlet UILabel *commentLabel;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (retain, nonatomic) IBOutlet UIImageView *itemImage;

+ (CGFloat)getCellHeight:(CommentFeed *)feed;
- (void)setCellInfo:(CommentFeed *)feed;

@end
