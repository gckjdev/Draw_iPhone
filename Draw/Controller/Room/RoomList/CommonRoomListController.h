//
//  CommonRoomListController.h
//  Draw
//
//  Created by Kira on 12-11-14.
//
//

#import "PPTableViewController.h"
#import "PPTableViewController.h"
#import "RoomPasswordDialog.h"
#import "CommonDialog.h"
#import "CommonSearchView.h"
#import "CommonGameNetworkService.h"
#import "FriendService.h"
#import "ShareGameServiceProtocol.h"

typedef enum {
    CommonRoomFilterAllRoom = 0,
    CommonRoomFilterFriendRoom = 1,
    CommonRoomFilterNearByRoom = 2
}CommonRoomFilter;

typedef enum {
    canJoinGame = 0,
    NotEnoughCoin
}PrejoinGameErrorCode;

@class PBGameSession;
@class CommonSearchView;

@interface CommonRoomListController : PPTableViewController<RoomPasswordDialogDelegate, CommonDialogDelegate, CommonSearchViewDelegate, CommonInfoViewDelegate> {
    BOOL _isJoiningGame;
    PBGameSession* _currentSession;
    NSTimer* _refreshRoomTimer;
    BOOL firstLoad;
    int _currentRoomType;
    CommonSearchView* _searchView;
    BOOL _isRefreshing;
    id<ShareGameServiceProtocol> _gameService;
}


@property (retain, nonatomic) PBGameSession* currentSession;
@property (retain, nonatomic) IBOutlet UIButton *searchButton;
@property (retain, nonatomic) IBOutlet UIImageView *headerBackgroundImageView;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;

@property (retain, nonatomic) IBOutlet UIButton *helpButton;
@property (retain, nonatomic) IBOutlet UIButton *createRoomButton;
@property (retain, nonatomic) IBOutlet UIButton *fastEntryButton;
@property (retain, nonatomic) IBOutlet UIButton *leftTabButton;
@property (retain, nonatomic) IBOutlet UIButton *centerTabButton;
@property (retain, nonatomic) IBOutlet UIButton *rightTabButton;
@property (retain, nonatomic) IBOutlet UILabel *emptyListTips;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (retain, nonatomic) IBOutlet UIButton *backButton;
@property (retain, nonatomic) IBOutlet CommonTitleView *titleView;

- (void)showPasswordDialog;
- (void)checkAndJoinGame:(int)sessionId;
- (void)checkAndJoinGame;
- (void)pauseRefreshingRooms;
- (void)continueRefreshingRooms;
- (void)refreshRoomsByFilter:(CommonRoomFilter)filter;
- (void)hideCenterTabButton;
- (void)connectServer;//for dice room list overwrite

- (void)didQueryUser:(NSString *)userId;

- (CGPoint)getSearchViewPosition;
- (void)handleUpdateOnlineUserCount;
- (void)handleDidJoinGame;
- (void)handleNoRoomMessage;
- (PrejoinGameErrorCode)handlePrejoinGameCheck;
- (PrejoinGameErrorCode)handlePrejoinGameCheckBySessionId:(int)sessionId;
- (void)handleJoinGameError:(PrejoinGameErrorCode)errorCode;
- (void)handleUpdateRoomList;
- (void)handleDidConnectServer;
- (void)initView;
- (void)handleLeftTabAction;
- (void)handleCenterTabAction;
- (void)handleRightTabAction;
@end
