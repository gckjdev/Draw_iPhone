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

typedef enum {
    allRoom = 0,
    friendRoom = 1,
    nearByRoom = 2
}RoomFilter;

typedef enum {
    JoinGameSuccess = 0,
    NotEnoughCoin
}JoinGameErrorCode;

@class PBGameSession;
@class CommonSearchView;

@interface CommonRoomListController : PPTableViewController</*CommonGameServiceDelegate, */InputDialogDelegate, CommonDialogDelegate, CommonSearchViewDelegate, CommonInfoViewDelegate> {
    BOOL _isJoiningDice;
    PBGameSession* _currentSession;
    NSTimer* _refreshRoomTimer;
    BOOL firstLoad;
    int _currentRoomType;
    CommonSearchView* _searchView;
    BOOL _isRefreshing;
    CommonGameNetworkService *_gameService;
}


@property (retain, nonatomic) PBGameSession* currentSession;

@end
