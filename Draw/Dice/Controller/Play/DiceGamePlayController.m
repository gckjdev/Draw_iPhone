//
//  DiceGamePlayController.m
//  Draw
//
//  Created by 小涛 王 on 12-7-27.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceGamePlayController.h"
#import "DiceImageManager.h"
#import "DicePopupView.h"
#import "DiceSelectedView.h"
#import "DiceGameService.h"
#import "DiceGameSession.h"
#import "DiceAvatarView.h"
#import "UserManager.h"

#define AVATAR_TAG_OFFSET   1000
#define NICKNAME_TAG_OFFSET 2000

@interface DiceGamePlayController ()

@end

@implementation DiceGamePlayController
@synthesize myLevelLabel;
@synthesize myCoinsLabel;
@synthesize openDiceButton;
@synthesize fontButton;
@synthesize diceCountSelectedHolderView;

- (void)dealloc {
    [myLevelLabel release];
    [myCoinsLabel release];
    [openDiceButton release];
    [diceCountSelectedHolderView release];
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
    [view setStart:1 end:12];
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
    PBDice_Builder *diceBuilder = [[[PBDice_Builder alloc] init] autorelease];
    [diceBuilder setDice:1];
    [diceBuilder setDiceId:1];
    PBDice *dice = [diceBuilder build];
    
    
    [DicePopupView popupCallDiceViewWithDice:dice count:2 atView:(UIView*)sender inView:self.view animated:YES];
    
}

#define TAG_TOOL_BUTTON 12080101
#define TAG_TOOL_SHEET  12080102
- (IBAction)clickToolButton:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.tag = TAG_TOOL_BUTTON;
    button.selected = !button.selected;
    
    ToolSheetView *toolSheetView = (ToolSheetView *)[self.view viewWithTag:TAG_TOOL_SHEET];
    
    if (toolSheetView == nil) {
        CGPoint fromPoint  = CGPointMake(button.frame.origin.x + 0.5 * button.frame.size.width, button.frame.origin.y );
        NSArray *imageNameList = [NSArray arrayWithObjects:@"tools_bell_bg.png", @"tools_bell_bg.png", @"tools_bell_bg.png",nil];
        NSArray *countNumberList = [NSArray arrayWithObjects:[NSNumber numberWithInt:8], [NSNumber numberWithInt:2], [NSNumber numberWithInt:5], nil];
                                    
        ToolSheetView *toolSheetView = [[ToolSheetView alloc] initWithImageNameList:imageNameList 
                                                                    countNumberList:countNumberList 
                                                                           delegate:self];
        
        toolSheetView.tag = TAG_TOOL_SHEET;
        [toolSheetView showInView:self.view fromFottomPoint:fromPoint];
        [toolSheetView release];
    } else {
        [toolSheetView removeFromSuperview];
    }
}

- (void)didSelectTool:(NSInteger)index
{
    UIButton *button = (UIButton *)[self.view viewWithTag:TAG_TOOL_BUTTON];
    button.selected = !button.selected;
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
    int index = [self getSelfIndexFromUserList:userList];
    if (index >= 0) {
        for (int i = 1; i <=userList.count; i ++) {
            
            DiceAvatarView* avatar = (DiceAvatarView*)[self.view viewWithTag:AVATAR_TAG_OFFSET+i];
            UILabel* nameLabel = (UILabel*)[self.view viewWithTag:(NICKNAME_TAG_OFFSET+i)];
            PPDebug(@"<test> tag = %d",(NICKNAME_TAG_OFFSET+i));
            int userIndex = (index+i-1)%userList.count;
            PBGameUser* user = [userList objectAtIndex:userIndex];
            [avatar setUrlString:user.avatar 
                          userId:user.userId 
                          gender:user.gender 
                           level:user.userLevel 
                      drunkPoint:0 
                          wealth:0];
            PPDebug(@"<test>update user <%@>", user.nickName);
            if (nameLabel) {
                [nameLabel setText:user.nickName];
            }
        }
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
         PPDebug(@"<HomeController> NOTIFICATION_JOIN_GAME_RESPONSE");         
     }];
    
    [[NSNotificationCenter defaultCenter] 
     addObserverForName:NOTIFICATION_ROOM
     object:nil     
     queue:[NSOperationQueue mainQueue]     
     usingBlock:^(NSNotification *notification) {                       
         PPDebug(@"<HomeController> NOTIFICATION_ROOM");   
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

@end
