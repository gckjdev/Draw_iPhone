//
//  CommentCell.h
//  Draw
//
//  Created by  on 12-6-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTableViewCell.h"
#import "Feed.h"

@class AvatarView;
@interface CommentCell : PPTableViewCell
{
    AvatarView *_avatarView;
}

@property (retain, nonatomic) IBOutlet UILabel *commentLabel;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;

+ (CGFloat)getCellHeight:(Feed *)feed;
- (void)setCellInfo:(Feed *)feed;

@end
