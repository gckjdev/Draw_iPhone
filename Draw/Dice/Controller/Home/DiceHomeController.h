//
//  DiceHomeController.h
//  Draw
//
//  Created by  on 12-8-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PPViewController.h"
#import "CommonDialog.h"
#import "DiceGameService.h"
#import "SuperHomeController.h"
#import "HomeHeaderPanel.h"

@interface DiceHomeController : SuperHomeController<CommonDialogDelegate, UIGestureRecognizerDelegate, HomeHeaderPanelDelegate>
{
//    MenuPanel *_menuPanel;
//    BottomMenuPanel *_bottomMenuPanel;
    NSTimer* _rollAwardDiceTimer;
    BOOL _isTryJoinGame;
    int _awardDicePoint;
    UITapGestureRecognizer *_tapGestureRecognizer;
}

//@property (retain, nonatomic) MenuPanel *menuPanel;
//@property (retain, nonatomic) BottomMenuPanel *bottomMenuPanel;

- (void)connectServer:(DiceGameRuleType)ruleType;

@end
