//
//  FeedCell.h
//  Draw
//
//  Created by  on 12-6-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTableViewCell.h"
//#import "StableView.h"


@class Feed;
@class ShowDrawView;
@class AvatarView;

@protocol FeedCellDelegate <NSObject>

@optional
- (void)didClickDrawOneMoreButtonAtIndexPath:(NSIndexPath *)indexPath;
- (void)didClickGuessButtonAtIndexPath:(NSIndexPath *)indexPath;
- (void)didClickFollowButtonAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface FeedCell : PPTableViewCell
{
    AvatarView *_avatarView;
}
@property (retain, nonatomic) IBOutlet UILabel *guessStatLabel;
@property (retain, nonatomic) IBOutlet UILabel *descLabel;
@property (retain, nonatomic) IBOutlet UILabel *userNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UIButton *actionButton;

@property (retain, nonatomic) AvatarView *avatarView;

- (IBAction)clickActionButton:(id)sender;
- (void)setCellInfo:(Feed *)feed;
@end
