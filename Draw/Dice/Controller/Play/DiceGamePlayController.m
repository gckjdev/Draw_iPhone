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

#define AVATAR_TAG_OFFSET   1000

#define NICKNAME_TAG_OFFSET 1100

#define RESULT_TAG_OFFSET   3000
#define BELL_TAG_OFFSET     4000

#define MAX_PLAYER_COUNT    6


@interface DiceGamePlayController ()

@property (retain, nonatomic) NSArray *playingUserList;
@property (retain, nonatomic) NSArray *userDiceList;

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

- (void)dealloc {
    [playingUserList release];
    [myLevelLabel release];
    [myCoinsLabel release];
    [openDiceButton release];
    [diceCountSelectedHolderView release];
    [_userDiceList release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    
    DiceSelectedView *view = [[[DiceSelectedView alloc] initWithFrame:diceCountSelectedHolderView.bounds superView:self.view] autorelease];
    view.delegate = self;
    self.playingUserList = [[[DiceGameService defaultService] session] playingUserList];
    [view setStart:[playingUserList count] end:[playingUserList count]*6  lastCallDice:6];
    [diceCountSelectedHolderView addSubview:view];
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
    
    ToolSheetView *toolSheetView = (ToolSheetView *)[self.view viewWithTag:TAG_TOOL_SHEET];
    
    if (toolSheetView == nil) {
        
        NSArray *imageNameList = [NSArray arrayWithObjects:@"tools_bell_bg.png", @"tools_bell_bg.png", @"tools_bell_bg.png",nil];
        NSArray *countNumberList = [NSArray arrayWithObjects:[NSNumber numberWithInt:8], [NSNumber numberWithInt:2], [NSNumber numberWithInt:5], nil];
                                    
        ToolSheetView *toolSheetView = [[ToolSheetView alloc] initWithImageNameList:imageNameList 
                                                                    countNumberList:countNumberList 
                                                                           delegate:self];
        
        toolSheetView.tag = TAG_TOOL_SHEET;
        [toolSheetView popupAtView:button inView:self.view animated:YES];
        [toolSheetView release];
    } else {
        [toolSheetView dismissAnimated:YES];
    }
}

- (void)didSelectTool:(NSInteger)index
{
    UIButton *button = (UIButton *)[self.view viewWithTag:TAG_TOOL_BUTTON];
    button.selected = !button.selected;
    
    
    //test code
    NSMutableArray *mutableArray = [[[NSMutableArray alloc] init] autorelease];
    for (int k = 0; k < 6 ; k++) {
        PBUserDice_Builder *userDiceBuilder = [[[PBUserDice_Builder alloc] init] autorelease];
        [userDiceBuilder setUserId:@"TEST"];
        for (int i = 0 ; i < 5 ; i++) {
            PBDice_Builder *diceBuilder = [[[PBDice_Builder alloc] init] autorelease];
            NSUInteger value =  (arc4random() % 6) + 1; 
            [diceBuilder setDice:value];
            [diceBuilder setDiceId:i];
            PBDice *dice = [diceBuilder build];
            
            [userDiceBuilder addDices:dice];
        }
        PBUserDice *userDice = [userDiceBuilder build];
        [mutableArray addObject:userDice];
    }
    self.userDiceList = mutableArray;
    [self showAllDicesResult];
}

- (void)showAllDicesResult
{
    int i = 1;
    for (PBUserDice *userDice in _userDiceList) {
        
        DicesResultView *oldDicesResultView = (DicesResultView *)[self.view viewWithTag:RESULT_TAG_OFFSET + i];
        DicesResultView *dicesResultView = [DicesResultView createDicesResultView];
        
        dicesResultView.center = oldDicesResultView.center;
        dicesResultView.tag = oldDicesResultView.tag;
        [dicesResultView setDices:userDice];
        [oldDicesResultView removeFromSuperview];
        [self.view addSubview:dicesResultView];
        i++;
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

- (void)updateAllPlayersAvatar
{
    NSArray* userList = [[DiceGameService defaultService].session userList];
    for (PBGameUser* user in userList) {
        PPDebug(@"<test>get user--%@",user.nickName);
    }
    int index = [self getSelfIndexFromUserList:userList];
    if (index >= 0) {
        for (int i = 0; i < userList.count; i ++) {
            
            int avatarIndex = (MAX_PLAYER_COUNT+i-index)%MAX_PLAYER_COUNT+1;
            DiceAvatarView* avatar = (DiceAvatarView*)[self.view viewWithTag:AVATAR_TAG_OFFSET+avatarIndex];
            UILabel* nameLabel = (UILabel*)[self.view viewWithTag:(NICKNAME_TAG_OFFSET+avatarIndex)];
            PBGameUser* user = [userList objectAtIndex:i];
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
         [self updateAllPlayersAvatar];
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

@end
