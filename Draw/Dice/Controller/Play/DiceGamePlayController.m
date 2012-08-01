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
#import "DiceGameService.h"
#import "DiceGameSession.h"

@interface DiceGamePlayController ()

@end

@implementation DiceGamePlayController

- (void)dealloc {
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

}

- (void)viewDidUnload
{
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
