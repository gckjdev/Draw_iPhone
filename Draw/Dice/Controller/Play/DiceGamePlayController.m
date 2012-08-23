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
//#import "SpeechService.h"

#import "AdService.h"
#import "DiceUserInfoView.h"

#import "ItemType.h"
#import "GifView.h"

#define AVATAR_TAG_OFFSET   8000
#define NICKNAME_TAG_OFFSET 1100
#define RESULT_TAG_OFFSET   3000
#define BELL_TAG_OFFSET     4000

#define MAX_PLAYER_COUNT    6

#define USER_THINK_TIME_INTERVAL 15

#define DURATION_SHOW_GAIN_COINS 3

#define DURATION_ROLL_BELL 1

@interface DiceGamePlayController ()

@property (retain, nonatomic) DiceSelectedView *diceSelectedView;
@property (retain, nonatomic) NSEnumerator *enumerator;

- (DiceAvatarView *)selfAvatarView;
- (DiceAvatarView*)avatarViewOfUser:(NSString*)userId;

- (void)disableAllDiceOperationButtons;
- (void)enableAllDiceOperationButtons;

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
@synthesize userWildsButton = _userWildsButton;
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


- (void)dealloc {
    [[AdService defaultService] clearAdView:_adView];
    [self setAdView:nil];
    
//    [playingUserList release];
    [_adView release];
    [myLevelLabel release];
    [myCoinsLabel release];
    [diceCountSelectedHolderView release];
    [_diceSelectedView release];
    [myDiceListHolderView release];
    [_roomNameLabel release];
    [_openDiceButton release];
    [_userWildsButton release];
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
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        _diceService = [DiceGameService defaultService];
        _userManager = [UserManager defaultManager];
        _popupViewManager = [DicePopupViewManager defaultManager];
        _imageManager = [DiceImageManager defaultManager];
        _levelService = [LevelService defaultService];
        _accountService = [AccountService defaultService];
        _audioManager = [AudioManager defaultManager];
        _expressionManager = [ExpressionManager defaultManager];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.itemsBoxButton.enabled = NO;

    self.gameBeginNoteLabel.hidden = YES;
    self.gameBeginNoteLabel.text = NSLS(@"kGameBegin");
//    self.gameBeginNoteLabel.textColor = [UIColor colorWithRed:1.0 green:69.0/255.0 blue:246.0/255.0 alpha:1.0];
    
    self.gameBeginNoteLabel.textColor = [UIColor yellowColor];

    
    [_audioManager setBackGroundMusicWithName:@"dice.m4a"];
    [_audioManager backgroundMusicStart];
    self.myLevelLabel.text = [NSString stringWithFormat:@"LV:%d",_levelService.level];;
    self.myCoinsLabel.text = [NSString stringWithFormat:@"x%d",[_accountService getBalance]];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.wildsLabel.textColor = [UIColor whiteColor];
    self.plusOneLabel.textColor = [UIColor whiteColor];    
        
    [[UIApplication sharedApplication] 
     setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    
    //_roomNameLabel.text = @"1号房间";
    _roomNameLabel.text = [NSString stringWithFormat:NSLS(@"kRoomName"), [[[DiceGameService defaultService] session] roomName]]; ;
    
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
    
    self.openDiceButton.fontLable.text = NSLS(@"kOpenDice");
    self.wildsFlagButton.hidden = YES;
    self.resultHolderView.hidden = YES;
    self.openDiceButton.hidden = YES;
    
    [self registerDiceGameNotifications];    
    self.waittingForNextTurnNoteLabel.text = NSLS(@"kWaittingForNextTurn");
    
    self.adView = [[AdService defaultService] createAdInView:self                  
                                                       frame:CGRectMake(0, 0, 320, 50) 
                                                   iPadFrame:CGRectMake(65, 800, 320, 50)
                                                     useLmAd:YES];
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
    [self setUserWildsButton:nil];
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
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateAllPlayersAvatar];
}


#define TAG_TOOL_BUTTON 12080101
- (IBAction)clickToolButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.tag = TAG_TOOL_BUTTON;
    button.selected = !button.selected;
    
    if (button.selected) {
        [_popupViewManager popupItemListAtView:button 
                                        inView:self.view
                                      duration:0
                                      delegate:self];
    } else {
        [_popupViewManager dismissItemListView];
    }
}

- (void)rollDiceAgain
{
    self.myDiceListHolderView.hidden = YES;
    
    // TODO: Reduce item and sync to server.
    
    // TODO: Show animations.
    [self rollUserBell:_userManager.userId];
    
    // TODO: Update myDiceList view.
    [self performSelector:@selector(rollDiceEnd) withObject:nil afterDelay:1];
}


- (void)someoneUseItem:(NSString *)userId
                itemId:(int)itemId;
{
    switch (itemId) {
        case ItemTypeRollAgain:
            // TODO: Show item animation here;
            [self rollUserBell:userId];
            [self showItemAnimationOnUser:userId itemName:NSLS(@"kRollAgain")];
            break;
            
        default:
            break;
    }
}


- (void)useItemSuccess:(int)itemId
{
    switch (itemId) {
        case ItemTypeRollAgain:
            [self rollDiceAgain];
            break;
            
        default:
            break;
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

    switch (item.type) {
        case ItemTypeRollAgain:
            [self useItem:item.type itemName:item.itemName userId:_userManager.userId];
            break;
            
        case ItemTypeCut:
            [self openDice:2];
            break;
            
        default:
            break;
    }
    
    [_accountService consumeItem:item.type amount:1]; 
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
    
    if (userId == nil) {
        [self showUserGainCoins];
    }else {
        [self showUserDice:userId];
    }
}

- (void)showUserDice:(NSString *)userId
{
    if ([_userManager isMe:userId]) {
        self.myDiceListHolderView.hidden = YES;
    }
    
    DicesResultView *resultView = [self resultViewOfUser:userId];
    [resultView setDices:[[[_diceService diceSession] userDiceList] objectForKey:userId] resultDice:_diceService.lastCallDice wilds:_diceService.diceSession.wilds];
    [resultView showAnimation:self.view.center];
    resultView.delegate = self;
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
    // TODO: show user gainCoins.
    for (NSString *userId in [[_diceService gameResult] allKeys]) {
        PBUserResult *result = [[_diceService gameResult] objectForKey:userId];
        DiceAvatarView *avatar = [self avatarViewOfUser:userId];
        [avatar rewardCoins:result.gainCoins duration:DURATION_SHOW_GAIN_COINS];
        
        if ([_userManager isMe:userId]) {
            
            [_levelService addExp:LIAR_DICE_EXP delegate:self];

            if (result.gainCoins > 0) {
                [_accountService chargeAccount:result.gainCoins source:LiarDiceWinType];
            }else{
                [_accountService deductAccount:abs(result.gainCoins) source:LiarDiceWinType];
            }
            self.myCoinsLabel.text = [NSString stringWithFormat:@"x%d",[_accountService getBalance]];
        }
    }
}

- (void)clearGameResult
{
    _usingWilds = NO;
    self.userWildsButton.selected = NO;
    [self dismissAllPopupViews];
    
    for (int index = 1 ; index <= 6; index ++) {
        DicesResultView *resultView = (DicesResultView *)[self.view viewWithTag:RESULT_TAG_OFFSET + index];
        resultView.hidden = YES;
    }
    
    self.resultHolderView.hidden = YES;
    self.wildsFlagButton.hidden = YES;
}

- (void)dismissAllPopupViews
{
    [_popupViewManager dismissCallDiceView];
    [_popupViewManager dismissOpenDiceView];
    [_popupViewManager dismissItemListView];
}

- (IBAction)clickRunAwayButton:(id)sender {
    if (![_diceService.diceSession isMeAByStander]) {
        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kQuitGameAlertTitle") message:NSLS(@"kQuitGameAlertMessage") style:CommonDialogStyleDoubleButton delegate:self theme:CommonDialogThemeDice];
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
        PPDebug(@"<test>get user--%@, sitting at %d",user.nickName, user.seatId);
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

- (void)rollUserBell:(NSString *)userId
{
    UIView *bell = [self bellViewOfUser:userId];
    bell.hidden = NO;
    [bell.layer addAnimation:[AnimationManager shakeLeftAndRightFrom:10 to:10 repeatCount:10 duration:1] forKey:@"shake"];
}

- (void)clearAllReciprocol
{
    for (int i = 1; i <= MAX_PLAYER_COUNT; i ++) {
        DiceAvatarView* avatar = (DiceAvatarView*)[self.view viewWithTag:AVATAR_TAG_OFFSET + i];
        [avatar stopReciprocol];
    }
}


#pragma mark - Register notifications.

- (void)registerDiceGameNotificationWithName:(NSString *)name 
                                  usingBlock:(void (^)(NSNotification *note))block
{
    PPDebug(@"<%@> name", [self description]);         

    [self registerNotificationWithName:name 
                                object:nil 
                                 queue:[NSOperationQueue mainQueue] 
                            usingBlock:block];
}

- (void)registerDiceGameNotifications
{    
    [self registerDiceGameNotificationWithName:NOTIFICATION_JOIN_GAME_RESPONSE 
                                    usingBlock:^(NSNotification *notification) {                       
                                    }];

    
    [self registerDiceGameNotificationWithName:NOTIFICATION_ROOM 
                            usingBlock:^(NSNotification *notification) {    
                                
//         GameMessage* message = [CommonGameNetworkService userInfoToMessage:[notification userInfo]];
//         RoomNotificationRequest* roomNotification = [message roomNotificationRequest];
//         
//         if ([roomNotification sessionsChangedList]){
//             for (PBGameSessionChanged* sessionChanged in [roomNotification sessionsChangedList]){
//                 int sessionId = [sessionChanged sessionId];
//                 if (sessionId == _diceService.session.sessionId){
//                     // split notification
//                     PBGameSessionChanged* changeData = sessionChanged;
//                     if ([changeData usersAddedList]){
//                         for (PBGameUser* user in [changeData usersAddedList]){
//                             // has new user
//                             
//                         }
//                     }
//                     
//                     if ([changeData userIdsDeletedList]){
//                         for (NSString* userId in [changeData userIdsDeletedList]){
//                             // has deleted user
//                             [self clearUserResult:userId];
//                         }
//                     }
//                     
//                 }
//             }
//         }
         
         [self roomChanged];
     }];
        
    [self registerDiceGameNotificationWithName:NOTIFICATION_ROLL_DICE_BEGIN
                                    usingBlock:^(NSNotification *notification) {                       
                                        [self rollDiceBegin];         
                                    }];
    
 
    [self registerDiceGameNotificationWithName:NOTIFICATION_ROLL_DICE_END
                                    usingBlock:^(NSNotification *notification) {                       
                                        [self rollDiceEnd];         
                                    }];
    
    [self registerDiceGameNotificationWithName:NOTIFICATION_NEXT_PLAYER_START
                                    usingBlock:^(NSNotification *notification) {                       
                                        [self nextPlayerStart];         
                                    }];
    
    [self registerDiceGameNotificationWithName:NOTIFICATION_CALL_DICE_REQUEST
                                    usingBlock:^(NSNotification *notification) {                       
                                        [self someoneCallDice];         
                                    }];
    
    [self registerDiceGameNotificationWithName:NOTIFICATION_CALL_DICE_RESPONSE
                                    usingBlock:^(NSNotification *notification) {
                                        GameMessage *message = [CommonGameNetworkService userInfoToMessage:notification.userInfo];
                                        if (message.resultCode == 0) {
                                            [self callDiceSuccess];
                                        }
                                    }];
    
    [self registerDiceGameNotificationWithName:NOTIFICATION_OPEN_DICE_REQUEST
                                    usingBlock:^(NSNotification *notification) {       
                                        [self someoneOpenDice];         
                                    }];
    
    [self registerDiceGameNotificationWithName:NOTIFICATION_OPEN_DICE_RESPONSE
                                    usingBlock:^(NSNotification *notification) { 
                                        GameMessage *message = [CommonGameNetworkService userInfoToMessage:notification.userInfo];
                                        if (message.resultCode == 0) {
                                            [self openDiceSuccess];
                                        }
                                    }];
    
    [self registerDiceGameNotificationWithName:NOTIFICATION_GAME_OVER_REQUEST
                                    usingBlock:^(NSNotification *notification) {                       
                                        [self gameOver];         
                                    }];
    
    [self registerDiceGameNotificationWithName:NOTIFICATION_USER_DICE
                                    usingBlock:^(NSNotification *notification) { 
//                                        [self someoneChangeDices];
                                    }];
    
    [self registerDiceGameNotificationWithName:NOTIFICATION_USE_ITEM_REQUEST
                                    usingBlock:^(NSNotification *notification) {  
                                        GameMessage *message = [CommonGameNetworkService userInfoToMessage:notification.userInfo];
                                        PPDebug(@"[改]user:%@ use item %d.", message.userId, message.useItemRequest.itemId);
                                        [self someoneUseItem:message.userId 
                                                      itemId:message.useItemRequest.itemId];         
                                    }];

    
    [self registerDiceGameNotificationWithName:NOTIFICATION_USE_ITEM_RESPONSE
                                    usingBlock:^(NSNotification *notification) {    
                                        GameMessage *message = [CommonGameNetworkService userInfoToMessage:notification.userInfo];
                                        if (message.resultCode == 0) {
                                            [self useItemSuccess:message.useItemResponse.itemId];         
                                        }
                                    }];
    
    [self registerDiceGameNotificationWithName:NOTIFICAIION_CHAT_REQUEST
                                    usingBlock:^(NSNotification *notification) {    
                                        GameMessage *message = [CommonGameNetworkService userInfoToMessage:notification.userInfo];
                                        
                                        if (message.chatRequest.chatType == 1) {
                                            [self someoneSendMessage:message.chatRequest.content 
                                                      contentVoiceId:message.chatRequest.contentVoiceId 
                                                              userId:message.userId];
                                        }else if (message.chatRequest.chatType == 2) {
                                            [self someoneSendExpression:message.chatRequest.expressionId
                                                                 userId:message.userId];
                                        }
                                    }];
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
    [self clearAllReciprocol];
    [self clearAllPlayersAvatar];
    [self clearAllResultViews];
    [self dismissAllPopupViews];
    [[DiceGameService defaultService] quitGame];
    [self unregisterAllNotifications];
    [self.navigationController popViewControllerAnimated:YES];
    [_audioManager backgroundMusicStop];
}

#pragma mark - DiceAvatarViewDelegate
- (void)didClickOnAvatar:(DiceAvatarView*)view
{
    if (view.userId) {
        [DiceUserInfoView showUser:view.userId nickName:nil avatar:nil gender:nil location:nil level:0 hasSina:NO hasQQ:NO hasFacebook:NO infoInView:self];
    }
    
}




#pragma mark - User actions.

- (void)updateDiceSelecetedView
{
    [_diceSelectedView setLastCallDice:_diceService.lastCallDice 
                     lastCallDiceCount:_diceService.lastCallDiceCount 
                      playingUserCount:_diceService.diceSession.playingUserCount];
}

- (void)disableAllDiceOperationButtons
{
    self.openDiceButton.hidden = YES;
    self.userWildsButton.enabled = NO;
    self.plusOneButton.enabled = NO;
    [_popupViewManager disableCutItem];
    [self.diceSelectedView disableUserInteraction];
}

- (void)enableAllDiceOperationButtons
{
    self.openDiceButton.hidden = NO;
    self.userWildsButton.enabled = YES;
    self.plusOneButton.enabled = YES;
    [_popupViewManager enableCutItem];
    [self.diceSelectedView enableUserInteraction];
}

- (void)showBeginNoteAnimation
{
    self.gameBeginNoteLabel.hidden = NO;
    self.gameBeginNoteLabel.alpha = 1;
    self.gameBeginNoteLabel.center = CGPointMake(160, 265);
    [UIView animateWithDuration:3 delay:0 options:UIViewAnimationCurveLinear animations:^{
        self.gameBeginNoteLabel.alpha = 0;
        self.gameBeginNoteLabel.center = CGPointMake(160, 185);
    } completion:^(BOOL finished) {
        self.gameBeginNoteLabel.hidden = YES;

    }];
}

- (void)rollDiceBegin
{
    [self clearGameResult];
    self.waittingForNextTurnNoteLabel.hidden = YES;
    [self showBeginNoteAnimation];
    [self rollAllBell];
    [_audioManager playSoundById:5];
    
    [self updateDiceSelecetedView];

}

- (void)rollDiceEnd
{
    self.itemsBoxButton.enabled = YES;
    [[self selfBellView] setHidden:YES];
    
    DiceShowView *diceShowView = [[[DiceShowView alloc] initWithFrame:CGRectZero dices:[_diceService myDiceList] userInterAction:NO] autorelease];
    [myDiceListHolderView addSubview:diceShowView];
    
    myDiceListHolderView.hidden = NO;
}

- (void)nextPlayerStart
{
    [self clearAllReciprocol];
    
    NSString *currentPlayUserId = _diceService.session.currentPlayUserId;
    [[self avatarViewOfUser:currentPlayUserId] startReciprocol:USER_THINK_TIME_INTERVAL];
    
    if ([_userManager isMe:currentPlayUserId])
    {        
        [self enableAllDiceOperationButtons];
        
        self.userWildsButton.enabled = !_diceService.diceSession.wilds;
        [self.diceSelectedView enableUserInteraction];
        
 
        self.openDiceButton.fontLable.text = NSLS(@"kOpenDice");
                
        // 没人叫过骰子不能开。
        if (_diceService.diceSession.lastCallDiceUserId == nil) {
            self.openDiceButton.hidden = YES;
            [_popupViewManager disableCutItem];
        }
        
        // 不能开自己叫的骰子。
        if (_diceService.diceSession.lastCallDiceUserId != nil && [_userManager isMe:_diceService.diceSession.lastCallDiceUserId]) {
            self.openDiceButton.hidden = YES;
            [_popupViewManager disableCutItem];
        }
        
        if (_diceService.diceSession.lastCallDiceCount >= _diceService.diceSession.playingUserCount*5) {
            self.plusOneButton.enabled = NO;
        }
        
        
    }else {
        [self disableAllDiceOperationButtons];
        
        // 不是旁观者，有人叫过骰子，而且不是自己叫的骰子，才能开
        if (!_diceService.diceSession.isMeAByStander && 
            _diceService.diceSession.lastCallDiceUserId != nil 
            && ![_userManager isMe:_diceService.diceSession.lastCallDiceUserId]) {
//            self.openDiceButton.enabled = YES;
            self.openDiceButton.hidden = NO;
            [_popupViewManager enableCutItem];
            self.openDiceButton.fontLable.text = NSLS(@"kScrambleToOpenDice");
        }
    }
}

#pragma mark - use item animations
- (void)useItem:(int)itemId itemName:(NSString *)itemName userId:(NSString *)userId
{
    [_diceService userItem:itemId];
    [self showItemAnimationOnUser:userId itemName:itemName];
}


#pragma mark- Buttons action

-(void)openDiceSuccess
{
//    [self disableAllDiceOperationButtons];
    [self popupOpenDiceView];  
}

- (void)openDice:(int)multiple
{
    [self disableAllDiceOperationButtons];
    [self clearAllReciprocol];
    [_diceService openDice:1];
}

- (IBAction)clickOpenDiceButton:(id)sender {
    [self openDice:1];
}

- (void)someoneOpenDice
{
    [self clearAllReciprocol];
    [self disableAllDiceOperationButtons];
    
//    NSString *str = (_diceService.diceSession.openType == 0) ? NSLS(@"kOpenDice") : NSLS(@"kScrambleToOpenDice") ;
//    [[SpeechService defaultService] play:str gender:YES];
    
    [self popupOpenDiceView];  
}


#pragma mark - DiceSelectedViewDelegate

- (void)userUseWilds
{
    _usingWilds = YES;
    self.userWildsButton.selected = YES;
    self.userWildsButton.enabled = NO;
    self.wildsFlagButton.hidden = NO;
}

- (IBAction)clickUseWildsButton:(id)sender {
    [self userUseWilds];
}

- (void)callDiceSuccess
{
//    [self disableAllDiceOperationButtons]; 
    [self popupCallDiceView];
}

-(void)callDice:(int)dice count:(int)count
{
    [self clearAllReciprocol];
    [self disableAllDiceOperationButtons]; 
    
    if (dice == 1 || count == _diceService.session.playingUserCount) {
        [self userUseWilds];
    }
    
    [_diceService callDice:dice count:count wilds:_usingWilds];
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
    [self clearAllReciprocol];

    if (_diceService.diceSession.lastCallDiceCount >= _diceService.diceSession.playingUserCount*5) {
        [self openDice:1];
    }else {
        [self callDice:_diceService.diceSession.lastCallDice count:(_diceService.diceSession.lastCallDiceCount + 1)];
    }
}

- (void)someoneCallDice
{   
    [self clearAllReciprocol];
    
    if (_diceService.diceSession.wilds) {
        [self userUseWilds];
    }

    [self updateDiceSelecetedView];
            
    [self popupCallDiceView];
}


- (void)gameOver;
{
    [_popupViewManager dismissItemListView];
    self.itemsBoxButton.enabled = NO;
    [self clearAllReciprocol];
    
    // Hidden views.
    [self hideAllBellViews];
    //self.myDiceListHolderView.hidden = YES;
    
    self.resultDiceCountLabel.text = @"0";
    self.resultDiceImageView.image = [_imageManager diceImageWithDice:_diceService.lastCallDice];
    self.resultHolderView.hidden = NO;
    
    // Show view.
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
    DiceAvatarView *userAvatarView = [self avatarViewOfUser:_diceService.openDiceUserId];
    
    PointDirection pointDirection = [self popupDirectionWithUserAvatarViewTag:userAvatarView.tag];
    
    [_popupViewManager popupOpenDiceViewWithOpenType:_diceService.openType
                                              atView:userAvatarView 
                                              inView:self.view
//                                            duration:(_diceService.diceSession.playingUserCount*4+3)
                                      pointDirection:pointDirection];
}

- (void)popupCallDiceView
{
    UIView *atView = [_userManager isMe:_diceService.lastCallUserId] ? myDiceListHolderView : [self avatarViewOfUser:_diceService.lastCallUserId];
    
    PointDirection pointDirection = [self popupDirectionWithUserAvatarViewTag:atView.tag];
    
    [_popupViewManager popupCallDiceViewWithDice:_diceService.lastCallDice
                                           count:_diceService.lastCallDiceCount
                                          atView:atView
                                          inView:self.view
                                  pointDirection:pointDirection];

}

- (void)popupMessageView:(NSString *)message onUser:(NSString *)userId 
{
    DiceAvatarView *view = [self avatarViewOfUser:userId];
    [_popupViewManager popupMessage:message 
                             atView:view
                             inView:self.view
                     pointDirection:[self popupDirectionWithUserAvatarViewTag:view.tag]];
}

- (void)roomChanged
{
    [self updateAllPlayersAvatar];
}

- (IBAction)clickSettingButton:(id)sender {
}

#pragma mark - common dialog delegate
- (void)clickOk:(CommonDialog *)dialog
{
    [self quitDiceGame];
    [[AccountService defaultService] deductAccount:200 source:LiarDiceFleeType];
}

- (void)clickBack:(CommonDialog *)dialog
{
    
}

#pragma mark - Item animations.
- (void)showItemAnimationOnUser:(NSString*)userId itemName:(NSString *)itemName
{
    HKGirlFontLabel *label = [[[HKGirlFontLabel alloc] initWithFrame:CGRectMake(0, 0, 70, 70) pointSize:50] autorelease];
    label.text = itemName;
    label.center = self.view.center;
    
    [self.view addSubview:label];
    
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationCurveEaseInOut animations:^{
        label.center = [[self bellViewOfUser:userId] center];
        label.transform = CGAffineTransformMakeScale(0.3, 0.3);
        label.alpha = 0.3;
    } completion:^(BOOL finished) {
        [label removeFromSuperview];
    }];
}

- (IBAction)clickChatButton:(id)sender {
    self.chatButton.selected = !self.chatButton.selected;
    if (self.chatButton.selected) {
        [_popupViewManager popupChatViewAtView:sender inView:self.view deleagate:self];
    }else {
        [_popupViewManager dismissChatView];
    }
}

- (void)someoneSendMessage:(NSString *)content 
            contentVoiceId:(NSString *)contentVoiceId
                    userId:(NSString *)userId
{
    [self popupMessageView:content onUser:userId];
    
    // TODO: Play voice here;
}

- (void)someoneSendExpression:(NSString *)expressionId userId:(NSString *)userId
{
    [self playExpression:expressionId userId:userId];
}

- (void)didClickMessage:(NSString *)message
{
    self.chatButton.selected = NO;
    [_popupViewManager dismissChatView];
    
    [self popupMessageView:message onUser:[_userManager userId]];
    [_diceService chatWithContent:message contentVoiceId:nil];
    
    // TODO: Play voice here;

}

- (void)didClickExepression:(NSString *)key
{
    PPDebug(@"didClickExepression:%@", key);
    self.chatButton.selected = NO;
    [_popupViewManager dismissChatView];
    
    // TODO: Popup image for expression.
    [self playExpression:key userId:_userManager.userId];
}

- (void)playExpression:(NSString *)key userId:(NSString *)userId
{
    DiceAvatarView *avatar = [self avatarViewOfUser:userId];
    NSString *filePath = [_expressionManager gifPathForExpression:key];
    if (filePath == nil) {
        return;
    }
    GifView* view = [[[GifView alloc] initWithFrame:avatar.frame
                                           filePath:filePath
                                   playTimeInterval:0.5] autorelease];
    [self.view addSubview:view];
    [view performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:6.0];
}


@end
