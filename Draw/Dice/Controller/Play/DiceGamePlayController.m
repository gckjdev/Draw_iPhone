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


@interface DiceGamePlayController ()

@property (retain, nonatomic) NSArray *playingUserList;
@property (retain, nonatomic) NSArray *userDiceList;
@property (retain, nonatomic) DiceShowView *diceShowView;

- (UIView *)selfAvatarView;

@end

@implementation DiceGamePlayController

@synthesize playingUserList;
@synthesize myLevelLabel;
@synthesize myCoinsLabel;
@synthesize openDiceButton;
@synthesize fontButton;
@synthesize diceCountSelectedHolderView;
@synthesize userDiceList = _userDiceList;
@synthesize diceShowView = _diceShowView;

- (void)dealloc {
    [playingUserList release];
    [myLevelLabel release];
    [myCoinsLabel release];
    [openDiceButton release];
    [fontButton release];
    [diceCountSelectedHolderView release];
    [_userDiceList release];
    [_diceSelectedView release];
    [_diceShowView release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication] 
     setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    
    // Do any additional setup after loading the view from its nib.
    self.myLevelLabel = [[[FontLabel alloc] initWithFrame:CGRectMake(84, 366, 50, 20) fontName:@"diceFont" pointSize:13] autorelease];
    self.myCoinsLabel = [[[FontLabel alloc] initWithFrame:CGRectMake(84, 386, 50, 20) fontName:@"diceFont" pointSize:13] autorelease];
    
    
    self.fontButton = [[FontButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50) fontName:@"diceFont" pointSize:13];
    self.fontButton.fontLable.text = @"开";
    [self.fontButton addTarget:self action:@selector(clickFontButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.fontButton];
//    self.myLevelLabel = [[[UILabel alloc] initWithFrame:CGRectMake(84, 366, 50, 20)] autorelease];
//    self.myCoinsLabel = [[[UILabel alloc] initWithFrame:CGRectMake(84, 386, 50, 20)] autorelease];
//    
//    myLevelLabel.font = [UIFont fontWithName:@"Papyrus" size:13];
//    myCoinsLabel.font = [UIFont fontWithName:@"Papyrus" size:13];

    myLevelLabel.backgroundColor = [UIColor clearColor];
    myCoinsLabel.backgroundColor = [UIColor clearColor];
    
    
    
    myLevelLabel.text = @"LV:21";
    myCoinsLabel.text = @"开骰";
    
    [self.view addSubview:myLevelLabel];
    [self.view addSubview:myCoinsLabel];
    
    _diceSelectedView = [[DiceSelectedView alloc] initWithFrame:diceCountSelectedHolderView.bounds superView:self.view];
    _diceSelectedView.delegate = self;
    self.playingUserList = [[[DiceGameService defaultService] session] playingUserList];
    [_diceSelectedView setStart:[playingUserList count] end:30  lastCallDice:6];
    [diceCountSelectedHolderView addSubview:_diceSelectedView];
    
    

}

- (void)clickFontButton
{
    PPDebug(@"clickFontButton");
}

- (void)viewDidUnload
{
    [self setMyLevelLabel:nil];
    [self setMyCoinsLabel:nil];
    [self setOpenDiceButton:nil];
    [self setDiceCountSelectedHolderView:nil];
    _diceSelectedView = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    
    //test data
//    NSMutableArray *mutableArray = [[[NSMutableArray alloc] init] autorelease];
//    for (int k = 0; k < 6 ; k++) {
//        PBUserDice_Builder *userDiceBuilder = [[[PBUserDice_Builder alloc] init] autorelease];
//        [userDiceBuilder setUserId:@"TEST"];
//        for (int i = 0 ; i < 5 ; i++) {
//            PBDice_Builder *diceBuilder = [[[PBDice_Builder alloc] init] autorelease];
//            NSUInteger value =  (arc4random() % 6) + 1; 
//            [diceBuilder setDice:value];
//            [diceBuilder setDiceId:i];
//            PBDice *dice = [diceBuilder build];
//            
//            [userDiceBuilder addDices:dice];
//        }
//        PBUserDice *userDice = [userDiceBuilder build];
//        [mutableArray addObject:userDice];
//    }
//    self.userDiceList = mutableArray;
//    [self showAllDicesResult];
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
        avatar.delegate = self;
        [avatar setImage:[[DiceImageManager defaultManager] greenSafaImage]];
        [nameLabel setText:nil];
        
    }
    
    // set user on seat
    for (PBGameUser* user in userList) {
        PPDebug(@"<test>get user--%@, sitting at %d",user.nickName, user.seatId);
        int seat = user.seatId;
        int seatIndex = (MAX_PLAYER_COUNT + selfUser.seatId - seat)%MAX_PLAYER_COUNT + 1;
        DiceAvatarView* avatar = (DiceAvatarView*)[self.view viewWithTag:AVATAR_TAG_OFFSET+seatIndex];
        UILabel* nameLabel = (UILabel*)[self.view viewWithTag:(NICKNAME_TAG_OFFSET+seatIndex)];
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
         
         // TODO show rolling dice animation here
     }];
    
    
    [[NSNotificationCenter defaultCenter] 
     addObserverForName:NOTIFICATION_ROLL_DICE_END
     object:nil     
     queue:[NSOperationQueue mainQueue]     
     usingBlock:^(NSNotification *notification) {                       
         PPDebug(@"<DiceGamePlayController> NOTIFICATION_ROLL_DICE_BEGIN"); 
         // Update dice selected view
         self.playingUserList = [[[DiceGameService defaultService] session] playingUserList];
         [_diceSelectedView setStart:[playingUserList count] end:[playingUserList count]*6  lastCallDice:6];
         [self updateAllPlayersAvatar];
         
         // Update user dices
         
         self.diceShowView = [[[DiceShowView alloc] initWithFrame:CGRectZero dices:[_diceService myDiceList] userInterAction:NO] autorelease];

         
     }];
    
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

- (UIView *)selfAvatarView
{
    return [self.view viewWithTag:(AVATAR_TAG_OFFSET + 1)];
}

#pragma mark - DiceSelectedViewDelegate

- (void)didSelectedDice:(PBDice *)dice count:(int)count
{
    [[DicePopupViewManager defaultManager] popupCallDiceViewWithDice:dice count:count atView:[self selfAvatarView] inView:self.view animated:YES];
}

#pragma mark - DiceAvatarViewDelegate
- (void)didClickOnAvatar:(DiceAvatarView*)view
{
    UIView* bell = [self.view viewWithTag:(view.tag-AVATAR_TAG_OFFSET+BELL_TAG_OFFSET)];
    [bell.layer addAnimation:[AnimationManager shakeLeftAndRightFrom:10 to:10 repeatCount:10 duration:1] forKey:@"shake"];
}
- (void)reciprocalEnd:(DiceAvatarView*)view
{
    
}

    

@end
