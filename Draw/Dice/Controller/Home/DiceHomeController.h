//
//  DiceHomeController.h
//  Draw
//
//  Created by  on 12-8-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PPViewController.h"
#import "BoardService.h"

@class MenuPanel;
@class BottomMenuPanel;

@interface DiceHomeController : PPViewController<BoardServiceDelegate>
{
    MenuPanel *_menuPanel;
    BottomMenuPanel *_bottomMenuPanel;

}

@property (retain, nonatomic) MenuPanel *menuPanel;
@property (retain, nonatomic) BottomMenuPanel *bottomMenuPanel;

@end
