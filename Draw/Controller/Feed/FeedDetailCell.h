//
//  UserInfoCell.h
//  Draw
//
//  Created by  on 12-8-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PPTableViewCell.h"
#import "DrawFeed.h"
@interface UserInfoCell : PPTableViewCell
{
    
}

@property (retain, nonatomic) IBOutlet UILabel *nickLabel;

- (void)setCellInfo:(DrawFeed *)feed;

@end


@interface DrawInfoCell : PPTableViewCell
{
    
}
@property (retain, nonatomic) IBOutlet UIImageView *drawImage;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UIButton *actionButton;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadingActivity;
- (void)setCellInfo:(DrawFeed *)feed;
@end


@interface CommentHeaderView : UIView
{
    
}
@property(nonatomic, assign)id delegate;
- (void)setViewInfo:(DrawFeed *)feed;
@end
