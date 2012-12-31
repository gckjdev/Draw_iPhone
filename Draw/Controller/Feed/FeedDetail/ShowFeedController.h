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

@class Feed;
@class DrawFeed;
@class UserInfoCell;
@class DrawInfoCell;
@class CommentHeaderView;
@class TableTab;
@class TableTabManager;
@class UseItemScene;
//@class ToolView;

@interface ShowFeedController : PPTableViewController<FeedServiceDelegate, DrawDataServiceDelegate,CommonDialogDelegate, CommentHeaderViewDelegate, CommentCellDelegate, UIActionSheetDelegate, DrawInfoCellDelegate>
{
    DrawFeed *_feed;
    UserInfoCell *_userCell;
    DrawInfoCell *_drawCell;
    CommentHeaderView *_commentHeader;
    TableTabManager *_tabManager;
    BOOL _didSave;
    BOOL _didLoadDrawPicture;
    UIImageView* _throwingItem;
}
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@property (retain, nonatomic) IBOutlet UIButton *guessButton;
@property (retain, nonatomic) IBOutlet UIButton *saveButton;
@property (retain, nonatomic) IBOutlet UIButton *commentButton;
@property (retain, nonatomic) IBOutlet UIButton *flowerButton;
@property (retain, nonatomic) IBOutlet UIButton *tomatoButton;
@property (retain, nonatomic) IBOutlet UIButton *replayButton;

- (IBAction)clickActionButton:(id)sender;
- (IBAction)clickRefresh:(id)sender;

@property(nonatomic, retain) UserInfoCell *userCell;
@property(nonatomic, retain) DrawInfoCell *drawCell;
@property(nonatomic, retain) CommentHeaderView *commentHeader;
@property(nonatomic, retain) DrawFeed *feed;
@property (nonatomic, retain) UseItemScene* useItemScene;

- (id)initWithFeed:(DrawFeed *)feed;
- (id)initWithFeed:(DrawFeed *)feed
             scene:(UseItemScene*)scene;
- (IBAction)clickBackButton:(id)sender;
@end
