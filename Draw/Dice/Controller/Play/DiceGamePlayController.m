//
//  DiceGamePlayController.m
//  Draw
//
//  Created by 小涛 王 on 12-7-27.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceGamePlayController.h"
#import "DiceGameService.h"
#import "DiceGameSession.h"
#import "DiceAvatarView.h"
#import "Dice.pb.h"
#import "AnimationManager.h"
#import "DiceNotification.h"
#import "GameMessage.pb.h"
#import "LevelService.h"
#import "AdService.h"
#import "DiceUserInfoView.h"
#import "ItemType.h"
#import "GifView.h"
#import "DiceSoundManager.h"
#import "DiceSettingView.h"
#import "ConfigManager.h"
#import "CommonMessageCenter.h"
#import "UIViewUtils.h"
#import "CommonDiceItemAction.h"
#import "DiceConfigManager.h"
#import "CallDiceView.h"
#import "CustomDiceManager.h"
#import "NotificationName.h"
#import "RoomTitleView.h"
#import "AccountManager.h"


#define AVATAR_TAG_OFFSET   8000
#define NICKNAME_TAG_OFFSET 1100
#define RESULT_TAG_OFFSET   3000
#define BELL_TAG_OFFSET     4000

#define MAX_PLAYER_COUNT    6

#define DURATION_SHOW_GAIN_COINS 3

#define DURATION_ROLL_BELL 1


#define DURATION_PLAYER_BET 5

@interface DiceGamePlayController ()
{
    int hideAdCounter;
    int _second;
}

@property (retain, nonatomic) DiceSelectedView *diceSelectedView;
@property (retain, nonatomic) NSEnumerator *enumerator;
@property (retain, nonatomic) DicePopupViewManager *popupView;



- (void)disableAllDiceOperationButtons;

- (void)clearAdHideTimer;
- (void)startAdHideTimer;

- (void)showDestroyWildsAnim;
- (void)showWildsAnim;

//- (void)popResultViewOnAvatarView:(UIView*)view
//                         duration:(CFTimeInterval)duration 
//                       coinsCount:(int)coinsCount;
- (void)quitDiceGame;

@end

@implementation DiceGamePlayController
@synthesize resultDiceImageView = _resultDiceImageView;
@synthesize resultHolderView = _resultHolderView;
@synthesize waittingForNextTurnNoteLabel = _waittingForNextTurnNoteLabel;
@synthesize gameBeginNoteLabel = _gameBeginNoteLabel;

@synthesize myLevelLabel;
@synthesize myCoinsLabel;
@synthesize myDiceListHolderView;
@synthesize diceCountSelectedHolderView;
@synthesize roomNameLabel = _roomNameLabel;
@synthesize openDiceButton = _openDiceButton;
@synthesize wildsButton = _wildsButton;
@synthesize plusOneButton = _plusOneButton;
@synthesize itemsBoxButton = _itemsBoxButton;
@synthesize wildsLabel = _wildsLabel;
@synthesize plusOneLabel = _plusOneLabel;
@synthesize popResultView = _popResultView;
@synthesize rewardCoinLabel = _rewardCoinLabel;
@synthesize wildsFlagButton = _wildsFlagButton;
@synthesize resultDiceCountLabel = _resultDiceCountLabel;
@synthesize diceSelectedView = _diceSelectedView;
@synthesize enumerator = _enumerator;
@synthesize adView = _adView;
@synthesize chatButton = _chatButton;
@synthesize popupLevel1View = _popupLevel1View;
@synthesize popupLevel2View = _popupLevel2View;
@synthesize popupLevel3View = _popupLevel3View;
@synthesize anteNoteLabel = _anteNoteLabel;
@synthesize anteLabel = _anteLabel;
@synthesize anteView = _anteView;
@synthesize waitForPlayerBetLabel = _waitForPlayerBetLabel;
@synthesize popupView = _popupView;
@synthesize tableImageView = _tableImageView;
@synthesize adHideTimer = _adHideTimer;


- (void)dealloc {
    [UIApplication sharedApplication].idleTimerDisabled=NO;

    [self setAdView:nil];
    
    [self clearAdHideTimer];
    
    [_adView release];
    [myLevelLabel release];
    [myCoinsLabel release];
    [diceCountSelectedHolderView release];
    [_diceSelectedView release];
    [myDiceListHolderView release];
    [_roomNameLabel release];
    [_openDiceButton release];
    [_wildsButton release];
    [_plusOneButton release];
    [_itemsBoxButton release];
    [_wildsLabel release];
    [_plusOneLabel release];
    [_popResultView release];
    [_rewardCoinLabel release];
    [_enumerator release];
    
    [_wildsFlagButton release];
    [_resultDiceCountLabel release];
    [_resultDiceImageView release];
    [_resultHolderView release];
    [_waittingForNextTurnNoteLabel release];
    [_gameBeginNoteLabel release];
    [_chatButton release];
    [_popupLevel1View release];
    [_popupLevel2View release];
    [_popupLevel3View release];
    [_popupView release];
    [_urgedUser release];
    [_anteNoteLabel release];
    [_anteLabel release];
    [_anteView release];
    [_waitForPlayerBetLabel release];
    [_tableImageView release];
    [super dealloc];
}

//- (id)initWIthRuleType:(DiceGameRuleType)ruleType
//{
//    self = [super init];
//    if (self) {
//        _diceService = [DiceGameService defaultService];
//        _userManager = [UserManager defaultManager];
//        _imageManager = [DiceImageManager defaultManager];
//        _levelService = [LevelService defaultService];
//        _accountService = [AccountService defaultService];
//        _audioManager = [AudioManager defaultManager];
//        _expressionManager = [ExpressionManager defaultManager];
//        _soundManager = [DiceSoundManager defaultManager];
//        _ruleType = ruleType;
//        _urgedUser = [[NSMutableSet alloc] init];
//    }
//    
//    return self;
//}

- (id)init
{
    self = [super init];
    if (self) {
        _diceService = [DiceGameService defaultService];
        _userManager = [UserManager defaultManager];
        _imageManager = [DiceImageManager defaultManager];
        _levelService = [LevelService defaultService];
        _accountService = [AccountService defaultService];
        _audioManager = [AudioManager defaultManager];
        _expressionManager = [ExpressionManager defaultManager];
        _soundManager = [DiceSoundManager defaultManager];
        _robotManager = [DiceRobotManager defaultManager];
        _customDicemanager = [CustomDiceManager defaultManager];
        _urgedUser = [[NSMutableSet alloc] init];
    }
    
    return self;
}

- (UIImage *)tableImage
{
//    UIImage *image = nil;
//    switch (_diceService.ruleType) {
//        case DiceGameRuleTypeRuleNormal:
//            image = [_imageManager diceNormalRoomTableImage];
//            break;
//        case DiceGameRuleTypeRuleHigh:
//            image = [_imageManager diceHighRoomTableImage];
//            break;
//            
//        case DiceGameRuleTypeRuleSuperHigh:
//            image = [_imageManager diceSuperHighRoomTableImage];
//            break;
//        default:
//            break;
//    }
//    
//    return image;
    switch ([DeviceDetection deviceScreenType]) {
        case DEVICE_SCREEN_IPAD:
        case DEVICE_SCREEN_NEW_IPAD:
            return [UIImage imageNamed:@"zjh_game_bg_dual_ipad.jpg"];
            break;
            
        case DEVICE_SCREEN_IPHONE5:
            return [UIImage imageNamed:@"zjh_game_bg_dual_ip5.jpg"];
            break;
            
        case DEVICE_SCREEN_IPHONE:
            return [UIImage imageNamed:@"zjh_game_bg_dual.jpg"];
            break;
            
        default:
            break;
    }
    
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableImageView.image = [self tableImage];
    
    [UIApplication sharedApplication].idleTimerDisabled=YES;
    self.popupView = [[[DicePopupViewManager alloc] init] autorelease];
    self.wildsLabel.text = NSLS(@"kDiceWilds");
    [self.wildsFlagButton setTitle:NSLS(@"kDiceWilds") forState:UIControlStateNormal];
    self.itemsBoxButton.enabled = NO;

    self.gameBeginNoteLabel.hidden = YES;
    self.gameBeginNoteLabel.text = NSLS(@"kGameBegin");
    self.gameBeginNoteLabel.textColor = [UIColor yellowColor];

    self.myLevelLabel.text = [NSString stringWithFormat:@"LV:%d",_levelService.level];;
    self.myCoinsLabel.text = [NSString stringWithFormat:@"x%d",[[AccountManager defaultManager] getBalanceWithCurrency:PBGameCurrencyCoin]];
    
    self.anteNoteLabel.text = NSLS(@"kAnte");
    
    self.view.backgroundColor = [UIColor blackColor];
    self.wildsLabel.textColor = [UIColor whiteColor];
    self.plusOneLabel.textColor = [UIColor whiteColor];    
        
    [[UIApplication sharedApplication] 
     setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    
    [RoomTitleView showRoomTitle:[_diceService roomName] inView:self.view] ;
    
    myCoinsLabel.textColor = [UIColor whiteColor];
    myLevelLabel.textColor = [UIColor whiteColor];
    
    [_openDiceButton setBackgroundImage:[[DiceImageManager defaultManager] openDiceButtonBgImage] forState:UIControlStateNormal];
    
    // Init dice selected view
    self.diceSelectedView = [[[DiceSelectedView alloc] initWithFrame:diceCountSelectedHolderView.bounds superView:self.view] autorelease];
    _diceSelectedView.delegate = self;
    [diceCountSelectedHolderView addSubview:_diceSelectedView];

    [self updateDiceSelecetedView];
    
    // Disable all dice operation buttons.
    [self disableAllDiceOperationButtons];
    [self hideAllBellViews];
    
    [self.openDiceButton setTitle:NSLS(@"kOpenDice") forState:UIControlStateNormal];
    self.wildsFlagButton.hidden = YES;
    self.resultHolderView.hidden = YES;
    self.openDiceButton.hidden = YES;
    self.anteView.hidden = YES;
    self.anteLabel.text = [NSString stringWithFormat:@"%d", _diceService.ante]; 
    self.waitForPlayerBetLabel.hidden = YES;
    self.waitForPlayerBetLabel.textColor = [UIColor yellowColor];

    
    [self updateWaittingForNextTurnNotLabel];
    
    self.adView = [[AdService defaultService] createAdInView:self                  
                                                       frame:CGRectMake(0, 0, 320, 50) 
                                                   iPadFrame:CGRectMake(224, 88, 320, 50)
                                                     useLmAd:YES];
    
    [self updateAllPlayersAvatar];
    
    if ([DeviceDetection isIPAD] == NO){
        [self startAdHideTimer];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [self registerDiceGameNotifications];
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self unregisterAllNotifications];
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{
    [[AdService defaultService] clearAdView:_adView];
    [self setAdView:nil];
    [self setMyLevelLabel:nil];
    [self setMyCoinsLabel:nil];
    [self setOpenDiceButton:nil];
    [self setDiceCountSelectedHolderView:nil];
    [self setMyDiceListHolderView:nil];
    [self setRoomNameLabel:nil];
    [self setWildsButton:nil];
    [self setPlusOneButton:nil];
    [self setItemsBoxButton:nil];
    [self setWildsLabel:nil];
    [self setPlusOneLabel:nil];
    [self setPopResultView:nil];
    [self setRewardCoinLabel:nil];
    [self setWildsFlagButton:nil];
    [self setResultDiceCountLabel:nil];
    [self setResultDiceImageView:nil];
    [self setResultHolderView:nil];
    [self setWaittingForNextTurnNoteLabel:nil];
    [self setGameBeginNoteLabel:nil];
    [self setChatButton:nil];
    [self setPopupLevel1View:nil];
    [self setPopupLevel2View:nil];
    [self setPopupLevel3View:nil];
    [self setAnteNoteLabel:nil];
    [self setAnteLabel:nil];
    [self setAnteView:nil];
    [self setWaitForPlayerBetLabel:nil];
    [self setTableImageView:nil];
    [super viewDidUnload];
}

#define TAG_TOOL_BUTTON 12080101
- (IBAction)clickToolButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.tag = TAG_TOOL_BUTTON;
    button.selected = !button.selected;
    
    if (button.selected) {
        [_popupView popupItemListAtView:button 
                                 inView:self.view
                           aboveSubView:self.popupLevel3View
                               duration:0
                               delegate:self];
    } else {
        [_popupView dismissItemListView];
    }
}

- (void)didDismissItemListView
{
    UIButton *button = (UIButton *)[self.view viewWithTag:TAG_TOOL_BUTTON];
    button.selected = NO;
}

- (void)didSelectItem:(Item *)item
{    
    UIButton *button = (UIButton *)[self.view viewWithTag:TAG_TOOL_BUTTON];
    button.selected = NO;
    [CommonDiceItemAction useItem:item.type controller:self view:self.view];
    
//    [self useItem:item.type itemName:item.shortName userId:_userManager.userId];
}

- (NSArray *)getSortedUserIdListBeginWithOpenUser
{
    NSArray *sortedPlayingUserList = [_diceService.diceSession.playingUserList sortedArrayUsingComparator: ^(id obj1, id obj2) {
        PBGameUser* user1 = (PBGameUser *)obj1;
        PBGameUser* user2 = (PBGameUser *)obj2;
        if (user1.seatId > user2.seatId) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if (user1.seatId < user2.seatId) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    BOOL found = NO;
    int index = 0;
    for (PBGameUser *user in sortedPlayingUserList) {
        if ([user.userId isEqualToString:_diceService.diceSession.openDiceUserId]) {
            found = YES;
            break;
        }
        index ++;
    }
    
    if (found) {
        NSMutableArray *resultIdList = [[[NSMutableArray alloc] init] autorelease];
        for (int i = index; i < [sortedPlayingUserList count]; i++) {
            PBGameUser *user = [sortedPlayingUserList objectAtIndex:i];
            [resultIdList addObject:user.userId];
        }
        for (int i = 0; i < index ; i++) {
            PBGameUser *user = [sortedPlayingUserList objectAtIndex:i];
            [resultIdList addObject:user.userId];
        }
        return resultIdList;
    } else {
        return [_diceService.diceSession.userDiceList allKeys];
    }
}

#pragma mark - Show game result.
- (void)showGameResult
{
    self.enumerator = [[self getSortedUserIdListBeginWithOpenUser] objectEnumerator];
    
    NSString *userId = [_enumerator nextObject];
    
    [self showUserDice:userId];
}

- (void)showUserDice:(NSString *)userId
{
    PBGameUser* pbUser = [_diceService.session getUserByUserId:userId];
    CustomDiceType type = [CustomDiceManager getUserDiceTypeByPBGameUser:pbUser];
    
    if ([_userManager isMe:userId]) {
        self.myDiceListHolderView.hidden = YES;
    }
    
    UIView *bell = [self bellViewOfUser:userId];
    bell.hidden = YES;
    
    DicesResultView *resultView = [self resultViewOfUser:userId];
    resultView.delegate = self;
    [resultView showUserResult:userId toCenter:self.view.center customDiceType:type];
    
}

- (void)stayDidStart:(int)resultDiceCount
{
    int totalCount = [self.resultDiceCountLabel.text intValue] + resultDiceCount;
    self.resultDiceCountLabel.text = [NSString stringWithFormat:@"%d", totalCount];
}

- (void)moveBackDidStop:(int)resultDiceCount
{
    NSString *userId = [_enumerator nextObject];
    
    if (userId == nil) {
        [self showUserGainCoins];
    }else {
        [self showUserDice:userId];
    }
}

- (void)levelUp:(int)level
{
    // TODO: Show level up animation.
    
}

- (void)coinDidRaiseUp:(DiceAvatarView *)view
{
    [self clearGameResult];
}

- (void)showUserGainCoins
{
    // Add Exp
    if (!_diceService.diceSession.isMeAByStander) {
        [_levelService addExp:LIAR_DICE_EXP delegate:self];
    }
    
    // Show user gainCoins.
    for (NSString *userId in [[_diceService gameResult] allKeys]) {
        PBUserResult *result = [[_diceService gameResult] objectForKey:userId];
        DiceAvatarView *avatar = [self avatarViewOfUser:userId];
        [avatar rewardCoins:result.gainCoins duration:DURATION_SHOW_GAIN_COINS];
        self.myLevelLabel.text = [NSString stringWithFormat:@"LV:%d",_levelService.level];
        if ([_userManager isMe:userId]) {
            [_accountService syncAccount:self];
        }
    }
}

- (void)clearGameResult
{
    self.wildsButton.selected = NO;
    [self dismissAllPopupViews];
    
    for (int index = 1 ; index <= 6; index ++) {
        DicesResultView *resultView = (DicesResultView *)[self.view viewWithTag:RESULT_TAG_OFFSET + index];
        resultView.hidden = YES;
    }
    
    self.resultHolderView.hidden = YES;
    self.wildsFlagButton.hidden = YES;
    self.anteView.hidden = YES;
}

- (void)dismissAllPopupViews
{
    [_popupView dismissCallDiceView];
    [_popupView dismissOpenDiceView];
    [_popupView dismissItemListView];
}

- (IBAction)clickRunAwayButton:(id)sender {
    [self killTimer];
    if (![_diceService.diceSession isMeAByStander] && ([_diceService.diceSession isGamePlaying])) {
        NSString *message = [NSString stringWithFormat:NSLS(@"kDedutCoinQuitGameAlertMessage"), [ConfigManager getDiceFleeCoin]];
        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kQuitGameAlertTitle") 
                                                           message:message
                                                             style:CommonDialogStyleDoubleButton 
                                                          delegate:self
                                           ];
        [dialog showInView:self.view];
    } else {
        [self quitDiceGame];
    }
}

- (int)getSelfIndexFromUserList:(NSArray*)userList
{
    if (userList.count > 0) {
        for (int i = 0; i < userList.count; i ++) {
            PBGameUser* user = [userList objectAtIndex:i];
            if ([user.userId isEqualToString:_userManager.userId]) {
                return i;
            }
        }
    }
    return -1;
}

- (PBGameUser*)getSelfUserFromUserList:(NSArray*)userList
{
    if (userList.count > 0) {
        for (int i = 0; i < userList.count; i ++) {
            PBGameUser* user = [userList objectAtIndex:i];
            if ([user.userId isEqualToString:[_userManager userId]]) {
                return user;
            }
        }
    }
    return nil;
}

- (void)clearAllPlayersAvatar
{
    for (int i = 1; i <= MAX_PLAYER_COUNT; i ++) {
        DiceAvatarView* avatar = (DiceAvatarView*)[self.view viewWithTag:AVATAR_TAG_OFFSET+i];
        avatar.delegate = nil;
    }
}

- (void)clearAllResultViews
{
    for (int index = 1 ; index <= MAX_PLAYER_COUNT; index ++) {
        DicesResultView *resultView = (DicesResultView *)[self.view viewWithTag:RESULT_TAG_OFFSET + index];
        resultView.delegate = nil;
    }
}


- (void)updateAllPlayersAvatar
{
    NSArray* userList = _diceService.session.userList;
    PBGameUser* selfUser = [self getSelfUserFromUserList:userList];
    
    //init seats
    for (int i = 1; i <= MAX_PLAYER_COUNT; i ++) {
        DiceAvatarView* avatar = (DiceAvatarView*)[self.view viewWithTag:AVATAR_TAG_OFFSET+i];
        UILabel* nameLabel = (UILabel*)[self.view viewWithTag:(NICKNAME_TAG_OFFSET+i)];
        avatar.delegate = self;
        [avatar setImage:[[DiceImageManager defaultManager] whiteSofaImage]];
        avatar.userId = nil;
        [nameLabel setText:nil];
    }
    
    // set user on seat
    for (PBGameUser* user in userList) {
//        PPDebug(@"<test>get user--%@, sitting at %d",user.nickName, user.seatId);
        int seat = user.seatId;
        int seatIndex = (MAX_PLAYER_COUNT + selfUser.seatId - seat)%MAX_PLAYER_COUNT + 1;
        DiceAvatarView* avatar = (DiceAvatarView*)[self.view viewWithTag:AVATAR_TAG_OFFSET+seatIndex];
        UILabel* nameLabel = (UILabel*)[self.view viewWithTag:(NICKNAME_TAG_OFFSET+seatIndex)];
        nameLabel.textColor = [UIColor whiteColor];
        [avatar setUrlString:user.avatar 
                      userId:user.userId
                      gender:user.gender 
                       level:user.userLevel 
                  drunkPoint:0 
                      wealth:0];
        if (nameLabel) {
            [nameLabel setText:user.nickName];
        }
    }
}

- (void)rollAllBell
{
    PBGameUser* selfUser = [self getSelfUserFromUserList:[[_diceService session] playingUserList]];
    for (PBGameUser* user in [[_diceService session] playingUserList]) {
        int seat = user.seatId;
        int seatIndex = (MAX_PLAYER_COUNT + selfUser.seatId - seat)%MAX_PLAYER_COUNT + 1;
        UIView* bell = [self.view viewWithTag:BELL_TAG_OFFSET+seatIndex];
        bell.hidden = NO;
        [bell.layer addAnimation:[AnimationManager shakeLeftAndRightFrom:10 to:10 repeatCount:10 duration:1] forKey:@"shake"];
    }
}

- (void)clearAllReciprocol
{
    for (int i = 1; i <= MAX_PLAYER_COUNT; i ++) {
        DiceAvatarView* avatar = (DiceAvatarView*)[self.view viewWithTag:AVATAR_TAG_OFFSET + i];
        [avatar stopReciprocol];
    }
}

- (void)clearAllUrgeUser
{
    [_urgedUser removeAllObjects];
    for (int i = 1; i <= MAX_PLAYER_COUNT; i ++) {
        DiceAvatarView* avatar = (DiceAvatarView*)[self.view viewWithTag:AVATAR_TAG_OFFSET + i];
        [avatar removeFlyClockOnMyHead];
    }

}


#pragma mark - Register notifications.

- (void)registerDiceGameNotifications
{    
    [self registerNotificationWithName:NOTIFICATION_JOIN_GAME_RESPONSE 
                                    usingBlock:^(NSNotification *notification) {                    
                                    }];

    
    [self registerNotificationWithName:NOTIFICATION_ROOM 
                            usingBlock:^(NSNotification *notification) {
         [self roomChanged];
     }];
        
    [self registerNotificationWithName:NOTIFICATION_ROLL_DICE_BEGIN
                                    usingBlock:^(NSNotification *notification) {                       
                                        [self rollDiceBegin];         
                                    }];
    
 
    [self registerNotificationWithName:NOTIFICATION_ROLL_DICE_END
                                    usingBlock:^(NSNotification *notification) {                       
                                        [self rollDiceEnd];         
                                    }];
    
    [self registerNotificationWithName:NOTIFICATION_NEXT_PLAYER_START
                                    usingBlock:^(NSNotification *notification) {  
                                        GameMessage *message = [CommonGameNetworkService userInfoToMessage:notification.userInfo];
                                        NSString* userId = message.currentPlayUserId;
                                        [self nextPlayerStart:userId];         
                                    }];
    
    [self registerNotificationWithName:NOTIFICATION_CALL_DICE_REQUEST
                                    usingBlock:^(NSNotification *notification) {                       
                                        [self someoneCallDice];         
                                    }];
    
    [self registerNotificationWithName:NOTIFICATION_CALL_DICE_RESPONSE
                                    usingBlock:^(NSNotification *notification) {
                                        [self callDiceSuccess];
                                    }];
    
    [self registerNotificationWithName:NOTIFICATION_OPEN_DICE_REQUEST
                                    usingBlock:^(NSNotification *notification) {       
                                        [self someoneOpenDice];         
                                    }];
    
    [self registerNotificationWithName:NOTIFICATION_OPEN_DICE_RESPONSE
                                    usingBlock:^(NSNotification *notification) { 
                                        [self openDiceSuccess];
                                    }];
    
    [self registerNotificationWithName:NOTIFICATION_BET_DICE_REQUEST
                                    usingBlock:^(NSNotification *notification) {
                                        GameMessage *message = [CommonGameNetworkService userInfoToMessage:notification.userInfo];
                                        BOOL win = !message.betDiceRequest.option;
                                        [self someoneBetDice:message.userId win:win];         
                                    }];
    
    [self registerNotificationWithName:NOTIFICATION_BET_DICE_RESPONSE
                                    usingBlock:^(NSNotification *notification) {
                                        [self betDiceSuccess];
                                    }];
    
    [self registerNotificationWithName:NOTIFICATION_GAME_OVER_REQUEST
                                    usingBlock:^(NSNotification *notification) {                       
                                        [self gameOver];         
                                    }];
    
    [self registerNotificationWithName:NOTIFICATION_USER_DICE
                                    usingBlock:^(NSNotification *notification) { 
                                        [self someoneChangeDice];
                                    }];
    
    [self registerNotificationWithName:NOTIFICATION_USE_ITEM_REQUEST
                                    usingBlock:^(NSNotification *notification) {  
                                        GameMessage *message = [CommonGameNetworkService userInfoToMessage:notification.userInfo];
                                        
                                        [CommonDiceItemAction handleItemRequest:message.useItemRequest.itemId 
                                                                         userId:message.userId 
                                                                     controller:self
                                                                           view:self.view 
                                                                        request:message.useItemRequest];      
                                    }];

    
    [self registerNotificationWithName:NOTIFICATION_USE_ITEM_RESPONSE
                                    usingBlock:^(NSNotification *notification) {    
                                        GameMessage *message = [CommonGameNetworkService userInfoToMessage:notification.userInfo];
                                        [CommonDiceItemAction handleItemResponse:message.useItemResponse.itemId 
                                                                      controller:self
                                                                            view:self.view 
                                                                        response:message.useItemResponse];
                                    }];
    
    [self registerNotificationWithName:NOTIFICAIION_CHAT_REQUEST
                                    usingBlock:^(NSNotification *notification) {    
                                        GameMessage *message = [CommonGameNetworkService userInfoToMessage:notification.userInfo];
                                        
                                        if (message.chatRequest.contentType == 1) {
                                            [self someoneSendMessage:message.chatRequest.content 
                                                      contentVoiceId:message.chatRequest.contentVoiceId 
                                                              userId:message.userId];
                                        }else if (message.chatRequest.contentType == 2) {
                                            [self someoneSendExpression:message.chatRequest.expressionId
                                                                 userId:message.userId];
                                        }
                                    }];
    
    
    
    [self registerNotificationWithName:UIApplicationWillEnterForegroundNotification usingBlock:^(NSNotification *note) {
        PPDebug(@"<DiceGamePlayController> Disconnected from server");
        if (![_diceService isConnected]) {
            [self popupUnhappyMessage:NSLS(@"kNetworkBroken") title:@""];
            [self quitDiceGame];            
        }
    }];
}

- (void)someoneChangeDice
{
    if (_diceService.diceSession.isMeAByStander) {
        [self showOtherBells];
    }
}

- (void)showOtherBells
{
    for (PBGameUser *user in _diceService.diceSession.playingUserList) {
        UIView *bell = [self bellViewOfUser:user.userId];
        bell.hidden = NO;
    }
}

#pragma mark - Private methods

- (DiceAvatarView *)selfAvatarView
{
    return (DiceAvatarView*)[self.view viewWithTag:(AVATAR_TAG_OFFSET + 1)];
}

- (DiceAvatarView*)avatarViewOfUser:(NSString*)userId
{
    if ([_userManager isMe:userId]) {
        return [self selfAvatarView];
    }
    
    for (int i = 2; i <= MAX_PLAYER_COUNT; i ++) {
        DiceAvatarView* avatar = (DiceAvatarView*)[self.view viewWithTag:AVATAR_TAG_OFFSET+i];
        if ([avatar.userId isEqualToString:userId]) {
            return avatar;
        }
    }
    return nil;
}

- (UIView *)selfBellView
{
    return [self.view viewWithTag:(BELL_TAG_OFFSET + 1)];
}

- (UIView *)bellViewOfUser:(NSString *)userId
{
    DiceAvatarView *userAvatarView = [self avatarViewOfUser:userId];
    return [self.view viewWithTag:userAvatarView.tag - AVATAR_TAG_OFFSET + BELL_TAG_OFFSET];
}

- (void)hideAllBellViews
{
    for (int i = 1; i <= 6; i ++) {
        UIView *bell = [self.view viewWithTag:(BELL_TAG_OFFSET + i)];
        bell.hidden = YES;
    }
}

- (DicesResultView *)resultViewOfUser:(NSString *)userId
{
    DiceAvatarView *userAvatarView = [self avatarViewOfUser:userId];
    return (DicesResultView *)[self.view viewWithTag:userAvatarView.tag - AVATAR_TAG_OFFSET + RESULT_TAG_OFFSET];
}

- (void)quitDiceGame
{
    [[AdService defaultService] clearAdView:_adView];
    
    [self clearAdHideTimer];
    [self clearAllReciprocol];
    [self clearAllPlayersAvatar];
    [self clearAllResultViews];
    [self dismissAllPopupViews];
    [[DiceGameService defaultService] quitGame];
    [self.navigationController popViewControllerAnimated:YES];
    //[_audioManager backgroundMusicStop];
}

#pragma mark - DiceAvatarViewDelegate
- (void)didClickOnAvatar:(DiceAvatarView*)view
{
    if (view.userId) {
        MyFriend *aFriend = [MyFriend friendWithFid:view.userId
                                           nickName:nil
                                             avatar:nil
                                             gender:nil
                                              level:1];

        [DiceUserInfoView showFriend:aFriend infoInView:self canChat:NO needUpdate:YES];
    }
    
}

#pragma mark - User actions.

- (void)updateDiceSelecetedView
{
    [_diceSelectedView setLastCallDice:_diceService.lastCallDice 
                     lastCallDiceCount:_diceService.lastCallDiceCount 
                      playingUserCount:_diceService.diceSession.playingUserCount
                          maxCallCount:_diceService.maxCallCount];
}

- (void)disableAllDiceOperationButtons
{
    self.openDiceButton.hidden = YES;
    self.wildsButton.enabled = NO;
    self.plusOneButton.enabled = NO;
    [self.diceSelectedView disableUserInteraction];
}

#define CENTER_GAME_BEGIN_NOTE_START  ([DeviceDetection isIPAD] ? CGPointMake(384, 578): CGPointMake(160, 265))
#define CENTER_GAME_BEGIN_NOTE_END  ([DeviceDetection isIPAD] ? CGPointMake(384, 618): CGPointMake(160, 185))

- (void)showBeginNoteAnimation
{
    self.gameBeginNoteLabel.hidden = NO;
    self.gameBeginNoteLabel.alpha = 1;
    self.gameBeginNoteLabel.center = CENTER_GAME_BEGIN_NOTE_START;
    [UIView animateWithDuration:3 delay:0 options:UIViewAnimationCurveLinear animations:^{
        self.gameBeginNoteLabel.alpha = 0;
        self.gameBeginNoteLabel.center = CENTER_GAME_BEGIN_NOTE_END;
    } completion:^(BOOL finished) {
        self.gameBeginNoteLabel.hidden = YES;

    }];
}

- (void)rollDiceBegin
{
    if (![DiceConfigManager meetJoinGameCondictionWithRuleType:_diceService.ruleType]) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kNotEnoughCoinToContinue") delayTime:1.5 isHappy:NO];
        [self quitDiceGame];
    }
        
    [self clearGameResult];
    self.waittingForNextTurnNoteLabel.hidden = YES;
    [self showBeginNoteAnimation];
    [self rollAllBell];
    [_audioManager playSoundById:5];
    
    [self updateDiceSelecetedView];
}

- (void)tellDiceToRobot:(NSArray*)list
{
    [_robotManager newRound:_diceService.diceSession.playingUserCount];
    int diceList[5];
    for (int i = 0; i < 5; i ++) {
        if (i < _diceService.myDiceList.count) {
            diceList[i] = ((PBDice*)[_diceService.myDiceList objectAtIndex:i]).dice;
        }
    }
    [_robotManager introspectRobotDices:diceList];
   // [self.roomNameLabel setText:nil];
}

- (void)rollDiceEnd
{
    self.itemsBoxButton.enabled = YES;
    self.anteLabel.text = [NSString stringWithFormat:@"%d", _diceService.ante]; 
    self.anteView.hidden = NO;
    
    [[self selfBellView] setHidden:YES];
    
    [myDiceListHolderView removeAllSubviews];
    DiceShowView *diceShowView = [[[DiceShowView alloc] initWithFrame:CGRectZero dices:[_diceService myDiceList] userInterAction:NO] autorelease];
    [myDiceListHolderView addSubview:diceShowView];
    
    myDiceListHolderView.hidden = NO;
    
    [self tellDiceToRobot:[_diceService myDiceList]];
}

- (void)removeUrgedUser:(NSString*)userId
{
    [_urgedUser removeObject:userId];
    DiceAvatarView* avatar = [self avatarViewOfUser:userId];
    [avatar removeFlyClockOnMyHead];
}

- (void)userPreStart:(NSString*)userId
{
//    PBGameUser* user = [_diceService.session getUserByUserId:userId];
    if ([_urgedUser containsObject:userId]) {
        [[self avatarViewOfUser:userId] startReciprocol:USER_THINK_TIME_INTERVAL - [ConfigManager getUrgeTime] 
                                                      fromProgress:((float)(USER_THINK_TIME_INTERVAL-[ConfigManager getUrgeTime])/USER_THINK_TIME_INTERVAL)];
        [self removeUrgedUser:userId];
        
//        PPDebug(@"<test> it is %@'s turn, he has been urged.",user.nickName);
        
    } else {
        [[self avatarViewOfUser:userId] startReciprocol:USER_THINK_TIME_INTERVAL];
//        PPDebug(@"<test> it is %@'s turn, he has not been urged.",user.nickName);
    }
}

- (void)robotMakeDecitions
{
    int userCount = _diceService.diceSession.playingUserCount;
    int lastCallDice = _diceService.diceSession.lastCallDice;
    int lastCallDiceCount = _diceService.diceSession.lastCallDiceCount;
    NSString* lastCallUserId = _diceService.diceSession.lastCallDiceUserId;
    BOOL isWild = _diceService.diceSession.wilds;
    
    int diceList[5];
    for (int i = 0; i < 5; i ++) {
        if (i < _diceService.myDiceList.count) {
            diceList[i] = ((PBDice*)[_diceService.myDiceList objectAtIndex:i]).dice;
        }
    }
    
    
    if (_diceService.lastCallUserId == nil) {
        [_robotManager initialCall:_diceService.diceSession.playingUserCount];

    } else {
        [_robotManager updateDecitionByPlayerCount:userCount userId:lastCallUserId number:lastCallDiceCount dice:lastCallDice isWild:isWild myDiceList:diceList];
    }
    
}

- (void)nextPlayerStart:(NSString*)currentUserId
{
//    PBGameUser* user = [_diceService.session getUserByUserId:currentUserId];
//    PPDebug(@"<test> *******it is %@'s turn*********",user.nickName);
    [self clearAllReciprocol];
    
    NSString *currentPlayUserId = currentUserId;
    [self userPreStart:currentPlayUserId];
    
    // 如果自己是旁观者，则在这里返回。
    if (_diceService.diceSession.isMeAByStander) {
        return;
    }
        
    if ([_userManager isMe:currentPlayUserId])
    {                        
        [self.openDiceButton setTitle:NSLS(@"kOpenDice") forState:UIControlStateNormal];
        
        [self robotMakeDecitions];

        // 根据实际叫斋情况判断是否使能斋按钮。
        self.wildsButton.enabled = !_diceService.diceSession.wilds;
        
        // 根据上次叫骰结果判断是否使能+1按钮。
        self.plusOneButton.enabled = (_diceService.lastCallDiceCount >= _diceService.maxCallCount) ? NO : YES;
        
        // 使能叫骰选择区域
        [self.diceSelectedView enableUserInteraction];
        
        // 更新道具列表
        [_popupView updateItemListView];

    }else {
        [self.openDiceButton setTitle:NSLS(@"kScrambleToOpenDice") forState:UIControlStateNormal];
        
        // 不是自己的回合，把下面的按钮全部disable.
        self.wildsButton.enabled = NO;
        self.plusOneButton.enabled = NO;
        [self.diceSelectedView disableUserInteraction];
                
        [_popupView updateItemListView];
    }
    
    // 如果有人叫过，而且叫的人不是自己，则可以显示开按钮。
    if (_diceService.lastCallUserId != nil 
        && ![_userManager isMe:_diceService.lastCallUserId]) {
        self.openDiceButton.hidden = NO;
    }else {
        self.openDiceButton.hidden = YES;
    }
}

#pragma mark - Account Delegate

// Sync Account Delegate
- (void)didSyncFinish
{
    self.myCoinsLabel.text = [NSString stringWithFormat:@"x%d",[[AccountManager defaultManager] getBalanceWithCurrency:PBGameCurrencyCoin]];
}

#pragma mark- Buttons action

-(void)openDiceSuccess
{
    [self popupOpenDiceView];  
    [self playOpenDiceVoice];
    [_popupView dismissItemListView];
    if ([ConfigManager showBetViewEnabled]) {
        [self showWaitForPlayerBetNote];
    }
}

- (void)openDice
{
    [self disableAllDiceOperationButtons];
    [self clearAllReciprocol];
    [_diceSelectedView dismiss];
    [_diceService openDice];
}

- (IBAction)clickOpenDiceButton:(id)sender {
    [self openDice];
}

- (void)someoneOpenDice
{
    [self clearAllReciprocol];
    [self disableAllDiceOperationButtons];
    [_diceSelectedView dismiss];
    [self popupOpenDiceView];  
    [self playOpenDiceVoice];
    [_popupView dismissItemListView];
    
    if ([ConfigManager showBetViewEnabled]) {
        [self showBetView];
    }
}

- (void)playOpenDiceVoice
{   
    BOOL gender = [[_diceService.diceSession getUserByUserId:_diceService.openDiceUserId] gender]; 
    
    if (_diceService.openType == OpenTypeNormal) {
        [_soundManager openDice:gender];
    }else if (_diceService.openType == OpenTypeScramble) {
        [_soundManager scrambleOpen:gender];
    }else if (_diceService.openType == OpenTypeCut) {
        // TODO: play cut voice.
        [_soundManager cutDice:gender];
    }
}


#pragma mark - DiceSelectedViewDelegate

- (void)userUseWilds
{
    self.wildsButton.selected = YES;
    [self showWildsAnim];
}

- (void)destroyWilds
{
    self.wildsButton.selected = NO;
    [self showDestroyWildsAnim];
}

- (IBAction)clickWildsButton:(id)sender {
    self.wildsButton.selected = !self.wildsButton.selected;
}

- (void)callDiceSuccess
{
    [self popupCallDiceView];
    self.anteLabel.text = [NSString stringWithFormat:@"%d", _diceService.ante]; 

    if (_diceService.diceSession.wilds) {
        [self userUseWilds];
    } else {
        [self destroyWilds];
    }
    
    [self playCallDiceVoice];
}

-(void)callDice:(int)dice count:(int)count
{
    [self clearAllReciprocol];
    [self disableAllDiceOperationButtons];
    [_diceSelectedView dismiss];
    
    if (dice == 1 || count == _diceService.session.playingUserCount) {
        [_diceService callDice:dice count:count wilds:YES];
    }else if (count >= _diceService.lastCallDiceCount*2) {
        [_diceService callDice:dice count:count wilds:NO];
    } else{
        [_diceService callDice:dice count:count wilds:self.wildsButton.selected];
    }
}

- (void)didSelectDice:(PBDice *)dice count:(int)count
{   
    [self callDice:dice.dice count:count];
}

- (IBAction)clickPlusOneButton:(id)sender {
    [self takeOver];
}

- (void)reciprocalEnd:(DiceAvatarView*)view
{
    if ([_userManager isMe:view.userId]) {
        [self takeOver];
    }
}

- (void)takeOver
{
    [self hideRobotDecision];
    [self clearAllReciprocol];

    if (_diceService.lastCallDiceCount >= _diceService.maxCallCount) {
        [self openDice];
    }else {
        [self callDice:_diceService.diceSession.lastCallDice count:(_diceService.diceSession.lastCallDiceCount + 1)];
    }
}

- (void)playPlusOneVoice
{
    BOOL gender = [[_diceService.diceSession getUserByUserId:_diceService.lastCallUserId] gender]; 
    [_soundManager plusOne:gender];
}

- (void)someoneCallDice
{   
    [self clearAllReciprocol];
    self.anteLabel.text = [NSString stringWithFormat:@"%d", _diceService.ante]; 
    
    if (_diceService.diceSession.wilds) {
        [self userUseWilds];
    } else {
        [self destroyWilds];
    }

    [self updateDiceSelecetedView];
    [self popupCallDiceView];
    [self playCallDiceVoice];
}

- (void)playCallDiceVoice
{
    BOOL gender = [[_diceService.diceSession getUserByUserId:_diceService.lastCallUserId] gender]; 
    [_soundManager callNumber:_diceService.lastCallDiceCount
                         dice:_diceService.lastCallDice 
                       gender:gender];
}

- (void)gameOver;
{
    [_popupView dismissItemListView];
    self.itemsBoxButton.enabled = NO;
    [self killTimer];
    self.waitForPlayerBetLabel.hidden = YES;
    [self clearAllReciprocol];
    [self clearAllUrgeUser];
    
    self.resultDiceCountLabel.text = @"0";
    self.resultDiceImageView.image = [_customDicemanager diceImageForType:[_customDicemanager getMyDiceType] dice:_diceService.lastCallDice];
    self.resultHolderView.hidden = NO;
    
    [self showGameResult];
}

- (PointDirection)popupDirectionWithUserAvatarViewTag:(int)tag
{
    PointDirection pointDirection = PointDirectionAuto;

    switch (tag - AVATAR_TAG_OFFSET) {
        case 1:
        case 2:
        case 3:
        case 5:
        case 6:
            pointDirection = PointDirectionDown;
            break;
            
        case 4:
            pointDirection = PointDirectionUp;
            break;
            
        default:
            pointDirection = PointDirectionAuto;
            break;
    }
    
    return pointDirection;
}

- (void)popupOpenDiceView
{    
    UIView *atView = [_userManager isMe:_diceService.openDiceUserId] ? myDiceListHolderView : [self avatarViewOfUser:_diceService.openDiceUserId];
    
    PointDirection pointDirection = [self popupDirectionWithUserAvatarViewTag:atView.tag];
    
    [_popupView popupOpenDiceViewWithOpenType:_diceService.openType
                                              atView:atView 
                                              inView:self.view
                                        aboveSubView:self.popupLevel1View
                                      pointDirection:pointDirection];
}

- (void)popupCallDiceView
{
    UIView *atView = [_userManager isMe:_diceService.lastCallUserId] ? myDiceListHolderView : [self avatarViewOfUser:_diceService.lastCallUserId];
    PBGameUser* pbUser = [_diceService.session getUserByUserId:_diceService.lastCallUserId];
    CustomDiceType type = [CustomDiceManager getUserDiceTypeByPBGameUser:pbUser];
    
    PointDirection pointDirection = [self popupDirectionWithUserAvatarViewTag:atView.tag];
    
    [_popupView popupCallDiceViewWithDice:_diceService.lastCallDice
                                           count:_diceService.lastCallDiceCount
                                          atView:atView
                                          inView:self.view
                                    aboveSubView:self.popupLevel1View
                                  pointDirection:pointDirection customDiceType:type];

}

- (void)popupMessageView:(NSString *)message onUser:(NSString *)userId 
{
    DiceAvatarView *view = [self avatarViewOfUser:userId];
    [_popupView popupMessage:message 
                             atView:view
                             inView:self.view
                       aboveSubView:self.popupLevel2View
                     pointDirection:[self popupDirectionWithUserAvatarViewTag:view.tag]];
}

- (void)roomChanged
{
    [self updateAllPlayersAvatar];
    [self updateWaittingForNextTurnNotLabel];
}

- (void)updateWaittingForNextTurnNotLabel
{
    if ([_diceService.diceSession.userList count] == 1) {
        self.waittingForNextTurnNoteLabel.text = NSLS(@"kWaitingForMoreUsers");
        self.waittingForNextTurnNoteLabel.hidden = NO;
    }else if ([_diceService.diceSession.userList count] > 1 && _diceService.diceSession.isMeAByStander) {
        PBGameUser* user = (PBGameUser*)[_diceService.diceSession.userList objectAtIndex:0];
        if (user.isPlaying) {
            self.waittingForNextTurnNoteLabel.text = NSLS(@"kWaittingForNextTurn");
            self.waittingForNextTurnNoteLabel.hidden = NO;
        } else {
            self.waittingForNextTurnNoteLabel.text = NSLS(@"kWaitingForStart");
            self.waittingForNextTurnNoteLabel.hidden = NO;
        }
    } else {
        self.waittingForNextTurnNoteLabel.text = NSLS(@"kWaitingForStart");
    }
}

- (void)showWaitForPlayerBetNote
{
    if (_diceService.diceSession.playingUserCount <= 2) {
        return;
    }
    
    _second = DURATION_PLAYER_BET;
    
    self.waitForPlayerBetLabel.text = [NSString stringWithFormat:NSLS(@"kWaitForPlayerBet"), _second];
    [self.view bringSubviewToFront:self.waitForPlayerBetLabel];

    self.waitForPlayerBetLabel.alpha = 0;
    self.waitForPlayerBetLabel.hidden = NO;
    [UIView animateWithDuration:1 animations:^{
        self.waitForPlayerBetLabel.alpha = 1;
    }];
    
    [self createTimer];
}

- (void)showBetView
{
    if (_diceService.diceSession.isMeAByStander) {
        return;
    }
    
    if ([[_userManager userId] isEqualToString:_diceService.lastCallUserId]
        || [[_userManager userId] isEqualToString:_diceService.openDiceUserId]) {
        [self showWaitForPlayerBetNote];
        return;
    }
    
    NSString *nickName = [_diceService.session getNickNameByUserId:_diceService.openDiceUserId];
    [DiceBetView showInView:self.view 
                   duration:DURATION_PLAYER_BET 
                   openUser:nickName 
                       ante:[_diceService betAnte]
                    winOdds:[_diceService oddsForWin:YES] 
                   loseOdds:[_diceService oddsForWin:NO]
                   delegate:self];
}

- (void)didBetOpenUserWin:(BOOL)win ante:(int)ante odds:(float)odds
{
    PPDebug(@"Bet %@, ante:%d, odds:%f", win?@"win":@"lose", ante, odds);
    [_diceService betOpenUserWin:win];
}


- (IBAction)clickSettingButton:(id)sender {
    DiceSettingView *settingView = [DiceSettingView createDiceSettingView];
    [settingView showInView:self.view];
}

#pragma mark - common dialog delegate
- (void)clickOk:(CommonDialog *)dialog
{
    if (dialog.tag == ROBOT_CALL_TIPS_DIALOG_TAG) {
        if (_robotManager.result.shouldOpen) {
            [self openDice];
        } else {
            [self callDice:_robotManager.result.dice count:_robotManager.result.diceCount];
        }
        return;
    }
    [self quitDiceGame];
    [[AccountService defaultService] deductCoin:[ConfigManager getDiceFleeCoin] source:LiarDiceFleeType];
}

- (void)clickBack:(CommonDialog *)dialog
{
    
}

- (IBAction)clickChatButton:(id)sender {
    if (!self.chatButton.selected) {
        self.chatButton.selected = YES;
        [_popupView popupChatViewAtView:[self selfAvatarView] 
                                 inView:self.view 
                           aboveSubView:self.popupLevel3View
                              deleagate:self];
    }else {
        self.chatButton.selected = NO;
        [_popupView dismissChatView];
    }
}

- (void)didClickCloseButton
{
    self.chatButton.selected = NO;
    [_popupView dismissChatView];
}


- (void)someoneSendMessage:(NSString *)content 
            contentVoiceId:(NSString *)contentVoiceId
                    userId:(NSString *)userId
{
    [self popupMessageView:content onUser:userId];
    [self playMessageVoice:userId contentVoiceId:contentVoiceId.intValue];
}

- (void)playMessageVoice:(NSString *)userId contentVoiceId:(int)contentVoiceId
{
    BOOL gender = [[_diceService.diceSession getUserByUserId:userId] gender]; 
    [[DiceSoundManager defaultManager] playVoiceById:contentVoiceId gender:gender];
}

- (void)someoneSendExpression:(NSString *)expressionId userId:(NSString *)userId
{
    [self showExpression:expressionId userId:userId];
}

- (void)didClickMessage:(CommonChatMessage *)message
{
    self.chatButton.selected = NO;
    [_popupView dismissChatView];
    
    [self popupMessageView:message.content onUser:[_userManager userId]];
    [_diceService chatWithContent:message.content contentVoiceId:[NSString stringWithFormat:@"%d", message.voiceId]];
    
    [self playMessageVoice:_userManager.userId contentVoiceId:message.voiceId];
}

- (void)didClickExepression:(NSString *)key
{
    PPDebug(@"didClickExepression:%@", key);
    self.chatButton.selected = NO;
    [_popupView dismissChatView];
    
    [_diceService chatWithExpression:key];
    
    [self showExpression:key userId:_userManager.userId];
}

- (void)showExpression:(NSString *)key userId:(NSString *)userId
{
    DiceAvatarView *avatar = [self avatarViewOfUser:userId];
    GifView* view = [_expressionManager gifExpressionForKey:key frame:avatar.bounds];
    
    view.userInteractionEnabled = NO;
    [avatar addSubview:view];
    
    [UIView animateWithDuration:1 delay:6.0 options:UIViewAnimationCurveLinear animations:^{
        view.alpha = 0;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
}

#pragma mark - Ad Hide Timer 

- (void)handleAdHideTimer:(id)sender
{
    hideAdCounter ++;    

    [UIView animateWithDuration:2 animations:^{
        if (hideAdCounter % 2 == 0){
            self.adView.alpha = 0;
        }
        else{
            self.adView.alpha = 1.0;
        }
    } completion:^(BOOL finished) {
        if (hideAdCounter % 2 == 0){
            [self.adView setHidden:YES];
        }
        else{
            [self.adView setHidden:NO];
        }
        
    }];    
    
    [self startAdHideTimer];
}



- (void)clearAdHideTimer
{
    if (_adHideTimer != nil){
        if ([_adHideTimer isValid]){
            [_adHideTimer invalidate];
        }

        self.adHideTimer = nil;
    }
}

#define HIDE_AD_TIMER_INTERVAL  5

- (void)startAdHideTimer
{
    if ([[AdService defaultService] isShowAd] == NO)
        return;
    
    [self clearAdHideTimer];
    self.adHideTimer = [NSTimer scheduledTimerWithTimeInterval:HIDE_AD_TIMER_INTERVAL target:self selector:@selector(handleAdHideTimer:) userInfo:nil repeats:NO];
}

- (void)showDestroyWildsAnim
{
    if (self.wildsFlagButton.hidden == NO) {
        self.wildsFlagButton.transform = CGAffineTransformMakeScale(1, 1);
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
            self.wildsFlagButton.transform = CGAffineTransformMakeScale(1.5, 1.5);
        } completion:^(BOOL finished) {
            //self.wildsFlagButton.transform = CGAffineTransformMakeScale(1.5, 1.5);
            [UIView animateWithDuration:1 delay:0.5 options:UIViewAnimationCurveEaseInOut animations:^{
                self.wildsFlagButton.transform = CGAffineTransformMakeScale(0.01, 15);
            } completion:^(BOOL finished) {
                self.wildsFlagButton.transform = CGAffineTransformMakeScale(0.01, 0.01);
                self.wildsFlagButton.hidden = YES;
            }];
        }];
    }
}

- (void)showWildsAnim
{
    if (self.wildsFlagButton.hidden == YES) {
        self.wildsFlagButton.hidden = NO;
        CAAnimation* enlarge = [AnimationManager scaleAnimationWithFromScale:1 toScale:3 duration:0.5 delegate:self removeCompeleted:NO];
        
        enlarge.autoreverses = YES;
        enlarge.repeatCount = 2;
        [self.wildsFlagButton.layer addAnimation:enlarge forKey:@"enlarge"];
    }
}

- (void)urgeUser:(NSString*)userId
{
    [_urgedUser addObject:userId];
    DiceAvatarView* avatar = [self avatarViewOfUser:userId];
    [avatar addFlyClockOnMyHead];
}

- (BOOL)isValidDice:(int)dice count:(int)count
{
    int lastCallDice = (_diceService.lastCallDice < 1 || _diceService.lastCallDice > 6) ? 1 : _diceService.lastCallDice;
    
    int start = (lastCallDice == 1) ? (_diceService.lastCallDiceCount + 1) : _diceService.lastCallDiceCount;
    int end = _diceService.maxCallCount;
    
    start = (start < _diceService.diceSession.playingUserCount) ? _diceService.diceSession.playingUserCount : start;
    end = (end < 7) ? 7 : end;
    if (dice <= 0 || dice > 6 || count < start || count > end) {
        return NO;
    }
    return YES;
}

#pragma mark - common info view delegate
- (void)infoViewDidDisappear:(CommonInfoView*)view
{
    if (view.tag == ROBOT_CALL_TIPS_DIALOG_TAG) {
        _diceRobotDecision = nil;
    }
}

- (void)showRobotDecision
{

    _diceRobotDecision= [CommonDialog createDialogWithTitle:NSLS(@"kCallTips") 
                                                           message:nil 
                                                             style:CommonDialogStyleDoubleButton 
                                                          delegate:self 
                                           ];
    _diceRobotDecision.tag = ROBOT_CALL_TIPS_DIALOG_TAG;
    _diceRobotDecision.disappearDelegate = self;
    
    if (_robotManager.result.shouldOpen) {
        [_diceRobotDecision.messageLabel setText:NSLS(@"kJustOpen")];
    } else {
        if (![self isValidDice:_robotManager.result.dice count:_robotManager.result.diceCount]) {
            _robotManager.result.dice = _diceService.diceSession.lastCallDice;
            _robotManager.result.diceCount = _diceService.diceSession.lastCallDiceCount + 1;
            PPDebug(@"<DiceGamePlayController> robot compute wrong, just add one!");
        }
        
        CallDiceView* view = [[[CallDiceView alloc] initWithDice:_robotManager.result.dice count:_robotManager.result.diceCount] autorelease];
        [_diceRobotDecision.contentView addSubview:view];
        [view setCenter:CGPointMake(_diceRobotDecision.contentView.frame.size.width/2, _diceRobotDecision.contentView.frame.size.height/2)];
        if (_robotManager.result.isWild) {
            UIButton* btn = [[[UIButton alloc] initWithFrame:self.wildsFlagButton.frame] autorelease];
            [btn setBackgroundImage:[UIImage imageNamed:@"zhai_bg.png"] forState:UIControlStateNormal];
            [btn.titleLabel setText:NSLS(@"kDiceWilds")];
            [btn setTitle:NSLS(@"kDiceWilds") forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_diceRobotDecision.contentView addSubview:btn];
            [btn setCenter:CGPointMake(view.frame.origin.x - btn.frame.size.width, view.center.y)];
            
        }
        
    }
    [_diceRobotDecision.oKButton setTitle:NSLS(@"kDoItLikeThis") forState:UIControlStateNormal];
    [_diceRobotDecision.backButton setTitle:NSLS(@"kThinkMyself") forState:UIControlStateNormal];
    [_diceRobotDecision showInView:self.view];

}

- (void)hideRobotDecision
{
    if ([self.view viewWithTag:ROBOT_CALL_TIPS_DIALOG_TAG] != nil) {
        [_diceRobotDecision disappear];
    }
}


#pragma mark - Timer manage

- (void)createTimer
{
    [self killTimer];
    
    PPDebug(@"self count: %d", self.retainCount);
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self 
                                                selector:@selector(handleTimer:)
                                                userInfo:nil 
                                                 repeats:YES];
    
    PPDebug(@"self count: %d", self.retainCount);
}

- (void)killTimer
{
    if ([timer isValid]) {
        [timer invalidate];        
    }
    self.timer = nil;
}

- (void)handleTimer:(NSTimer *)timer
{
    _second--;
    
    self.waitForPlayerBetLabel.text = [NSString stringWithFormat:NSLS(@"kWaitForPlayerBet"), _second];
    
    if (_second <= 0) {
        [self killTimer];
        self.waitForPlayerBetLabel.hidden = YES;
    }
}

- (void)showUserBetResult:(NSString *)userId win:(BOOL)win
{
    DiceAvatarView *myAvatarView = [self avatarViewOfUser:userId];
    
    UIImageView *imageView = [[[UIImageView alloc] initWithFrame:myAvatarView.bounds] autorelease];
    imageView.image = [_imageManager betResultImage:win];
    CGFloat duration = DURATION_PLAYER_BET/2 + _diceService.diceSession.playingUserCount*DURATION_SHOW_RESULT_PER_PLAYER;
    imageView.userInteractionEnabled = NO;
    [myAvatarView addSubview:imageView];
    
    [imageView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:duration];
//    [UIView animateWithDuration:duration delay:0  options:UIViewAnimationOptionCurveLinear animations:^{
//        
//    } completion:^(BOOL finished) {
//        [imageView removeFromSuperview];
//    }];
}

- (void)betDiceSuccess
{
    [self showUserBetResult:_userManager.userId win:_diceService.diceSession.betWin];
}

- (void)someoneBetDice:(NSString *)userId win:(BOOL)win
{
    [self showUserBetResult:userId win:win];
}   


@end
