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
#import "PPDebug.h"
#import "FeedManager.h"
//#import "HJManagedImageV.h"

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

@end

@interface FeedCell : PPTableViewCell<AvatarViewDelegate, FeedManagerDelegate>
{
    AvatarView *_avatarView;
    ShowDrawView *_showView;
}
@property (retain, nonatomic) IBOutlet UILabel *guessStatLabel;
@property (retain, nonatomic) IBOutlet UILabel *descLabel;
@property (retain, nonatomic) IBOutlet UILabel *userNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UIImageView *drawImageView;
@property (retain, nonatomic) ShowDrawView *showView;
@property (retain, nonatomic) AvatarView *avatarView;
@property (retain, nonatomic) Feed *feed;
- (void)setCellInfo:(Feed *)feed;

+ (CGFloat)getCellHeight:(Feed *)feed;

@end
