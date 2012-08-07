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
#import "DicesResultView.h"
#import "Dice.pb.h"
#import "AnimationManager.h"
#import "DiceNotification.h"
#import "GameMessage.pb.h"

#define AVATAR_TAG_OFFSET   1000
#define NICKNAME_TAG_OFFSET 1100
#define RESULT_TAG_OFFSET   3000
#define BELL_TAG_OFFSET     4000

#define MAX_PLAYER_COUNT    6

#define USER_THINK_TIME_INTERVAL 15

@interface DiceGamePlayController ()

@property (retain, nonatomic) DiceSelectedView *diceSelectedView;
@property (retain, nonatomic) NSEnumerator *enumerator;

- (DiceAvatarView *)selfAvatarView;
- (DiceAvatarView*)avatarViewOfUser:(NSString*)userId;

- (void)disableAllDiceOperationButton;
- (void)popResultViewOnAvatarView:(UIView*)view
                         duration:(CFTimeInterval)duration 
                       coinsCount:(int)coinsCount;

@end

@implementation DiceGamePlayController

@synthesize myLevelLabel;
@synthesize myCoinsLabel;
@synthesize myDiceListHolderView;
@synthesize statusButton = _statusButton;
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
@synthesize diceSelectedView = _diceSelectedView;
@synthesize enumerator = _enumerator;
- (void)dealloc {
//    [playingUserList release];
    [myLevelLabel release];
    [myCoinsLabel release];
    [_statusButton release];
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
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    
    self.diceSelectedView = [[[DiceSelectedView alloc] initWithFrame:diceCountSelectedHolderView.bounds superView:self.view] autorelease];
    _diceSelectedView.delegate = self;
    [diceCountSelectedHolderView addSubview:_diceSelectedView];
    
    [self disableAllDiceOperationButton];
    [self hideAllBellViews];
    [[self selfBellView] setHidden:NO];
}


- (void)viewDidUnload
{
    [self setMyLevelLabel:nil];
    [self setMyCoinsLabel:nil];
    [self setOpenDiceButton:nil];
    [self setDiceCountSelectedHolderView:nil];
    [self setMyDiceListHolderView:nil];
    [self setStatusButton:nil];
    [self setRoomNameLabel:nil];
    [self setUserWildsButton:nil];
    [self setPlusOneButton:nil];
    [self setItemsBoxButton:nil];
    [self setWildsLabel:nil];
    [self setPlusOneLabel:nil];
    [self setPopResultView:nil];
    [self setRewardCoinLabel:nil];
    [super viewDidUnload];
}


#define TAG_TOOL_BUTTON 12080101
#define TAG_TOOL_SHEET  12080102
- (IBAction)clickToolButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.tag = TAG_TOOL_BUTTON;
    button.selected = !button.selected;
    
    if (button.selected) {
        NSArray *imageNameList = [NSArray arrayWithObjects:@"tools_bell_bg.png", @"tools_bell_bg.png", @"tools_bell_bg.png",nil];
        NSArray *countNumberList = [NSArray arrayWithObjects:[NSNumber numberWithInt:8], [NSNumber numberWithInt:2], [NSNumber numberWithInt:5], nil];
        
        [_popupViewManager popupToolSheetViewWithImageNameList:imageNameList countNumberList:countNumberList delegate:self atView:button inView:self.view];
    } else {
        [_popupViewManager dismissToolSheetView];
    }
}

- (void)didSelectTool:(NSInteger)index
{    
    UIButton *button = (UIButton *)[self.view viewWithTag:TAG_TOOL_BUTTON];
    button.selected = NO;
}


- (void)showAllUserDices
{
    self.enumerator = [_diceService.diceSession.userDiceList keyEnumerator];
 
    NSString *userId = [_enumerator nextObject];
    if (userId == nil) {
        [self clearGameResult];
        return;
    }
    
    [self showUserDice:userId];
}

- (void)showUserDice:(NSString *)userId
{
    DicesResultView *resultView = [self resultViewOfUser:userId];
    [resultView setDices:[[[_diceService diceSession] userDiceList] objectForKey:userId]];
    [resultView showAnimation:self.view.center delegate:self];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSString *userId = [_enumerator nextObject];
    if (userId == nil) {
        [self clearGameResult];
        return;
    }
    
    [self showUserDice:userId];
}




- (void)clearUserResult:(NSString *)userId
{
    [[self resultViewOfUser:userId] setHidden:YES];
}

- (void)clearAllUserResult
{
    for (int index = 1 ; index <= 6; index ++) {
        DicesResultView *resultView = (DicesResultView *)[self.view viewWithTag:RESULT_TAG_OFFSET + index];
        resultView.hidden = YES;
    }
}

- (void)showGameResult
{
    [self showAllUserDices];
    
    [self showUserResult];
}

- (void)showUserResult
{
    // TODO: show user gainCoins.
    for (NSString *userId in [[_diceService gameResult] allKeys]) {
        PBUserResult *result = [[_diceService gameResult] objectForKey:userId];
        DiceAvatarView *avatar = [self avatarViewOfUser:userId];
//        PPDebug(@"user[%@](user id = %@) %@, avatar center = (%f,%f)", [_diceService.diceSession getNickNameByUserId:userId],[avatar userId], result.win ? @"win" : @"loser", avatar.center.x, avatar.center.y);
//        [self popResultViewOnAvatarView:avatar
//                               duration:5
//                             coinsCount:result.gainCoins];
    }
}

- (void)clearGameResult
{
    [self clearAllUserResult];
}

- (IBAction)clickRunAwayButton:(id)sender {
    [[DiceGameService defaultService] quitGame];
    [self.navigationController popViewControllerAnimated:YES];
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

- (void)updateAllPlayersAvatar
{
    NSArray* userList = _diceService.session.userList;
    PBGameUser* selfUser = [self getSelfUserFromUserList:userList];
    
    //init seats
    for (int i = 1; i <= MAX_PLAYER_COUNT; i ++) {
        DiceAvatarView* avatar = (DiceAvatarView*)[self.view viewWithTag:AVATAR_TAG_OFFSET+i];
        UILabel* nameLabel = (UILabel*)[self.view viewWithTag:(NICKNAME_TAG_OFFSET+i)];
//        UIView* bell = [self.view viewWithTag:BELL_TAG_OFFSET+i];
//        [bell setHidden:YES];
//        UIView* result = [self.view viewWithTag:RESULT_TAG_OFFSET+i];
//        [result setHidden:YES];
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
//        UIView* bell = [self.view viewWithTag:BELL_TAG_OFFSET+seatIndex];
//        [bell setHidden:NO];
//        UIView* result = [self.view viewWithTag:RESULT_TAG_OFFSET+seatIndex];
//        [result setHidden:NO];
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

- (void)shakeAllBell
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


#pragma test server
- (void)registerDiceGameNotification
{
    [[NSNotificationCenter defaultCenter] 
     addObserverForName:NOTIFICATION_JOIN_GAME_RESPONSE
     object:nil     
     queue:[NSOperationQueue mainQueue]     
     usingBlock:^(NSNotification *notification) {                       
         PPDebug(@"<DiceGamePlayController> NOTIFICATION_JOIN_GAME_RESPONSE");         
     }];
    
    [[NSNotificationCenter defaultCenter] 
     addObserverForName:NOTIFICATION_ROOM
     object:nil     
     queue:[NSOperationQueue mainQueue]     
     usingBlock:^(NSNotification *notification) {                       
         PPDebug(@"<DiceGamePlayController> NOTIFICATION_ROOM");      
         GameMessage* message = [CommonGameNetworkService userInfoToMessage:[notification userInfo]];
         RoomNotificationRequest* roomNotification = [message roomNotificationRequest];
         
         if ([roomNotification sessionsChangedList]){
             for (PBGameSessionChanged* sessionChanged in [roomNotification sessionsChangedList]){
                 int sessionId = [sessionChanged sessionId];
                 if (sessionId == _diceService.session.sessionId){
                     // split notification
                     PBGameSessionChanged* changeData = sessionChanged;
                     if ([changeData usersAddedList]){
                         for (PBGameUser* user in [changeData usersAddedList]){
                             // has new user
                             
                         }
                     }
                     
                     if ([changeData userIdsDeletedList]){
                         for (NSString* userId in [changeData userIdsDeletedList]){
                             // has deleted user
                             [self clearUserResult:userId];
                         }
                     }
                     
                 }
             }
         }
         
         [self roomChanged];
     }];
    
    [[NSNotificationCenter defaultCenter] 
     addObserverForName:NOTIFICATION_ROLL_DICE_BEGIN
     object:nil     
     queue:[NSOperationQueue mainQueue]     
     usingBlock:^(NSNotification *notification) {                       
         PPDebug(@"<DiceGamePlayController> NOTIFICATION_ROLL_DICE_BEGIN"); 
         [self rollDiceBegin];         
     }];
    
    
    [[NSNotificationCenter defaultCenter] 
     addObserverForName:NOTIFICATION_ROLL_DICE_END
     object:nil     
     queue:[NSOperationQueue mainQueue]     
     usingBlock:^(NSNotification *notification) {                       
         PPDebug(@"<DiceGamePlayController> NOTIFICATION_ROLL_DICE_END"); 
         [self rollDiceEnd];
     }];
    
    
    [[NSNotificationCenter defaultCenter] 
     addObserverForName:NOTIFICATION_NEXT_PLAYER_START
     object:nil     
     queue:[NSOperationQueue mainQueue]     
     usingBlock:^(NSNotification *notification) {                       
         PPDebug(@"<DiceGamePlayController> NOTIFICATION_NEXT_PLAYER_START"); 
         [self nextPlayerStart];
    }];
    
    
    [[NSNotificationCenter defaultCenter] 
     addObserverForName:NOTIFICATION_CALL_DICE_REQUEST
     object:nil     
     queue:[NSOperationQueue mainQueue]     
     usingBlock:^(NSNotification *notification) {                       
         PPDebug(@"<DiceGamePlayController> NOTIFICATION_CALL_DICE_REQUEST"); 
         [self someoneCallDice];
     }];
    
    
    [[NSNotificationCenter defaultCenter] 
     addObserverForName:NOTIFICATION_OPEN_DICE_REQUEST
     object:nil     
     queue:[NSOperationQueue mainQueue]     
     usingBlock:^(NSNotification *notification) {                       
         PPDebug(@"<DiceGamePlayController> NOTIFICATION_OPEN_DICE_REQUEST"); 
         [self someoneOpenDice];
     }];
    
    [[NSNotificationCenter defaultCenter] 
     addObserverForName:NOTIFICATION_OPEN_DICE_RESPONSE
     object:nil     
     queue:[NSOperationQueue mainQueue]     
     usingBlock:^(NSNotification *notification) {                       
         PPDebug(@"<DiceGamePlayController> NOTIFICATION_OPEN_DICE_RESPONSE"); 
        [self openDiceSuccess];
     }];
    
    
    [[NSNotificationCenter defaultCenter] 
     addObserverForName:NOTIFICATION_GAME_OVER_REQUEST
     object:nil     
     queue:[NSOperationQueue mainQueue]     
     usingBlock:^(NSNotification *notification) {                       
         PPDebug(@"<DiceGamePlayController> NOTIFICATION_GAME_OVER_REQUEST"); 
         //pop open dice view on myself avatar
         [self gameOver];         
     }];

}

- (void)unregisterDiceGameNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:nil
                                                  object:_diceService];
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self 
//                                                    name:NOTIFICATION_ROOM
//                                                  object:nil];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self registerDiceGameNotification];    
    [self updateAllPlayersAvatar];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self unregisterDiceGameNotification];
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

- (void)showBellOfPlayingUsers
{
    for (PBGameUser *user in [[_diceService diceSession] playingUserList]) {
        UIView *bell = [self bellViewOfUser:user.userId];
        bell.hidden = NO;
    }
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


#pragma mark - DiceAvatarViewDelegate
- (void)didClickOnAvatar:(DiceAvatarView*)view
{
    // TODO: popup user info.

}


- (IBAction)clickUseWildsButton:(id)sender {
    UIButton *button =  (UIButton *)sender;
    button.selected = YES;
    button.enabled = NO;
    
    // TODO: Send user wilds command to server.
    
}

#pragma mark - User actions.
- (void)disableAllDiceOperationButton
{
    self.openDiceButton.enabled = NO;
    self.itemsBoxButton.enabled = NO;
    self.userWildsButton.enabled = NO;
    self.plusOneButton.enabled = NO;
    [self.diceSelectedView disableUserInteraction];
}

- (void)enableAllDiceOperationButton
{
    self.openDiceButton.enabled = YES;
    self.itemsBoxButton.enabled = YES;
    self.userWildsButton.enabled = YES;
    self.plusOneButton.enabled = YES;
    [self.diceSelectedView enableUserInteraction];
}

- (void)dismissAllPopupView
{
//    [_popupViewManager dismissCallDiceView];
//    [_popupViewManager dismissOpenDiceView];
//    [_popupViewManager dismissToolSheetView];
}

- (void)rollDiceBegin
{
    [self clearGameResult];
    [self dismissAllPopupView];

    [_diceSelectedView setStart:[[_diceService session] playingUserCount]  end:[[_diceService session] playingUserCount]*5  lastCallDice:6];

    [self showBellOfPlayingUsers];
    [self shakeAllBell];
}

- (void)rollDiceEnd
{
    [[self selfBellView] setHidden:YES];
    
    DiceShowView *diceShowView = [[[DiceShowView alloc] initWithFrame:CGRectZero dices:[_diceService myDiceList] userInterAction:NO] autorelease];
    [myDiceListHolderView addSubview:diceShowView];
    self.myDiceListHolderView.hidden = NO;

    [self enableAllDiceOperationButton];
}

- (void)nextPlayerStart
{
    [self clearAllReciprocol];
    
    NSString *currentPlayUserId = [[_diceService session] currentPlayUserId];
    
    [[self avatarViewOfUser:currentPlayUserId] startReciprocol:USER_THINK_TIME_INTERVAL];
    
    if ([_userManager isMe:currentPlayUserId])
    {
        if (_diceService.diceSession.lastCallDiceUserId == nil) {
            [self enableAllDiceOperationButton];
            self.openDiceButton.enabled = NO;
        }else {
            [self enableAllDiceOperationButton];
        }
    }else {
        [self disableAllDiceOperationButton];
    }
}

#pragma mark - DiceSelectedViewDelegate

- (void)didSelectedDice:(PBDice *)dice count:(int)count
{    
    [_diceService callDice:dice.dice count:count];
    [self someoneCallDice];
}

- (IBAction)clickPlusOneButton:(id)sender {
    [self plusOne];
}

- (void)reciprocalEnd:(DiceAvatarView*)view
{
    if([_userManager isMe:view.userId])
    {
        [self plusOne];
    }
}

- (void)plusOne
{
    [_diceService autoCallDice];
    [self someoneCallDice];
}

- (void)someoneCallDice
{
    if (_diceService.lastCallDice == 6) {
        [_diceSelectedView setStart:([_diceService lastCallDiceCount] + 1)  end:[[_diceService session] playingUserCount]*5  lastCallDice:6];
    }else {
        [_diceSelectedView setStart:[_diceService lastCallDiceCount]  end:[[_diceService session] playingUserCount]*5  lastCallDice:[_diceService lastCallDice]];
    }
    
    [[self avatarViewOfUser:_diceService.lastCallUserId] stopReciprocol];
    [self popupCallDiceView];
}


#pragma mark- Buttons action
- (IBAction)clickOpenDiceButton:(id)sender {
    [_diceService openDice];
}

- (void)openDiceSuccess
{
//    [[self avatarViewOfUser:_diceService.openDiceUserId] stopReciprocol];
//    [self disableAllDiceOperationButton];
//    [self popupOpenDiceView];
    [self someoneOpenDice];
}

- (void)someoneOpenDice
{
    [[self avatarViewOfUser:_diceService.openDiceUserId] stopReciprocol];
    [self disableAllDiceOperationButton];
    [self popupOpenDiceView];    
}

- (void)gameOver;
{
    // Hidden views.
    [self hideAllBellViews];
    self.myDiceListHolderView.hidden = YES;
    
    // Show view.
    [self showGameResult];
}

- (void)popupOpenDiceView
{
    DiceAvatarView *userAvatarView = [self avatarViewOfUser:_diceService.openDiceUserId];
    [_popupViewManager popupOpenDiceViewWithOpenType:_diceService.openType
                                              atView:userAvatarView 
                                              inView:self.view
                                            duration:10];
}

- (void)popupCallDiceView
{
    UIView *atView = [_userManager isMe:_diceService.lastCallUserId] ? myDiceListHolderView : [self avatarViewOfUser:_diceService.lastCallUserId];
    [_popupViewManager popupCallDiceViewWithDice:_diceService.lastCallDice
                                           count:_diceService.lastCallDiceCount
                                          atView:atView
                                          inView:self.view];

}

- (void)popResultViewOnAvatarView:(UIView*)view
                         duration:(CFTimeInterval)duration 
                       coinsCount:(int)coinsCount
{
    self.popResultView.hidden = NO;
    [self.view bringSubviewToFront:self.popResultView];
    [self.rewardCoinLabel setText:[NSString stringWithFormat:@"%d",coinsCount]];
    CGPoint from = CGPointMake(view.center.x, view.center.y+view.frame.size.height/2);
    CGPoint to = CGPointMake(view.center.x, view.center.y-view.frame.size.height/2);
    CAAnimationGroup* pop = [AnimationManager raiseAndDismissFrom:from
                                                               to:to
                                                         duration:duration];
    [self.popResultView.layer addAnimation:pop forKey:@"popResult"];
}

- (void)roomChanged
{
    [self updateAllPlayersAvatar];
}

- (IBAction)clickSettingButton:(id)sender {
//    [[self selfBellView] setHidden:YES]; 
//    DicesResultView *resultView = [self resultViewOfUser:_userManager.userId];
//    [resultView setDices:[self genDiceListStartWith:1 end:5]];
//    [resultView showAnimation:self.view.center];

}

//- (NSArray *)genDiceListStartWith:(int)start end:(int)end
//{
//    NSMutableArray *dices = [NSMutableArray array];
//    
//    for (int i = start; i <= end; i ++) {
//        PBDice_Builder *diceBuilder = [[[PBDice_Builder alloc] init] autorelease];
//        [diceBuilder setDice:i];
//        [diceBuilder setDiceId:i];
//        PBDice *dice = [diceBuilder build];
//        
//        [dices addObject:dice];
//    }
//    
//    return dices;
//}

@end
