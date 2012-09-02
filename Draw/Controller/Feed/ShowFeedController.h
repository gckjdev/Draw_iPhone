//
//  ShowFeedController.h
//  Draw
//
//  Created by  on 12-9-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PPTableViewController.h"
#import "FeedService.h"

@class Feed;
@class DrawFeed;
@class UserInfoCell;
@class DrawInfoCell;
@class TableTab;
@class TableTabManager;

@interface ShowFeedController : PPTableViewController<FeedServiceDelegate>
{
    DrawFeed *_feed;
    UserInfoCell *_userCell;
    DrawInfoCell *_drawCell;
    TableTabManager *_tabManager;
    NSInteger _startIndex;
}
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property(nonatomic, retain) UserInfoCell *userCell;
@property(nonatomic, retain) DrawInfoCell *drawCell;
@property(nonatomic, retain) DrawFeed *feed;
- (id)initWithFeed:(DrawFeed *)feed;

- (IBAction)clickBackButton:(id)sender;
@end
