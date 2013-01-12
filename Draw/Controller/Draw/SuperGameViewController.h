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
#import "ChatController.h"

#define GAME_TIME 60
@class AvatarView;
@class Word;
@interface SuperGameViewController : PPViewController<DrawGameServiceDelegate, ChatControllerDelegate, AvatarViewDelegate>
{
    ShareImageManager *shareImageManager;
    NSTimer *gameTimer;
    NSInteger retainCount;
    Word *_word;
    LanguageType languageType;
    DrawGameService *drawGameService;
    NSMutableArray *avatarArray;
    BOOL _gameCompleted;
    BOOL _gameCanCompleted;
}

@property (retain, nonatomic) IBOutlet UIButton *turnNumberButton;
@property (retain, nonatomic) IBOutlet UIButton *popupButton;
@property (retain, nonatomic) IBOutlet UIButton *clockButton;
@property (retain, nonatomic) ChatController *privateChatController;
@property (retain, nonatomic) ChatController *groupChatController;
@property (retain, nonatomic) Word *word;

- (void)resetTimer;
- (void)updateClockButton;
- (void)startTimer;
- (void)handleTimer:(NSTimer *)theTimer;// this method needs over ride

- (id)init;
- (void)initRoundNumber;
//- (void)initClock;
- (void)initAvatars;
- (void)initPopButton;
- (void)cleanData;

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

- (void)showGroupChatView;
- (void)showAnimationThrowTool:(ToolView*)toolView isItemEnough:(BOOL)itemEnough;
- (void)recieveFlower;
- (void)recieveTomato;

@end
