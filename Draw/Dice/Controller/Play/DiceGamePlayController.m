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
    
    DiceSelectedView *view = [[[DiceSelectedView alloc] initWithFrame:diceCountSelectedHolderView.bounds] autorelease];
    [view setStart:1 end:9];
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
    Dice_Builder *diceBuilder = [[[Dice_Builder alloc] init] autorelease];
    [diceBuilder setDice:1];
    [diceBuilder setDiceId:1];
    Dice *dice = [diceBuilder build];
    
    
    [DicePopupView popupCallDiceViewWithDice:dice count:2 atView:(UIView*)sender inView:self.view animated:YES];
    
}


- (IBAction)clickRunAwayButton:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
    NSArray* array = [[DiceGameService defaultService].session userList];
    for (PBGameUser* user in array) {
        PPDebug(@"%@",user.nickName);
    }
}

@end
