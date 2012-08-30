//
//  DiceHomeController.m
//  Draw
//
//  Created by  on 12-8-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DiceHomeController.h"
//#import "Board.h"
#import "BoardPanel.h"
#import "BottomMenuPanel.h"
#import "MenuPanel.h"
#import "BoardService.h"
#import "BoardManager.h"
#import "CommonGameNetworkService.h"
#import "DiceGamePlayController.h"
#import "StringUtil.h"
#import "UserManager.h"
#import "DiceGameService.h"
#import "CoinShopController.h"

@interface DiceHomeController()
{
    BoardPanel *_boardPanel;
    NSTimeInterval interval;
    BOOL hasGetLocalBoardList;

}

- (void)updateBoardPanelWithBoards:(NSArray *)boards;
- (void)registerDiceGameNotification;

@end

@implementation DiceHomeController
@synthesize menuPanel = _menuPanel;
@synthesize bottomMenuPanel = _bottomMenuPanel;


- (void)dealloc
{
    PPRelease(_menuPanel);
    PPRelease(_bottomMenuPanel);
    [super dealloc];
}

- (void)loadBoards
{
    hasGetLocalBoardList = NO;
    interval = 1;
    Board *defaultBoard = [Board defaultBoard];
    NSArray *borads = [NSArray arrayWithObject:defaultBoard];
    PPDebug(@"<viewDidLoad> update Board Panel With Default Boards ");
    [self updateBoardPanelWithBoards:borads];
    
    [[BoardService defaultService] getBoardsWithDelegate:self];    
}
- (void)loadMainMenu
{
    self.menuPanel = [MenuPanel menuPanelWithController:self 
                                            gameAppType:GameAppTypeDice];
    
    self.menuPanel.center = [DeviceDetection isIPAD] ? CGPointMake(384, 682) : CGPointMake(160, 304);
    
    [self.view insertSubview:self.menuPanel atIndex:0];
    
}

- (void)loadBottomMenu
{
    self.bottomMenuPanel = [BottomMenuPanel panelWithController:self
                                                    gameAppType:GameAppTypeDice];
    
    self.bottomMenuPanel.center = [DeviceDetection isIPAD] ? CGPointMake(384, 960) : CGPointMake(160, 439);
    
    [self.view addSubview:_bottomMenuPanel];
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{    
    [super viewDidLoad];
    [self loadBoards];
    [self loadMainMenu];
    [self loadBottomMenu];

}

- (void)viewDidAppear:(BOOL)animated
{
    [self registerDiceGameNotification];    
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self unregisterAllNotifications];
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


#pragma mark - Board Service Delegate
- (void)updateBoardList:(NSTimer *)theTimer
{
    interval *= 2;
    if (interval < NSTimeIntervalSince1970) {
        PPDebug(@"<updateBoardList> timeinterval = %f", interval);
        [[BoardService defaultService] getBoardsWithDelegate:self];        
    }
}

- (void)didGetBoards:(NSArray *)boards 
          resultCode:(NSInteger)resultCode
{
    if (resultCode == 0) {
        PPDebug(@"<didGetBoards> update Board Panel With Remote Boards ");
        [self updateBoardPanelWithBoards:boards];
        [[BoardManager defaultManager] saveBoardList:boards];
    }else {
        //start timer to fetch. use the local
        if(!hasGetLocalBoardList){
            NSArray * boardList = [[BoardManager defaultManager] 
                                   getLocalBoardList];
            hasGetLocalBoardList = YES;
            PPDebug(@"<didGetBoards> update Board Panel With Local Boards ");
            [self updateBoardPanelWithBoards:boardList];
        }
        [NSTimer scheduledTimerWithTimeInterval:interval target:self 
                                       selector:@selector(updateBoardList:)
                                       userInfo:nil
                                        repeats:NO];
        //start timer to fetch. use the local
    }
}

- (void)updateBoardPanelWithBoards:(NSArray *)boards
{
    if ([boards count] != 0) {
        [_boardPanel removeFromSuperview];
        _boardPanel = [BoardPanel boardPanelWithController:self];
        [_boardPanel setBoardList:boards];
        [self.view addSubview:_boardPanel];  
    }
    
}

#pragma mark - Game Notification

- (void)registerDiceGameNotificationWithName:(NSString *)name 
                                  usingBlock:(void (^)(NSNotification *note))block
{
    [self registerNotificationWithName:name 
                                object:nil 
                                 queue:[NSOperationQueue mainQueue] 
                            usingBlock:block];
}

- (void)registerDiceGameNotification
{
    [self registerDiceGameNotificationWithName:NOTIFICATION_JOIN_GAME_RESPONSE usingBlock:^(NSNotification *note) {
        PPDebug(@"<%@> NOTIFICATION_JOIN_GAME_RESPONSE", [self description]); 
        [self hideActivity];
        if(_isTryJoinGame) {
            GameMessage* message = [CommonGameNetworkService userInfoToMessage:[note userInfo]];
            if ([message resultCode] == GameResultCodeSuccess){
                DiceGamePlayController *controller = [[[DiceGamePlayController alloc] init] autorelease];
                [self.navigationController pushViewController:controller animated:YES];
            }
            else{
                // TODO show error info here
                PPDebug(@"JOIN GAME FAIL, ResultCode=%d", [message resultCode]);
            }

            // clear join dice flag
            _isTryJoinGame = NO; 
        }
    }];
    
}

- (void)unregisterDiceGameNotification
{        
    [self unregisterAllNotifications];
}


- (BOOL)meetJoinGameCondiction
{
    if ([[AccountService defaultService] getBalance] <= DICE_THRESHOLD_COIN) {
        NSString* message = [NSString stringWithFormat:NSLS(@"kCoinsNotEnoughAndEnterShop"), DICE_THRESHOLD_COIN];
        CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kNotEnoughCoin") 
                                                           message:message
                                                             style:CommonDialogStyleDoubleButton 
                                                          delegate:self 
                                                             theme:CommonDialogThemeDice];
        [dialog showInView:self.view];
        return NO;
    }
    return YES;
}

- (void)connectServer
{

    
    _isTryJoinGame = YES;    

    [[DiceGameService defaultService] connectServer:self];
    [self showActivityWithText:NSLS(@"kConnectingServer")];
}

- (void)didConnected
{
    PPDebug(@"%@ <didConnected>", [self description]);
    
    [self hideActivity];
        
    if (_isTryJoinGame){
        [self showActivityWithText:NSLS(@"kJoiningGame")];
        [[DiceGameService defaultService] joinGameRequestWithCondiction:^BOOL{
            return [self meetJoinGameCondiction];
        }];
    }    
}

- (void)didBroken
{
    _isTryJoinGame = NO;
    PPDebug(@"%@ <didBroken>", [self description]);
    [self hideActivity];
    
    [self popupUnhappyMessage:NSLS(@"kNetworkBroken") title:@""];
    [self.navigationController popToRootViewControllerAnimated:NO];
    
}

#pragma mark - common dialog delegate
- (void)clickOk:(CommonDialog *)dialog
{
    CoinShopController* controller = [[[CoinShopController alloc] init] autorelease];
    [self.navigationController pushViewController:controller animated:YES]; 
}

- (void)clickBack:(CommonDialog *)dialog
{
    
}

@end
