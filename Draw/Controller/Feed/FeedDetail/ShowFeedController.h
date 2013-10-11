//
//  ShowFeedController.h
//  Draw
//
//  Created by  on 12-9-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PPTableViewController.h"
#import "FeedService.h"
#import "DrawDataService.h"
#import "CommonDialog.h"
#import "DrawGameAnimationManager.h"
#import "CommentHeaderView.h"
#import "CommentCell.h"
#import "DrawInfoCell.h"
#import "UserService.h"
#import "CommonTabController.h"
#import "ShowFeedSceneProtocol.h"
#import "MWPhotoBrowser.h"
#import "DetailFooterView.h"

@class Feed;
@class DrawFeed;
@class UserInfoCell;
@class DrawInfoCell;
@class CommentHeaderView;
@class TableTab;
@class TableTabManager;
@class UseItemScene;
//@class ToolView;

@interface ShowFeedController : CommonTabController<FeedServiceDelegate, DrawDataServiceDelegate,CommonDialogDelegate, CommentHeaderViewDelegate, CommentCellDelegate, DrawInfoCellDelegate, UserServiceDelegate, MWPhotoBrowserDelegate, DetailFooterViewDelegate>
{
    time_t timestamp;
}

@property(nonatomic, assign)NSArray *feedList;

- (id)initWithFeedId:(NSString *)feedId;
- (id)initWithFeed:(DrawFeed *)feed;
- (id)initWithFeed:(DrawFeed *)feed
             scene:(UseItemScene*)scene;
- (id)initWithFeed:(DrawFeed *)feed
             scene:(UseItemScene *)scene
         feedScene:(NSObject<ShowFeedSceneProtocol>*)feedScene;

- (void)showOpusImageBrower;


@property (nonatomic, retain) NSObject<ShowFeedSceneProtocol>* feedScene;

@end
