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
#import "TimeUtils.h"
#import "AccountService.h"
#import "AnimationManager.h"
#import "CommonMessageCenter.h"
#import "CMPopTipView.h"
#import "DiceConfigManager.h"
#import "ConfigManager.h"
#import "LmWallService.h"

#define KEY_LAST_AWARD_DATE     @"last_award_day"

#define AWARD_DICE_TAG      20120901

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

- (void)playBGM
{
    [[AudioManager defaultManager] setBackGroundMusicWithName:@"dice.m4a"];
    [[AudioManager defaultManager] backgroundMusicStart];
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{    
    [super viewDidLoad];
    [self loadBoards];
    [self loadMainMenu];
    [self loadBottomMenu];
    [self playBGM];
    [self checkIn];

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

#pragma mark - code for rolling award dice

- (void)clickDice:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    [[CommonMessageCenter defaultCenter] postMessageWithText:[NSString stringWithFormat:@"you pick up %d coin",_awardDicePoint] delayTime:2 isHappy:YES];
    [btn removeFromSuperview];
}

- (void)updateTimer:(id)sender
{
    UIButton* btn = (UIButton*)[self.view viewWithTag:AWARD_DICE_TAG];
    _awardDicePoint = rand()%6+1;
    UIImage* image = [UIImage imageNamed:[NSString stringWithFormat:@"open_bell_%dbig.png", _awardDicePoint]];
    [btn setImage:image forState:UIControlStateNormal];
}

- (void)startRollDiceTimer
{
    _rollAwardDiceTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
}

- (void)killRollDiceTimer
{
    if (_rollAwardDiceTimer) {
        if ([_rollAwardDiceTimer isValid]) {
            [_rollAwardDiceTimer invalidate];
        }
        _rollAwardDiceTimer = nil;
    }
}

- (void)rollAwardDice
{
    UIButton* diceBtn = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 55)] autorelease];
    [diceBtn setCenter:CGPointMake(self.view.frame.size.width-50, self.view.frame.size.height-50)];
    [self.view addSubview:diceBtn];
    [diceBtn addTarget:self action:@selector(clickDice:) forControlEvents:UIControlEventTouchUpInside];
    diceBtn.tag = AWARD_DICE_TAG;
    CAAnimation* rolling = [AnimationManager rotationAnimationWithRoundCount:50 duration:2.5];
    rolling.removedOnCompletion = NO;
    rolling.delegate = self;
    [diceBtn.layer addAnimation:rolling forKey:@""];
    
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    CGPoint endPoint = CGPointMake(self.view.frame.size.width-50, self.view.frame.size.height-50);
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGPathMoveToPoint(curvedPath, NULL, self.view.frame.size.width/4, 100);
    CGPathAddCurveToPoint(curvedPath, NULL, endPoint.x*0.6, 0, endPoint.x*0.75, 0, endPoint.x, endPoint.y);

    pathAnimation.path = curvedPath;
    CGPathRelease(curvedPath);
    pathAnimation.duration = 2.5;
    pathAnimation.delegate = self;
    
    [diceBtn.layer addAnimation:pathAnimation forKey:@""];
    
    
    [self startRollDiceTimer];
}

- (int)checkIn
{  
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //TODO:the code below must be recover after test finish
//    NSDate* lastCheckInDate = [userDefaults objectForKey:KEY_LAST_AWARD_DATE];
//    if (lastCheckInDate != nil && isLocalToday(lastCheckInDate)){
//        // already check in, return -1
//        PPDebug(@"<checkIn> but already do it today... come tomorrow :-)");
//        return -1;
//    }
    
    // random get some coins
    int coins = 0;
    PPDebug(@"<checkIn> got %d coins", coins);
    [self rollAwardDice]; 
    
    // update check in today flag
    [userDefaults setObject:[NSDate date] forKey:KEY_LAST_AWARD_DATE];
    [userDefaults synchronize];    
    return coins;
}

#pragma mark - animation delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self killRollDiceTimer];
    
    HKGirlFontLabel* label = [[[HKGirlFontLabel alloc] initWithFrame:CGRectMake(0, 0, 50, 25) pointSize:13] autorelease];
    [label setText:NSLS(@"kClickMe")];
    CMPopTipView* view = [[[CMPopTipView alloc] initWithCustomView:label needBubblePath:NO] autorelease];
    [view setBackgroundColor:[UIColor yellowColor]];
    [view presentPointingAtView:[self.view viewWithTag:AWARD_DICE_TAG] inView:self.view animated:YES];
    [UIView animateWithDuration:4 animations:^{
        view.alpha = 0;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
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

- (void)showCoinsNotEnoughView
{
    CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kNotEnoughCoin") 
                                                       message:[DiceConfigManager coinsNotEnoughNote]
                                                         style:CommonDialogStyleDoubleButton 
                                                      delegate:self 
                                                         theme:CommonDialogThemeDice];
    [dialog showInView:self.view];
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
        [[DiceGameService defaultService] joinGameRequestWithCondiction:^BOOL{
            if ([DiceConfigManager meetJoinGameCondiction]) {
                [self showActivityWithText:NSLS(@"kJoiningGame")];
                return YES;
            }else {
                [self showCoinsNotEnoughView];
                return NO;
            }
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
    if ([ConfigManager wallEnabled]) {
        [self showWall];
    }else {
        CoinShopController* controller = [[[CoinShopController alloc] init] autorelease];
        [self.navigationController pushViewController:controller animated:YES]; 
    }
}

- (void)clickBack:(CommonDialog *)dialog
{
    
}

- (void)showWall
{        
    if ([ConfigManager useLmWall]){    
        [UIUtils alertWithTitle:@"免费金币获取提示" msg:@"下载免费应用即可获取金币！下载完应用一定要打开才可以获得奖励哦！"];
        [[LmWallService defaultService] show:self];
    }
}


@end
