//
//  SuperDrawViewController.m
//  Draw
//
//  Created by  on 12-5-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SuperGameViewController.h"
#import "PPDebug.h"
#import "StableView.h"
#import "GameSession.h"
#import "GameSessionUser.h"
#import "DeviceDetection.h"
#import "AnimationManager.h"
#import "WordManager.h"
#import "DrawGameService.h"
#import "ChatMessageView.h"
#import "ExpressionManager.h"
#import "GameMessage.pb.h"
#import "DrawGameAnimationManager.h"
#import "LevelService.h"
#import "AccountManager.h"
#import "CommonMessageCenter.h"
#import "ConfigManager.h"
#import "AccountService.h"
#import "UseItemScene.h"
#import "UserGameItemManager.h"

#define ITEM_FRAME  ([DeviceDetection isIPAD]?CGRectMake(0, 0, 122, 122):CGRectMake(0, 0, 61, 61))

@interface SuperGameViewController ()

- (void)showChatMessageViewOnUser:(NSString*)userId title:(NSString*)title message:(NSString*)message;
- (void)showChatMessageViewOnUser:(NSString*)userId title:(NSString*)title expression:(UIImage*)expression;


@end

@implementation SuperGameViewController

@synthesize turnNumberButton;
@synthesize popupButton;
@synthesize clockButton;
@synthesize privateChatController = _privateChatController;
@synthesize groupChatController = _groupChatController;
@synthesize word = _word;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)dealloc
{
    
    shareImageManager = nil;
    drawGameService = nil;
    gameTimer = nil;
    
    PPRelease(_word);
    PPRelease(clockButton);
    PPRelease(popupButton);
    PPRelease(turnNumberButton);
    PPRelease(avatarArray);
    PPRelease(_privateChatController);
    PPRelease(_groupChatController);
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        drawGameService = [DrawGameService defaultService];    
        avatarArray = [[NSMutableArray alloc] init];
        shareImageManager = [ShareImageManager defaultManager];
        _gameCompleted = NO;
        _gameCanCompleted = NO;
        [drawGameService registerObserver:self];    
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    [self initRoundNumber];
    [self initAvatars];
    [self initPopButton];
    [UIApplication sharedApplication].idleTimerDisabled=YES;
}

- (void)viewDidUnload
{
    [drawGameService unregisterObserver:self];
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _gameCanCompleted = YES;
}

- (void)viewDidDisappear:(BOOL)animated
{
//    [[SpeechService defaultService] cancel];
    [_privateChatController dismiss:NO];
    [_groupChatController dismiss:NO];
    [drawGameService unregisterObserver:self];
    [super viewDidDisappear:animated];
}

#pragma mark - Timer 

- (void)resetTimer
{
    if (gameTimer && [gameTimer isValid]) {
        [gameTimer invalidate];
    }
    gameTimer = nil;
    retainCount = GAME_TIME;
}
- (void)updateClockButton
{
    NSString *clockString = [NSString stringWithFormat:@"%d",retainCount];
    [self.clockButton setTitle:clockString forState:UIControlStateNormal];
}

- (void)handleTimer:(NSTimer *)theTimer
{
    PPDebug(@"<SuperGameViewController> handle timer");
}
- (void)startTimer
{
    [self resetTimer];
    [self updateClockButton];
    gameTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handleTimer:) userInfo:nil repeats:YES];
}

#pragma mark - Avatar views

#define AVATAR_VIEW_SPACE ([DeviceDetection isIPAD] ? 36.0 * 2 : 36.0)
- (void)adjustPlayerAvatars:(NSString *)quitUserId
{
    BOOL needMove = NO;
    AvatarView *removeAvatar = nil;
    
    for (AvatarView *aView in avatarArray) {
        if ([aView.userId isEqualToString:quitUserId]) {
            needMove = YES;
            removeAvatar = aView;
        }else if (needMove) {
            aView.center = CGPointMake(aView.center.x - AVATAR_VIEW_SPACE,
                                       aView.center.y);                
        }
    }
    if (removeAvatar) {
        [removeAvatar removeFromSuperview];
        [avatarArray removeObject:removeAvatar];
    }
}

- (void)cleanAvatars
{
    //remove all the old avatars
    for (AvatarView *view in avatarArray) {
        [view removeFromSuperview];
    }
    [avatarArray removeAllObjects];
    
}
- (void)updatePlayerAvatars
{
    [self cleanAvatars];
    GameSession *session = [[DrawGameService defaultService] session];
    int i = 0;
    for (GameSessionUser *user in session.userList) {
        AvatarType type = Guesser;
        if([user.userId isEqualToString:session.drawingUserId])
        {
            type = Drawer;
        }
        BOOL gender = user.gender;
        
        //need to improve later, me u
        NSString* avatarUrl;
        if ([[UserManager defaultManager] isMe:user.userId]) {
            avatarUrl = [[UserManager defaultManager] avatarURL];
        } else {
            avatarUrl = [user userAvatar];
        }

        AvatarView *aView = [[AvatarView alloc] initWithUrlString:avatarUrl type:type gender:gender level:user.level];
        [aView setUserId:user.userId];
        aView.delegate = self;
        
        //set center
        if ([DeviceDetection isIPAD]) {
            aView.center = CGPointMake(70 * 2 + AVATAR_VIEW_SPACE * i, 50);
        }else{
            aView.center = CGPointMake(70 + AVATAR_VIEW_SPACE * i, 20);
        }
        
        [self.view addSubview:aView];
        [avatarArray addObject:aView];
        [aView release];
        ++ i;                                  
    }
}


- (AvatarView *)avatarViewForUserId:(NSString *)userId
{
    for (AvatarView *view in avatarArray) {
        if ([view.userId isEqualToString:userId]) {
            return view;
        }
    }
    return nil;
}


- (NSInteger)userCount
{
    GameSession *session = [[DrawGameService defaultService] session];
    return [session.userList count];
}


#pragma mark - pop up message


- (void)popGuessMessage:(NSString *)message userId:(NSString *)userId onLeftTop:(BOOL)onLeftTop
{
    AvatarView *player = [self avatarViewForUserId:userId];

    if (player == nil) {
        return;
    }
    CGFloat x = player.frame.origin.x;
    CGFloat y = player.frame.origin.y + player.frame.size.height;
    if (onLeftTop) {
        if ([DeviceDetection isIPAD]) {
            x = 10 * 2;//player.frame.origin.x;
            y = 55 * 2;//player.frame.origin.y + player.frame.size.height;            
        }else{
            x = 10;//player.frame.origin.x;
            y = 50;//player.frame.origin.y + player.frame.size.height;                        
        }
    }
    CGSize size = [message sizeWithFont:self.popupButton.titleLabel.font];
    
    if ([DeviceDetection isIPAD]) {
        [self.popupButton setFrame:CGRectMake(x, y, size.width + 20 * 2, size.height + 15 * 2)];
    }else{
        [self.popupButton setFrame:CGRectMake(x, y, size.width + 20, size.height + 15)];
    }
    [self.popupButton setTitle:message forState:UIControlStateNormal];
    [self.popupButton setHidden:NO];
    CAAnimation *animation = [AnimationManager disappearAnimationWithDuration:5];
    [self.popupButton.layer addAnimation:animation forKey:@"DismissAnimation"];
    
}

- (void)popGuessMessage:(NSString *)message userId:(NSString *)userId
{
    [self popGuessMessage:message userId:userId onLeftTop:NO];
}

- (void)popUpRunAwayMessage:(NSString *)userId
{
    NSString *nickName = [[drawGameService session] getNickNameByUserId:userId];
    NSString *message = [NSString stringWithFormat:NSLS(@"kRunAway"),nickName];
    [self popGuessMessage:message userId:userId onLeftTop:YES];
}


- (void)addScore:(NSInteger)score toUser:(NSString *)userId
{
    AvatarView *avatarView = [self avatarViewForUserId:userId];
    [avatarView setScore:score];
}

- (void)initRoundNumber
{
    [self.turnNumberButton setTitle:[NSString stringWithFormat:@"%d",drawGameService.roundNumber] forState:UIControlStateNormal];
}

- (void)initPopButton
{
    [self.popupButton setBackgroundImage:[shareImageManager popupImage] 
                                forState:UIControlStateNormal];
    self.popupButton.userInteractionEnabled = NO;
    [self.view bringSubviewToFront:self.popupButton];
}
- (void)initAvatars
{
    [self updatePlayerAvatars];
}

- (void)cleanData
{
    [self resetTimer];
    drawGameService.showDelegate = nil;
    drawGameService.drawDelegate = nil;
    [drawGameService unregisterObserver:self];
//    [[SpeechService defaultService] cancel];
}

- (void)didReceiveGuessWord:(NSString*)wordText 
                guessUserId:(NSString*)guessUserId 
               guessCorrect:(BOOL)guessCorrect
                  gainCoins:(int)gainCoins
{
    if (!guessCorrect) {
        if ([LocaleUtils isTraditionalChinese]) {
            wordText = [WordManager changeToTraditionalChinese:wordText];                
        }
        [self popGuessMessage:wordText userId:guessUserId]; 
    }else{
        [self popGuessMessage:NSLS(@"kGuessCorrect") userId:guessUserId];
        [self addScore:gainCoins toUser:guessUserId];
    }
}

- (void)didGameReceiveChat:(GameMessage *)message
{
    NSString* content = [[message notification] chatContent];
    GameChatType chatType = [[message notification] chatType];
    
    //add by haodong
    if ([content hasPrefix:NORMAL_CHAT]) {
//        NSString *readText = [content stringByReplacingOccurrencesOfString:NORMAL_CHAT withString:NSLS(@"")];
//        BOOL gender = [[[[DrawGameService defaultService] session] getUserByUserId:[message userId]] gender];
//        [[SpeechService defaultService] play:readText gender:gender];
    }
    
    
    if (chatType == GameChatTypeChatGroup) {
        if ([content hasPrefix:EXPRESSION_CHAT]) {
            NSString *key = [content stringByReplacingOccurrencesOfString:EXPRESSION_CHAT withString:NSLS(@"")];
            UIImage *image = [[ExpressionManager defaultManager] pngExpressionForKey:key];  
            [self showChatMessageViewOnUser:[message userId] title:NSLS(@"kSayToAll") expression:image];
        }else if ([content hasPrefix:NORMAL_CHAT]) {
            NSString *msg = [content stringByReplacingOccurrencesOfString:NORMAL_CHAT withString:NSLS(@"")];
            [self showChatMessageViewOnUser:[message userId] title:NSLS(@"kSayToAll") message:msg];
        }
    }else {
        if ([content hasPrefix:EXPRESSION_CHAT]) {
            NSString *key = [content stringByReplacingOccurrencesOfString:EXPRESSION_CHAT withString:NSLS(@"")];
            UIImage *image = [[ExpressionManager defaultManager] pngExpressionForKey:key]; 
            [self showChatMessageViewOnUser:[message userId] title:NSLS(@"kSayToYou") expression:image];
        }else if ([content hasPrefix:NORMAL_CHAT]) {
            NSString *msg = [content stringByReplacingOccurrencesOfString:NORMAL_CHAT withString:NSLS(@"")];
            [self showChatMessageViewOnUser:[message userId] title:NSLS(@"kSayToYou") message:msg];
        }
    }
}


- (void)didClickOnAvatar:(NSString*)userId
{
    if (userId == nil || [[UserManager defaultManager] isMe:userId]) {
        return;
    }
    
    if (_privateChatController == nil) {
        _privateChatController = [[ChatController alloc] initWithChatType:GameChatTypeChatPrivate];
        _privateChatController.chatControllerDelegate = self;
    }
    [_privateChatController showInView:self.view messagesType:GameMessages selectedUserId:userId needAnimation:YES];
}

- (void)showGroupChatView
{
    if (_groupChatController == nil) {
        _groupChatController = [[ChatController alloc] initWithChatType:GameChatTypeChatGroup];
        _groupChatController.chatControllerDelegate = self;
    }
    [_groupChatController showInView:self.view messagesType:GameMessages selectedUserId:nil needAnimation:YES];
}

- (void)didSelectMessage:(NSString*)message toUser:(NSString *)userNickName
{
    //add by haodong
//    BOOL gender = [[UserManager defaultManager] isUserMale];
//    [[SpeechService defaultService] play:message gender:gender];
    
    NSString *title = [NSString stringWithFormat:NSLS(@"kSayToXXX"), userNickName];
    [self showChatMessageViewOnUser:[[DrawGameService defaultService] userId] title:title message:message];
}

- (void)didSelectExpression:(UIImage*)expression toUser:(NSString *)userNickName
{
    NSString *title = [NSString stringWithFormat:NSLS(@"kSayToXXX"), userNickName];
    [self showChatMessageViewOnUser:[[DrawGameService defaultService] userId] title:title expression:expression];
}

- (void)showChatMessageViewOnUser:(NSString*)userId title:(NSString*)title message:(NSString*)message
{
    AvatarView *player = [self avatarViewForUserId:userId];
    CGPoint origin = CGPointMake(player.frame.origin.x, player.frame.origin.y+player.frame.size.height);
    [ChatMessageView showMessage:message title:title origin:origin superView:self.view];
}

- (void)showChatMessageViewOnUser:(NSString*)userId title:(NSString*)title expression:(UIImage*)expression
{
    AvatarView *player = [self avatarViewForUserId:userId];
    CGPoint origin = CGPointMake(player.frame.origin.x, player.frame.origin.y+player.frame.size.height);
    [ChatMessageView showExpression:expression title:title origin:origin superView:self.view];
}

- (void)showAnimationThrowTool:(ToolView*)toolView isBuy:(BOOL)isBuy
{
    UIImageView* throwItem = [[[UIImageView alloc] initWithFrame:ITEM_FRAME] autorelease];
    throwItem.center = self.view.center;
    [self.view addSubview:throwItem];
    [throwItem setImage:[toolView backgroundImageForState:UIControlStateNormal]];
    if (toolView.itemType == ItemTypeTomato) {
        [DrawGameAnimationManager showThrowTomato:throwItem animInController:self rolling:NO itemEnough:!isBuy shouldShowTips:[UseItemScene shouldItemMakeEffectInScene:YES] completion:^(BOOL finished) {
            
        }];
    }
    if (toolView.itemType == ItemTypeFlower) {
        [DrawGameAnimationManager showThrowFlower:throwItem animInController:self rolling:NO itemEnough:!isBuy shouldShowTips:[UseItemScene shouldItemMakeEffectInScene:YES] completion:^(BOOL finished) {
            
        }];
    }
}

- (void)recieveFlower
{
    UIImageView* item = [[[UIImageView alloc] initWithFrame:ITEM_FRAME] autorelease];
    [self.view addSubview:item];
    [item setImage:[ShareImageManager defaultManager].flower];
    [DrawGameAnimationManager showReceiveFlower:item animationInController:self];
    
}
- (void)recieveTomato
{
    // show animation
    UIImageView* item = [[[UIImageView alloc] initWithFrame:ITEM_FRAME] autorelease];
    [self.view addSubview:item];
    [item.layer removeAllAnimations];
    [item setImage:[ShareImageManager defaultManager].tomato];
    [DrawGameAnimationManager showReceiveTomato:item animaitonInController:self];    
}

@end
