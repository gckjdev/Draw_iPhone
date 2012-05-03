//
//  SuperDrawViewController.h
//  Draw
//
//  Created by  on 12-5-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPViewController.h"
#import "DrawGameService.h"
#import "ShareImageManager.h"

#define GAME_TIME 60
@class AvatarView;
@interface SuperDrawViewController : PPViewController<DrawGameServiceDelegate>
{
    ShareImageManager *shareImageManager;
    NSTimer *gameTimer;
    NSInteger retainCount;
    
    DrawGameService *drawGameService;
    NSMutableArray *avatarArray;

}

@property (retain, nonatomic) IBOutlet UIButton *turnNumberButton;
@property (retain, nonatomic) IBOutlet UIButton *popupButton;
@property (retain, nonatomic) IBOutlet UIButton *clockButton;

- (void)resetTimer;
- (void)updateClockButton;
- (void)startTimer;
- (void)handleTimer:(NSTimer *)theTimer;// this method needs over ride

- (id)init;

//avatar views
- (void)adjustPlayerAvatars:(NSString *)quitUserId;
- (void)cleanAvatars;
- (void)updatePlayerAvatars;
- (AvatarView *)avatarViewForUserId:(NSString *)userId;
- (NSInteger)userCount;

//pop up user message

- (void)popGuessMessage:(NSString *)message userId:(NSString *)userId onLeftTop:(BOOL)onLeftTop;
- (void)popGuessMessage:(NSString *)message userId:(NSString *)userId;
- (void)popUpRunAwayMessage:(NSString *)userId;
- (void)addScore:(NSInteger)score toUser:(NSString *)userId;

@end
