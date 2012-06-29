//
//  FeedCell.h
//  Draw
//
//  Created by  on 12-6-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTableViewCell.h"
#import "StableView.h"


@class Feed;
@class ShowDrawView;


@protocol FeedCellDelegate <NSObject>

@optional
- (void)didClickDrawOneMoreButtonAtIndexPath:(NSIndexPath *)indexPath;
- (void)didClickGuessButtonOnFeed:(Feed *)feed;
- (void)didClickAvatar:(NSString *)userId 
              nickName:(NSString *)nickName 
                gender:(BOOL)gender
           atIndexPath:(NSIndexPath *)indexPath;

//- (void)didClickGuessButtonAtIndexPath:(NSIndexPath *)indexPath;
//- (void)didClickFollowButtonAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface FeedCell : PPTableViewCell<AvatarViewDelegate>
{
    AvatarView *_avatarView;
    ShowDrawView *_drawView;
}
@property (retain, nonatomic) IBOutlet UILabel *guessStatLabel;
@property (retain, nonatomic) IBOutlet UILabel *descLabel;
@property (retain, nonatomic) IBOutlet UILabel *userNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UIButton *actionButton;

@property (retain, nonatomic) AvatarView *avatarView;
@property (retain, nonatomic) ShowDrawView *drawView;
@property (retain, nonatomic) Feed *feed;
- (IBAction)clickActionButton:(id)sender;
- (void)setCellInfo:(Feed *)feed;
@end
