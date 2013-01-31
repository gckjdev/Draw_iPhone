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
#import "UserManager+DiceUserManager.h"
#import "DiceGameService.h"
#import "CoinShopController.h"
#import "AdService.h"
#import "TimeUtils.h"
#import "AccountService.h"
#import "AnimationManager.h"
#import "CommonMessageCenter.h"
#import "CMPopTipView.h"

#import "ConfigManager.h"

#import "DiceConfigManager.h"
#import "ConfigManager.h"
#import "LmWallService.h"
#import "HelpView.h"

#import "RegisterUserController.h"

#import "VendingController.h"
#import "DiceRoomListController.h"
#import "UserSettingController.h"
#import "FriendController.h"
#import "ChatListController.h"
#import "FeedbackController.h"
#import "ZJHGameService.h"
#import "ZJHGameController.h"
#import "PPResourceService.h"
#import "NotificationName.h"
#import "ZJHRoomListController.h"

#define KEY_LAST_AWARD_DATE     @"last_award_day"

#define DAILY_GIFT_COIN [ConfigManager getDailyGiftCoin]
#define DAILY_GIFT_COIN_INCRE   [ConfigManager getDailyGiftCoinIncre]

#define AWARD_DICE_TAG      2012090101
#define AWARD_DICE_START_POINT CGPointMake(0, 0)
#define AWARD_DICE_SIZE ([DeviceDetection isIPAD]?CGSizeMake(100, 110):CGSizeMake(50, 55))
#define AWARD_TIPS_FONT ([DeviceDetection isIPAD]?22:11)

#define BOARD_HEIGHT ISIPAD ? 408 : 193

@interface DiceHomeController()
{
    BoardPanel *_boardPanel;
    NSTimeInterval interval;
    BOOL hasGetLocalBoardList;
    
    PPResourceService *_resService;
}

- (void)updateBoardPanelWithBoards:(NSArray *)boards;
- (void)registerDiceGameNotification;
- (void)showWall;
- (void)checkIn;

@end

@implementation DiceHomeController
//@synthesize menuPanel = _menuPanel;
//@synthesize bottomMenuPanel = _bottomMenuPanel;


- (void)dealloc
{
//    PPRelease(_menuPanel);
//    PPRelease(_bottomMenuPanel);
    [super dealloc];
    
}

- (void)loadBoards:(BOOL)localOnly
{    
//    hasGetLocalBoardList = NO;
//    interval = 1;
//    Board *defaultBoard = [Board defaultBoard];
//    NSArray *borads = [NSArray arrayWithObject:defaultBoard];
//    PPDebug(@"<viewDidLoad> update Board Panel With Default Boards ");

    [self updateBoardPanelWithBoards:[[BoardManager defaultManager] boardList]];
    
//    if (localOnly == NO){
//        [[BoardService defaultService] getBoardsWithDelegate:self];    
//    }
}
//- (void)loadMainMenu
//{
//    self.menuPanel = [MenuPanel menuPanelWithController:self 
//                                            gameAppType:GameAppTypeDice];
//    
////    CGPoint iphoneCenter = ([DeviceDetection isIPhone5]?CGPointMake(160, 406):CGPointMake(160, 306));
//    self.menuPanel.center = [DeviceDetection isIPAD] ? CGPointMake(384, 686) : CGPointMake(160, 306);
//    
//    [self.view insertSubview:self.menuPanel atIndex:0];
//    
//}

//- (void)loadBottomMenu
//{
//    self.bottomMenuPanel = [BottomMenuPanel panelWithController:self
//                                                    gameAppType:GameAppTypeDice];
//    
//    self.bottomMenuPanel.center = [DeviceDetection isIPAD] ? CGPointMake(384, 961) : CGPointMake(160, 440);
//    
//    [self.view addSubview:_bottomMenuPanel];
//}

- (void)playBGM
{
    [[AudioManager defaultManager] setBackGroundMusicWithName:@"dice.m4a"];
    [[AudioManager defaultManager] backgroundMusicStart];
}
#pragma mark - View lifecycle

- (void)viewDidLoad
{        
    [[AdService defaultService] setViewController:self];
    _resService = [PPResourceService defaultService];

    [super viewDidLoad];
//    [self loadMainMenu];
//    [self loadBottomMenu];
    [self playBGM];
    [self checkIn];

}

- (void)viewDidAppear:(BOOL)animated
{
    [[AdService defaultService] setViewController:self];    

    [self loadBoards:YES];    
    [self registerDiceGameNotification];    
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [_boardPanel stopTimer];
    [_boardPanel clearAds];
    [self unregisterDiceGameNotifications];
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _boardPanel = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


#pragma mark - Board Service Delegate
- (void)updateBoardList:(NSTimer *)theTimer
{
    interval *= 2;
    if (interval < NSTimeIntervalSince1970) {
        PPDebug(@"<updateBoardList> timeinterval = %f", interval);
        [[BoardService defaultService] syncBoards];
    }
}

- (void)didGetBoards:(NSArray *)boards
          resultCode:(NSInteger)resultCode
{

}

- (void)joinGameResponse:(GameMessage*)message
{
    PPDebug(@"<%@> NOTIFICATION_JOIN_GAME_RESPONSE", [self description]);
    [self hideActivity];
    if(_isTryJoinGame) {
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
}

- (void)updateBoardPanelWithBoards:(NSArray *)boards
{
    if ([boards count] != 0) {
        
        // remove old board
        [_boardPanel stopTimer];
        [_boardPanel removeFromSuperview];
        
        // create new board and show it
        _boardPanel = [BoardPanel boardPanelWithController:self];
        [_boardPanel setBoardList:boards];
        [self.view addSubview:_boardPanel]; 
        
        // if there are other views, bring them to front if needed
        UIView* awardButton = [self.view viewWithTag:AWARD_DICE_TAG];
        if (awardButton) {
            [self.view bringSubviewToFront:awardButton];
        }
        
        UIView* helpView = [self.view viewWithTag:DICE_HELP_VIEW_TAG];
        if (helpView){
            [self.view bringSubviewToFront:helpView];
        }
    }
    
}

#pragma mark - code for rolling award dice

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    //CGPoint pointInView = [touch locationInView:gestureRecognizer.view];
    if ( [gestureRecognizer isMemberOfClass:[UITapGestureRecognizer class]] ) {
        CGPoint aPoint = [touch locationInView:self.view];
        UIButton* btn = (UIButton*)[self.view viewWithTag:AWARD_DICE_TAG];
        CGPoint bPoint = [(CALayer*)btn.layer.presentationLayer position];
        if (abs((aPoint.x-bPoint.x)) < 50 && abs((aPoint.y - bPoint.y)) < 50) {
            return YES;
        }
        [btn.layer removeAllAnimations];
        [btn removeFromSuperview];
        return NO;
    } 

    return NO;
}

- (int)calCoinByPoint:(int)point
{
    if (point == 1) {
        return DAILY_GIFT_COIN + 5*DAILY_GIFT_COIN_INCRE;
    }
    return DAILY_GIFT_COIN+(point-2)*DAILY_GIFT_COIN_INCRE;
}

- (void)awardCoin
{
    int awardCoins = [self calCoinByPoint:_awardDicePoint];
    [[CommonMessageCenter defaultCenter] postMessageWithText:[NSString stringWithFormat:NSLS(@"kDailyAwardCoin"),awardCoins] delayTime:2 isHappy:YES];
    [[AccountService defaultService] chargeAccount:awardCoins source:LiarDiceDailyAward];
}

- (void)clickAwardDice:(UITapGestureRecognizer*)sender
{
    CGPoint aPoint = [sender locationInView:self.view];
    UIButton* btn = (UIButton*)[self.view viewWithTag:AWARD_DICE_TAG];
    CGPoint bPoint = [(CALayer*)btn.layer.presentationLayer position];
    if (abs((aPoint.x-bPoint.x)) < AWARD_DICE_SIZE.width/2 && abs((aPoint.y - bPoint.y)) < AWARD_DICE_SIZE.height/2) {
        [self awardCoin];
        [btn removeFromSuperview];
        [_tapGestureRecognizer setEnabled:NO];
    }

    
}

- (void)rollAwardDice
{
    UIButton* diceBtn = [[[UIButton alloc] initWithFrame:CGRectMake(0, 
                                                                    0, 
                                                                    AWARD_DICE_SIZE.width, 
                                                                    AWARD_DICE_SIZE.height)] 
                         autorelease];
    _awardDicePoint = rand()%6 + 1;
//    UIImage* image = [UIImage imageNamed:[ConfigManager getAwardItemImageName:_awardDicePoint]];
    UIImage* image = [[DiceImageManager defaultManager] openDiceImageWithDice:_awardDicePoint];
    [diceBtn setBackgroundImage:image forState:UIControlStateNormal];
    //[diceBtn setCenter:CGPointMake(self.view.frame.size.width-50, self.view.frame.size.height-50)];
    [self.view addSubview:diceBtn];
    [self.view bringSubviewToFront:diceBtn];
    [diceBtn addTarget:self action:@selector(clickAwardDice:) forControlEvents:UIControlEventTouchUpInside];
    diceBtn.tag = AWARD_DICE_TAG;
    CAAnimation* rolling = [AnimationManager rotateAnimationWithRoundCount:-50 duration:25];
    rolling.removedOnCompletion = YES;
    rolling.delegate = self;
    [diceBtn.layer addAnimation:rolling forKey:@"roll"];
    
//    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
//    pathAnimation.calculationMode = kCAAnimationPaced;
//    pathAnimation.fillMode = kCAFillModeForwards;
//    pathAnimation.removedOnCompletion = NO;
////    CGPoint endPoint = CGPointMake(self.view.frame.size.width-50, self.view.frame.size.height-50);
//    CGMutablePathRef curvedPath = CGPathCreateMutable();
//    CGPathMoveToPoint(curvedPath, NULL, self.view.frame.size.width/4, 100);
////    CGPathAddCurveToPoint(curvedPath, NULL, endPoint.x*0.6, 0, endPoint.x*0.75, 0, endPoint.x, endPoint.y);
//
//    pathAnimation.path = curvedPath;
//    CGPathRelease(curvedPath);
//    pathAnimation.duration = 2.5;
//    pathAnimation.delegate = self;
//    
//    CGPoint startPoint = AWARD_DICE_START_POINT;
    CGPoint points[6];
    float diceWidth = AWARD_DICE_SIZE.width;
    float diceHeight = AWARD_DICE_SIZE.height;
    float screenWidth = self.view.frame.size.width;
    float screenHeight = self.view.frame.size.height;
    points[0] = AWARD_DICE_START_POINT;
    points[1] = CGPointMake(screenWidth - diceWidth/3, 
                            rand()%(int)(screenHeight - diceHeight) + diceHeight/2);
    points[2] = CGPointMake(rand()%(int)(screenWidth - diceWidth) + diceWidth/2, 
                            screenHeight - diceHeight/3);
    points[3] = CGPointMake(diceWidth/3, 
                            rand()%(int)(screenHeight - diceHeight) + diceHeight/2);
    points[4] = CGPointMake(rand()%(int)(screenWidth - diceWidth) + diceWidth/2, 
                            diceHeight/3);
    points[5] = CGPointMake(rand()%(int)(screenWidth - diceWidth) + diceWidth/2, 
                            rand()%(int)(screenHeight - diceHeight) + diceHeight/2);
    
    CAKeyframeAnimation* pathAnimation = [AnimationManager pathByPoins:points count:6 duration:25 delegate:self];
    pathAnimation.removedOnCompletion = YES;
    
    [diceBtn.layer addAnimation:pathAnimation forKey:@"move"];
    [diceBtn setCenter:points[5]];
//    
//    [self startRollDiceTimer];
}

- (void)checkIn
{  
    if ([[UserManager defaultManager] hasUser] == NO){
        // no user yet, don't show award dice button, add by Benson
        return;
    }    
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    //TODO:the code below must be recover after test finish
    NSDate* lastCheckInDate = [userDefaults objectForKey:KEY_LAST_AWARD_DATE];
    if (lastCheckInDate != nil && isLocalToday(lastCheckInDate)){
        // already check in, return -1
        PPDebug(@"<checkIn> but already do it today... come tomorrow :-)");
        return;
    }
    
    // random get some coins
//    int coins = 0;
//    PPDebug(@"<checkIn> got %d coins", coins);
    _tapGestureRecognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickAwardDice:)] autorelease];
    _tapGestureRecognizer.delegate = self;
    _tapGestureRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:_tapGestureRecognizer];
    [self rollAwardDice]; 
    
    // update check in today flag
    [userDefaults setObject:[NSDate date] forKey:KEY_LAST_AWARD_DATE];
    [userDefaults synchronize];    
}

#pragma mark - animation delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
//    [self killRollDiceTimer];
//    
    if (flag) {
        UIButton* btn = (UIButton*)[self.view viewWithTag:AWARD_DICE_TAG];
        UILabel* label = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, AWARD_DICE_SIZE.width, AWARD_DICE_SIZE.height/2)] autorelease];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:[UIFont systemFontOfSize:AWARD_TIPS_FONT]];
        [label setText:NSLS(@"kClickMe")];
        CMPopTipView* view = [[[CMPopTipView alloc] initWithCustomView:label needBubblePath:NO] autorelease];
        [view setBackgroundColor:[UIColor yellowColor]];
        [view presentPointingAtView:[self.view viewWithTag:AWARD_DICE_TAG] inView:self.view animated:YES];
        [UIView animateWithDuration:4 animations:^{
            view.alpha = 0;
            if (btn)
                btn.alpha = 0;
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
            if (btn)
                [btn removeFromSuperview];
        }];
    }
}

- (void)registerDiceGameNotification
{
    [self registerNotificationWithName:NOTIFICATION_JOIN_GAME_RESPONSE
                            usingBlock:^(NSNotification *note) {
                                [self joinGameResponse:[CommonGameNetworkService userInfoToMessage:[note userInfo]]];
    }];
    
    [self registerNotificationWithName:BOARD_UPDATE_NOTIFICATION // TODO set right name here
                            usingBlock:^(NSNotification *note) {
                                [self updateBoardPanelWithBoards:[[BoardManager defaultManager] boardList]];
                            }];    
    
    [self registerNotificationWithName:UIApplicationDidEnterBackgroundNotification
                            usingBlock:^(NSNotification *note) {
                                [_boardPanel clearAds];
                            }];
    
    [self registerNotificationWithName:NOTIFICATION_NETWORK_CONNECTED // TODO set right name here
                            usingBlock:^(NSNotification *note) {
                                [self didConnected];
                            }];
    
    [self registerNotificationWithName:NOTIFICATION_NETWORK_DISCONNECTED // TODO set right name here
                            usingBlock:^(NSNotification *note) {
                                [self disconnectWithError:[CommonGameNetworkService userInfoToError:note.userInfo]];
                            }];
}

- (void)unregisterDiceGameNotifications
{
    [self unregisterNotificationWithName:NOTIFICATION_JOIN_GAME_RESPONSE];
    [self unregisterNotificationWithName:BOARD_UPDATE_NOTIFICATION];
    [self unregisterNotificationWithName:NOTIFICATION_NETWORK_CONNECTED];
}

- (void)showCoinsNotEnoughView
{
    CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kNotEnoughCoin") 
                                                       message:[DiceConfigManager coinsNotEnoughNoteWithRuleType:DiceGameRuleTypeRuleNormal]
                                                         style:CommonDialogStyleDoubleButton 
                                                      delegate:self 
                                           ];
    [dialog showInView:self.view];
}

- (void)connectServer:(DiceGameRuleType)ruleType
{
    _isTryJoinGame = YES;    
    
    [self showActivityWithText:NSLS(@"kConnectingServer")];
    [[DiceGameService defaultService] setRuleType:ruleType];
//    [[DiceGameService defaultService] connectServer:self];
    [[DiceGameService defaultService] connectServer];
}

- (void)didConnected
{
    PPDebug(@"%@ <didConnected>", [self description]);
    
    [self hideActivity];
    
    // for zhajinhua test
    
    if (_isTryJoinGame){
        if ([DiceConfigManager meetJoinGameCondictionWithRuleType:DiceGameRuleTypeRuleNormal]) {
            [self showActivityWithText:NSLS(@"kJoiningGame")];
            [[DiceGameService defaultService] joinGameRequestWithCustomUser:[[UserManager defaultManager] toDicePBGameUser]];
        }else {
            [[DiceGameService defaultService] disconnectServer];
            [self showCoinsNotEnoughView];
        }
    }
}

- (void)disconnectWithError:(NSError *)error
{
    PPDebug(@"diconnect error: %@", [error description]);

    _isTryJoinGame = NO;
    [self hideActivity];
        
    if (error != nil) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        [self popupUnhappyMessage:NSLS(@"kNetworkBroken") title:@""];
    }
}

//- (void)connectFailed
//{
//    [self connectBroken];
//}

//- (void)connectBroken
//{
//    _isTryJoinGame = NO;
//    PPDebug(@"%@ <didBroken>", [self description]);
//    [self hideActivity];
//    
//    [self popupUnhappyMessage:NSLS(@"kNetworkBroken") title:@""];
//    [self.navigationController popToRootViewControllerAnimated:NO];
//}

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
    [UIUtils alertWithTitle:@"免费金币获取提示" msg:@"下载免费应用即可获取金币！下载完应用一定要打开才可以获得奖励哦！"];
    [[LmWallService defaultService] show:self];
}


#pragma mark - Button Menu delegate

- (void)homeMainMenuPanel:(HomeMainMenuPanel *)mainMenuPanel
             didClickMenu:(HomeMenuView *)menu
                 menuType:(HomeMenuType)type
{
    if (![self isRegistered]) {
        [self toRegister];
        return;
    }
    switch (type) {
        case HomeMenuTypeDiceShop:
        {
            VendingController* vc = [[VendingController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
        }
            break;
        case HomeMenuTypeDiceStart:
        {
            if ([self respondsToSelector:@selector(connectServer:)]){
                [self connectServer:DiceGameRuleTypeRuleNormal];
            }
        }
            break;
        case HomeMenuTypeDiceHappyRoom:
        {
            DiceRoomListController* vc = [[[DiceRoomListController alloc] initWithRuleType:DiceGameRuleTypeRuleNormal] autorelease];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        case HomeMenuTypeDiceHighRoom:
        {
            DiceRoomListController* vc = [[[DiceRoomListController alloc] initWithRuleType:DiceGameRuleTypeRuleHigh] autorelease];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case HomeMenuTypeDiceSuperHighRoom:
        {
            DiceRoomListController* vc = [[[DiceRoomListController alloc] initWithRuleType:DiceGameRuleTypeRuleSuperHigh] autorelease];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
            
        case HomeMenuTypeDiceHelp:
        {
            HelpView *view = [HelpView createHelpView:@"ZJHHelpView"];
            [view showInView:self.view];
        }
            break;

        default:
            break;
    }
}

- (void)homeBottomMenuPanel:(HomeBottomMenuPanel *)bottomMenuPanel
               didClickMenu:(HomeMenuView *)menu
                   menuType:(HomeMenuType)type
{
    PPDebug(@"<homeBottomMenuPanel>, click type = %d", type);
    if (![self isRegistered]) {
        [self toRegister];
        return;
    }
    
    switch (type) {
            //For Bottom Menus
        case HomeMenuTypeDrawSetting:
        case HomeMenuTypeDrawMe:
        {
            UserSettingController *settings = [[UserSettingController alloc] init];
            [self.navigationController pushViewController:settings animated:YES];
            [settings release];
        }
            break;
        case HomeMenuTypeDrawFriend:
        {
            FriendController *mfc = [[FriendController alloc] init];
            [self.navigationController pushViewController:mfc animated:YES];
            [mfc release];
            //            [[StatisticManager defaultManager] setFanCount:0];
        }
            break;
        case HomeMenuTypeDrawMessage:
        {
            ChatListController *controller = [[ChatListController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
            [controller release];
            //            [[StatisticManager defaultManager] setMessageCount:0];
        }
            break;
        case HomeMenuTypeDrawMore:
        {
            FeedbackController* feedBack = [[FeedbackController alloc] init];
            [self.navigationController pushViewController:feedBack animated:YES];
            [feedBack release];
            
        }
            break;
            
        default:
            break;
    }
    [menu updateBadge:0];
}

- (float)getMainMenuOriginY
{
    return BOARD_HEIGHT;
}
//- (void)didClickMenuButton:(MenuButton *)menuButton
//{
//    PPDebug(@"menu button type = %d", menuButton.type);
//    if (![self isRegistered]) {
//        [self toRegister];
//        return;
//    }
//    
//    MenuButtonType type = menuButton.type;
//    switch (type) {
//        case MenuButtonTypeDiceShop:
//        {
//            VendingController* vc = [[VendingController alloc] init];
//            [self.navigationController pushViewController:vc animated:YES];
//            [vc release];
//        }
//            break;
//        case MenuButtonTypeDiceStart:
//        {
//            if ([self respondsToSelector:@selector(connectServer:)]){
//                [self connectServer:DiceGameRuleTypeRuleNormal];
//            }
//        }
//            break;
//        case MenuButtonTypeDiceHappyRoom:
//        {
//            DiceRoomListController* vc = [[[DiceRoomListController alloc] initWithRuleType:DiceGameRuleTypeRuleNormal] autorelease];
//            [self.navigationController pushViewController:vc animated:YES];
//        }
//            break;
//            
//        case MenuButtonTypeDiceHighRoom:
//        {
//            DiceRoomListController* vc = [[[DiceRoomListController alloc] initWithRuleType:DiceGameRuleTypeRuleHigh] autorelease];
//            [self.navigationController pushViewController:vc animated:YES];
//        }
//            break;
//        case MenuButtonTypeDiceSuperHighRoom:
//        {
//            DiceRoomListController* vc = [[[DiceRoomListController alloc] initWithRuleType:DiceGameRuleTypeRuleSuperHigh] autorelease];
//            [self.navigationController pushViewController:vc animated:YES];
//        }
//            break;
//            
//        case MenuButtonTypeDiceHelp:
//        {
//            HelpView *view = [HelpView createHelpView:@"ZJHHelpView"];
//            [view showInView:self.view];
//        }
//            break;
//            //For Bottom Menus
//        case MenuButtonTypeSettings:
//        {
//            UserSettingController *settings = [[UserSettingController alloc] init];
//            [self.navigationController pushViewController:settings animated:YES];
//            [settings release];
//        }
//            break;
//        case MenuButtonTypeFriend:
//        {
//            FriendController *mfc = [[FriendController alloc] init];
//            [self.navigationController pushViewController:mfc animated:YES];
//            [mfc release];
////            [_bottomMenuPanel setMenuBadge:0 forMenuType:MenuButtonTypeFriend];
//        }
//            break;
//        case MenuButtonTypeChat:
//        {
//            ChatListController *controller = [[ChatListController alloc] init];
//            [self.navigationController pushViewController:controller animated:YES];
//            [controller release];
//            
////            [_bottomMenuPanel setMenuBadge:0 forMenuType:type];
//            
//        }
//            break;
//        case MenuButtonTypeFeedback:
//        {
//            FeedbackController* feedBack = [[FeedbackController alloc] init];
//            [self.navigationController pushViewController:feedBack animated:YES];
//            [feedBack release];
//            
//        }
//            break;
//        case MenuButtonTypeCheckIn:
//            
//        default:
//            break;
//    }
//}

- (IBAction)clickZhaJinHuaButton:(id)sender {
    
//    [_resService startDownloadInView:self.view backgroundImage:@"DiceDefault" resourcePackageName:@"zhajinhua_core" success:^(BOOL alreadyExisted) {
//        _isZJH = YES;
//        
//        [self showActivityWithText:NSLS(@"kConnectingServer")];
//        
//        [[ZJHGameService defaultService] setRule:PBZJHRuleTypeNormal];
//        [[ZJHGameService defaultService] connectServer];
//        
//    } failure:^(NSError *error, UIView* downloadView) {
//        [self popupMessage:@"Fail to load resources" title:@""];
//    }];
}

@end
