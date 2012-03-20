//
//  RoomController.h
//  Draw
//
//  Created by  on 12-3-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPViewController.h"
#import "DrawGameService.h"

@interface RoomController : PPViewController<DrawGameServiceDelegate>
{
    int _currentTimeCounter;
    BOOL _hasClickStartGame;
}

@property (retain, nonatomic) IBOutlet UIButton *prolongButton;
@property (retain, nonatomic) IBOutlet UILabel *roomNameLabel;
@property (retain, nonatomic) IBOutlet UIButton *startGameButton;
@property (retain, nonatomic) NSTimer *startTimer;

- (IBAction)clickStart:(id)sender;
- (IBAction)clickChangeRoom:(id)sender;
- (IBAction)clickProlongStart:(id)sender;

// use this method when first enter room
+ (void)firstEnterRoom:(UIViewController*)superController;

// use this method for returning from draw/guess to room
+ (void)returnRoom:(UIViewController*)superController;

@end
