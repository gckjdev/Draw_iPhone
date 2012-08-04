//
//  DiceGamePlayController.m
//  Draw
//
//  Created by 小涛 王 on 12-7-27.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceGamePlayController.h"
#import "DiceImageManager.h"
#import "DicePopupViewManager.h"
#import "DiceGameService.h"
#import "DiceGameSession.h"
#import "DiceAvatarView.h"
#import "UserManager.h"
#import "DicesResultView.h"
#import "Dice.pb.h"
#import "AnimationManager.h"
#import "DiceNotification.h"


#define AVATAR_TAG_OFFSET   1000

#define NICKNAME_TAG_OFFSET 1100

#define RESULT_TAG_OFFSET   3000
#define BELL_TAG_OFFSET     4000

#define MAX_PLAYER_COUNT    6

#define USER_THINK_TIME_INTERVAL 15

@interface DiceGamePlayController ()

@property (retain, nonatomic) NSArray *playingUserList;
@property (retain, nonatomic) NSArray *userDiceList;
@property (retain, nonatomic) DiceShowView *diceShowView;

- (DiceAvatarView *)selfAvatarView;
- (DiceAvatarView*)avatarOfUser:(NSString*)userId;
- (void)disableAllOperationButton;

@end

@implementation DiceGamePlayController

@synthesize playingUserList;
@synthesize myLevelLabel;
@synthesize myCoinsLabel;
@synthesize myDiceListHolderView;
@synthesize statusButton = _statusButton;
@synthesize diceCountSelectedHolderView;
@synthesize userDiceList = _userDiceList;
@synthesize diceShowView = _diceShowView;
@synthesize roomNameLabel = _roomNameLabel;
@synthesize openDiceButton = _openDiceButton;

- (void)dealloc {
    [playingUserList release];
    [myLevelLabel release];
    [myCoinsLabel release];
    [_statusButton release];
    [diceCountSelectedHolderView release];
    [_userDiceList release];
    [_diceSelectedView release];
    [_diceShowView release];
    [myDiceListHolderView release];
    [_roomNameLabel release];
    [_openDiceButton release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        _diceService = [DiceGameService defaultService];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] 
     setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    
    _roomNameLabel.text = @"1号房间";
    
    myCoinsLabel.textColor = [UIColor whiteColor];
    myLevelLabel.textColor = [UIColor whiteColor];
    
    [_openDiceButton setBackgroundImage:[[DiceImageManager defaultManager] openDiceButtonBgImage] forState:UIControlStateNormal];
    
    _diceSelectedView = [[DiceSelectedView alloc] initWithFrame:diceCountSelectedHolderView.bounds superView:self.view];
    _diceSelectedView.delegate = self;
    self.playingUserList = [[[DiceGameService defaultService] session] playingUserList];
    [_diceSelectedView setStart:[playingUserList count] end:30  lastCallDice:6];
    [diceCountSelectedHolderView addSubview:_diceSelectedView];
    
//    
//    self.diceShowView = [[[DiceShowView alloc] initWithFrame:CGRectZero dices:[self genDiceListStartWith:1 end:5] userInterAction:NO] autorelease];
//    
//    [myDiceListHolderView addSubview:_diceShowView];
//    
}


- (void)viewDidUnload
{
    [self setMyLevelLabel:nil];
    [self setMyCoinsLabel:nil];
    [self setOpenDiceButton:nil];
    [self setDiceCountSelectedHolderView:nil];
    _diceSelectedView = nil;
    [self setMyDiceListHolderView:nil];
    [self setStatusButton:nil];
    [self setRoomNameLabel:nil];
    [super viewDidUnload];
}

#pragma mark- Buttons action
- (IBAction)clickOpenDiceButton:(id)sender {
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
        
        [[DicePopupViewManager defaultManager] popupToolSheetViewWithImageNameList:imageNameList countNumberList:countNumberList delegate:self atView:button inView:self.view animated:YES];
    } else {
        [[DicePopupViewManager defaultManager] dismissToolSheetViewAnimated:YES];
    }
}

- (void)didSelectTool:(NSInteger)index
{    
    UIButton *button = (UIButton *)[self.view viewWithTag:TAG_TOOL_BUTTON];
    button.selected = NO;
}


- (void)showDicesResultByUserId:(NSString *)userId
{
    int resultIndex = 0;
    
    for (int index = 1 ; index <= 6 ; index ++) {
        int tag = AVATAR_TAG_OFFSET + index;
        DiceAvatarView *tempAvatarView = (DiceAvatarView *)[self.view viewWithTag:tag];
        if ([tempAvatarView.userId isEqualToString:userId]) {
            resultIndex = index;
            break;
        }
    }
    
    PBUserDice *foundUserDice = nil;
    for (PBUserDice *userDice in _userDiceList) {
        if ([userDice.userId isEqualToString:userId]) {
            foundUserDice = userDice;
            break;
        }
    }
    
    DicesResultView *oldDicesResultView = (DicesResultView *)[self.view viewWithTag:RESULT_TAG_OFFSET + resultIndex];
    DicesResultView *dicesResultView = [DicesResultView createDicesResultView];
    dicesResultView.center = oldDicesResultView.center;
    dicesResultView.tag = oldDicesResultView.tag;
    [dicesResultView setUserDices:foundUserDice];
    [oldDicesResultView removeFromSuperview];
    [self.view addSubview:dicesResultView];
}

- (void)showAllDicesResult
{
    for (PBGameUser *user in self.playingUserList) {
        [self showDicesResultByUserId:user.userId];
    } 
}

- (void)clearAllDicesResult
{
    for (int index = 1 ; index <= 6; index ++) {
        DicesResultView *resultView = (DicesResultView *)[self.view viewWithTag:RESULT_TAG_OFFSET + index];
        [resultView clearUserDices];
    }
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
            if ([user.userId isEqualToString:[UserManager defaultManager].userId]) {
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
            if ([user.userId isEqualToString:[UserManager defaultManager].userId]) {
                return user;
            }
        }
    }
    return nil;
}

- (void)updateAllPlayersAvatar
{
    NSArray* userList = [[DiceGameService defaultService].session userList];
    PBGameUser* selfUser = [self getSelfUserFromUserList:userList];
    
    //init seats
    for (int i = 1; i <= MAX_PLAYER_COUNT; i ++) {
        DiceAvatarView* avatar = (DiceAvatarView*)[self.view viewWithTag:AVATAR_TAG_OFFSET+i];
        UILabel* nameLabel = (UILabel*)[self.view viewWithTag:(NICKNAME_TAG_OFFSET+i)];
        UIView* bell = [self.view viewWithTag:BELL_TAG_OFFSET+i];
        [bell setHidden:YES];
        UIView* result = [self.view viewWithTag:RESULT_TAG_OFFSET+i];
        [result setHidden:YES];
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
        UIView* bell = [self.view viewWithTag:BELL_TAG_OFFSET+seatIndex];
        [bell setHidden:NO];
        UIView* result = [self.view viewWithTag:RESULT_TAG_OFFSET+seatIndex];
        [result setHidden:NO];
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
    PBGameUser* selfUser = [self getSelfUserFromUserList:playingUserList];
    for (PBGameUser* user in playingUserList) {
        int seat = user.seatId;
        int seatIndex = (MAX_PLAYER_COUNT + selfUser.seatId - seat)%MAX_PLAYER_COUNT + 1;
        UIView* bell = [self.view viewWithTag:BELL_TAG_OFFSET+seatIndex];
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
         self.playingUserList = [[[DiceGameService defaultService] session] playingUserList];
         [_diceSelectedView setStart:[playingUserList count] end:[playingUserList count]*6  lastCallDice:6];
         [self updateAllPlayersAvatar];
     }];
    
    [[NSNotificationCenter defaultCenter] 
     addObserverForName:NOTIFICATION_ROLL_DICE_BEGIN
     object:nil     
     queue:[NSOperationQueue mainQueue]     
     usingBlock:^(NSNotification *notification) {                       
         PPDebug(@"<DiceGamePlayController> NOTIFICATION_ROLL_DICE_BEGIN"); 
         [self reset];
         [self shakeAllBell];
     }];
    
    
    [[NSNotificationCenter defaultCenter] 
     addObserverForName:NOTIFICATION_ROLL_DICE_END
     object:nil     
     queue:[NSOperationQueue mainQueue]     
     usingBlock:^(NSNotification *notification) {                       
         PPDebug(@"<DiceGamePlayController> NOTIFICATION_ROLL_DICE_END"); 
         // Update dice selected view
         self.playingUserList = [[[DiceGameService defaultService] session] playingUserList];
         [_diceSelectedView setStart:[playingUserList count] end:[playingUserList count]*6  lastCallDice:6];
         [self updateAllPlayersAvatar];
         
         // Update my dices
         [[self selfBellView] setHidden:YES];
    
         self.diceShowView = [[[DiceShowView alloc] initWithFrame:CGRectZero dices:[_diceService myDiceList] userInterAction:NO] autorelease];
         
//         self.diceShowView = [[[DiceShowView alloc] initWithFrame:CGRectZero dices:[self genDiceListStartWith:1 end:5] userInterAction:NO] autorelease];

         [myDiceListHolderView addSubview:_diceShowView];
     }];
    
    
    [[NSNotificationCenter defaultCenter] 
     addObserverForName:NOTIFICATION_NEXT_PLAYER_START
     object:nil     
     queue:[NSOperationQueue mainQueue]     
     usingBlock:^(NSNotification *notification) {                       
         PPDebug(@"<DiceGamePlayController> NOTIFICATION_NEXT_PLAYER_START"); 
         // TODO: clear all reciprocol.
         [self clearAllReciprocol];
         
         NSString *currentPlayUser =  [[_diceService session] currentPlayUserId];
         
         PPDebug(@"currentPlayUser = %@", [[_diceService session] getNickNameByUserId:currentPlayUser]);
         [[self avatarOfUser:currentPlayUser] startReciprocol:USER_THINK_TIME_INTERVAL];
         
         
     }];
    
    
    [[NSNotificationCenter defaultCenter] 
     addObserverForName:NOTIFICATION_CALL_DICE_REQUEST
     object:nil     
     queue:[NSOperationQueue mainQueue]     
     usingBlock:^(NSNotification *notification) {                       
         PPDebug(@"<DiceGamePlayController> NOTIFICATION_CALL_DICE_REQUEST"); 
         // TODO: Popup view on call dice user.
         if (![[UserManager defaultManager] isMe:[_diceService lastCallUserId]]) {
            [[DicePopupViewManager defaultManager] popupCallDiceViewWithDice:[_diceService lastCallDice] 
                                                                       count:[_diceService lastCallDiceCount] 
                                                                      atView:[self avatarOfUser:[_diceService lastCallUserId]]
                                                                      inView:self.view 
                                                                    animated:YES];
         }
         
     }];
    
    
    [[NSNotificationCenter defaultCenter] 
     addObserverForName:NOTIFICATION_OPEN_DICE_REQUEST
     object:nil     
     queue:[NSOperationQueue mainQueue]     
     usingBlock:^(NSNotification *notification) {                       
         PPDebug(@"<DiceGamePlayController> NOTIFICATION_OPEN_DICE_REQUEST"); 
         //disable all operation button
         [self disableAllOperationButton];
         //pop open dice view (only if other player open)
         
     }];
    
    [[NSNotificationCenter defaultCenter] 
     addObserverForName:NOTIFICATION_OPEN_DICE_RESPONSE
     object:nil     
     queue:[NSOperationQueue mainQueue]     
     usingBlock:^(NSNotification *notification) {                       
         PPDebug(@"<DiceGamePlayController> NOTIFICATION_OPEN_DICE_RESPONSE"); 
         //pop open dice view on myself avatar
         
     }];
    
    
}

- (void)reset
{
    [[self selfBellView] setHidden:NO];
    self.diceShowView = nil;
}

- (void)unregisterDiceGameNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:NOTIFICATION_JOIN_GAME_RESPONSE 
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:NOTIFICATION_ROOM
                                                  object:nil];
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

#pragma mark - Praviete methods

- (DiceAvatarView*)avatarOfUser:(NSString*)userId
{
    for (int i = 1; i < MAX_PLAYER_COUNT; i ++) {
        DiceAvatarView* avatar = (DiceAvatarView*)[self.view viewWithTag:AVATAR_TAG_OFFSET+i];
        if ([avatar.userId isEqualToString:userId]) {
            return avatar;
        }
    }
    return nil;
}

- (void)disableAllOperationButton
{
    //TODO: ...
}

- (DiceAvatarView *)selfAvatarView
{
    return (DiceAvatarView*)[self.view viewWithTag:(AVATAR_TAG_OFFSET + 1)];
}

- (UIView *)selfBellView
{
    return [self.view viewWithTag:(BELL_TAG_OFFSET + 1)];
}

#pragma mark - DiceSelectedViewDelegate

- (void)didSelectedDice:(PBDice *)dice count:(int)count
{
    [[DicePopupViewManager defaultManager] popupCallDiceViewWithDice:dice.dice count:count atView:[self selfAvatarView] inView:self.view animated:YES];
//    [[DicePopupViewManager defaultManager] popupOpenDiceViewWithOpenType:0 atView:[self selfAvatarView] inView:self.view animated:YES];
    
    [_diceService callDice:dice.dice count:count];

    [[self selfAvatarView] stopReciprocol];

}

#pragma mark - DiceAvatarViewDelegate
- (void)didClickOnAvatar:(DiceAvatarView*)view
{
    UIView* bell = [self.view viewWithTag:(view.tag-AVATAR_TAG_OFFSET+BELL_TAG_OFFSET)];
    [bell.layer addAnimation:[AnimationManager shakeLeftAndRightFrom:10 to:10 repeatCount:10 duration:1] forKey:@"shake"];
}
- (void)reciprocalEnd:(DiceAvatarView*)view
{
    if([[[UserManager defaultManager] userId] isEqualToString:view.userId])
    {
        // TODO: auto +1 action.
    }
}

    

@end
