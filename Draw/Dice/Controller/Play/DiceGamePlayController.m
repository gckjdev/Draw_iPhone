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

- (void)disableAllDiceOperationButtons;
- (void)enableAllDiceOperationButtons;

- (void)popResultViewOnAvatarView:(UIView*)view
                         duration:(CFTimeInterval)duration 
                       coinsCount:(int)coinsCount;

@end

@implementation DiceGamePlayController

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
@synthesize diceSelectedView = _diceSelectedView;
@synthesize enumerator = _enumerator;

- (void)dealloc {
//    [playingUserList release];
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
    
    // Init dice selected view
    self.diceSelectedView = [[[DiceSelectedView alloc] initWithFrame:diceCountSelectedHolderView.bounds superView:self.view] autorelease];
    [_diceSelectedView setStart:1 end:7 startDice:1];
    _diceSelectedView.delegate = self;
    [diceCountSelectedHolderView addSubview:_diceSelectedView];
    
    // Disable all dice operation buttons.
    [self disableAllDiceOperationButtons];
    [self hideAllBellViews];
    [[self selfBellView] setHidden:NO];
    
    [self registerDiceGameNotifications];    
    
    self.openDiceButton.fontLable.text = NSLS(@"kOpenDice");
    self.wildsFlagButton.hidden = YES;
}


- (void)viewDidUnload
{
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
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateAllPlayersAvatar];
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
        [self showUserResult];
        [self performSelector:@selector(clearGameResult) withObject:nil afterDelay:5];
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
        [self showUserResult];
        [self performSelector:@selector(clearGameResult) withObject:nil afterDelay:5];
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
}

- (void)showUserResult
{
    // TODO: show user gainCoins.
    for (NSString *userId in [[_diceService gameResult] allKeys]) {
        PBUserResult *result = [[_diceService gameResult] objectForKey:userId];
        DiceAvatarView *avatar = [self avatarViewOfUser:userId];
        [avatar rewardCoins:result.gainCoins duration:5];
    }
}

- (void)clearGameResult
{
    [self clearAllUserResult];
}

- (IBAction)clickRunAwayButton:(id)sender {
    [self clearAllReciprocol];
    [[DiceGameService defaultService] quitGame];
    [self unregisterAllNotifications];
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
    
    [self registerDiceGameNotificationWithName:NOTIFICATION_OPEN_DICE_REQUEST
                                    usingBlock:^(NSNotification *notification) {                       
                                        [self someoneOpenDice];         
                                    }];
    
    [self registerDiceGameNotificationWithName:NOTIFICATION_OPEN_DICE_RESPONSE
                                    usingBlock:^(NSNotification *notification) {                       
                                        [self openDiceSuccess];         
                                    }];
    
    [self registerDiceGameNotificationWithName:NOTIFICATION_GAME_OVER_REQUEST
                                    usingBlock:^(NSNotification *notification) {                       
                                        [self gameOver];         
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
    
    // 自己叫过斋之后就不能再叫了
    button.userInteractionEnabled = NO;
    _usingWilds = YES;
}

#pragma mark - User actions.
- (void)disableAllDiceOperationButtons
{
    self.openDiceButton.enabled = NO;
    self.itemsBoxButton.enabled = NO;
    self.userWildsButton.enabled = NO;
    self.plusOneButton.enabled = NO;
    [self.diceSelectedView disableUserInteraction];
}

- (void)enableAllDiceOperationButtons
{
    self.openDiceButton.enabled = YES;
    self.itemsBoxButton.enabled = YES;
    self.userWildsButton.enabled = YES;
    self.plusOneButton.enabled = YES;
    [self.diceSelectedView enableUserInteraction];
}

- (void)rollDiceBegin
{
    [self clearGameResult];

    [_diceSelectedView setStart:[[_diceService session] playingUserCount]  end:[[_diceService session] playingUserCount]*5  startDice:1];
    
    self.userWildsButton.userInteractionEnabled = YES;
    self.wildsFlagButton.hidden = YES;

    [self showBellOfPlayingUsers];
    [self shakeAllBell];
}

- (void)rollDiceEnd
{
    [[self selfBellView] setHidden:YES];
    
    DiceShowView *diceShowView = [[[DiceShowView alloc] initWithFrame:CGRectZero dices:[_diceService myDiceList] userInterAction:NO] autorelease];
    [myDiceListHolderView addSubview:diceShowView];
    self.myDiceListHolderView.hidden = NO;

    [self enableAllDiceOperationButtons];
}

- (void)nextPlayerStart
{
    [self clearAllReciprocol];
    NSString *currentPlayUserId = _diceService.session.currentPlayUserId;
    [[self avatarViewOfUser:currentPlayUserId] startReciprocol:USER_THINK_TIME_INTERVAL];
    
    if ([_userManager isMe:currentPlayUserId])
    {        
        [self enableAllDiceOperationButtons];
 
        self.openDiceButton.fontLable.text = NSLS(@"kOpenDice");
                
        // 没人叫过骰子不能开。
        if (_diceService.diceSession.lastCallDiceUserId == nil) {
            self.openDiceButton.enabled = NO;
        }
        
        // 不能开自己叫的骰子。
        if (_diceService.diceSession.lastCallDiceUserId != nil && [_userManager isMe:_diceService.diceSession.lastCallDiceUserId]) {
            self.openDiceButton.enabled = NO;
        }
        
    }else {
        [self disableAllDiceOperationButtons];
        
        // 有人叫过骰子，而且不是自己叫的骰子，才能开
        if (_diceService.diceSession.lastCallDiceUserId != nil && ![_userManager isMe:_diceService.diceSession.lastCallDiceUserId]) {
            self.openDiceButton.enabled = YES;
            self.openDiceButton.fontLable.text = NSLS(@"kScrambleToOpenDice");
        }
    }
}

#pragma mark - DiceSelectedViewDelegate

-(void)callDice:(int)dice count:(int)count
{
    PPDebug(@"################  ME CALL DICE  #####################");
    
    [self clearAllReciprocol];
    [self disableAllDiceOperationButtons]; 
 
    if (_usingWilds == YES) {
        [_diceService callDice:dice count:count wilds:_usingWilds];
        self.wildsFlagButton.hidden = NO;
        _usingWilds = NO;
    }else {
        [_diceService callDice:dice count:count];
    }
    
    [self popupCallDiceView];
}

- (void)didSelectedDice:(PBDice *)dice count:(int)count
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
        [_diceService openDice];
    }else {
        [self callDice:_diceService.diceSession.lastCallDice count:(_diceService.diceSession.lastCallDiceCount + 1)];
    }
}


- (void)someoneCallDice
{   
    [self clearAllReciprocol];
    
    [_diceSelectedView setStart:(_diceService.lastCallDiceCount + _diceService.lastCallDice/6)  end:_diceService.diceSession.playingUserCount*5  startDice:(_diceService.lastCallDice%6 + 1)];
    
    if (_diceService.diceSession.wilds) {
        self.userWildsButton.userInteractionEnabled = NO;
        self.wildsFlagButton.hidden = NO;
    }
    
    [self popupCallDiceView];
}

#pragma mark- Buttons action

-(void)openDiceSuccess
{
    [self disableAllDiceOperationButtons];
    [self popupOpenDiceView];  
}

- (IBAction)clickOpenDiceButton:(id)sender {
    [self clearAllReciprocol];
    [_diceService openDice];
}

- (void)someoneOpenDice
{
    [self clearAllReciprocol];
    [self disableAllDiceOperationButtons];
    [self popupOpenDiceView];    
}

- (void)gameOver;
{
    [self clearAllReciprocol];
    
    // Hidden views.
    [self hideAllBellViews];
    self.myDiceListHolderView.hidden = YES;
    
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
                                            duration:10
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
    [_popupViewManager popupCallDiceViewWithDice:_diceService.lastCallDice
                                           count:_diceService.lastCallDiceCount
                                          atView:[self selfAvatarView]
                                          inView:self.view
                                  pointDirection:PointDirectionUp];
    
    [_popupViewManager popupOpenDiceViewWithOpenType:0 atView:[self selfAvatarView] inView:self.view duration:5 pointDirection:PointDirectionAuto];

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
