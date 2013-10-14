//
//  ReportFeedCell.h
//  Draw
//
//  Created by Gamy on 13-9-3.
//
//

#import "PPTableViewCell.h"
#import "StableView.h"
#import "CommentFeed.h"

@interface ReportFeedCell : PPTableViewCell<AvatarViewDelegate>

@property (retain, nonatomic) IBOutlet UIImageView *bgImageView;
@property (retain, nonatomic) IBOutlet UILabel *descLabel;
@property (retain, nonatomic) IBOutlet UILabel *userNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UIImageView *drawImageView;
@property (retain, nonatomic) IBOutlet AvatarView *avatarView;
@property (retain, nonatomic) CommentFeed *feed;
@property (assign, nonatomic) NSString *contestId;
+ (CGFloat)getCellHeightWithFeed:(CommentFeed *)feed;
- (void)setCellInfo:(CommentFeed *)feed;

@end
