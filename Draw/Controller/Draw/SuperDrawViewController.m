//
//  SuperDrawViewController.m
//  Draw
//
//  Created by  on 12-5-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SuperDrawViewController.h"
#import "PPDebug.h"
#import "StableView.h"
#import "GameSession.h"
#import "GameSessionUser.h"
#import "DeviceDetection.h"
#import "AnimationManager.h"
#import "WordManager.h"

@implementation SuperDrawViewController
@synthesize turnNumberButton;
@synthesize popupButton;
@synthesize clockButton;


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
    [clockButton release];
    [popupButton release];
    [turnNumberButton release];
    [avatarArray release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        drawGameService = [DrawGameService defaultService];    
        avatarArray = [[NSMutableArray alloc] init];
        shareImageManager = [ShareImageManager defaultManager];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
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
        if ([session isMe:user.userId]) {
            gender = [[UserManager defaultManager] isUserMale];
        }
        AvatarView *aView = [[AvatarView alloc] initWithUrlString:[user userAvatar] type:type gender:gender];
        [aView setUserId:user.userId];
        
        //set center
        if ([DeviceDetection isIPAD]) {
            aView.center = CGPointMake(70 * 2 + AVATAR_VIEW_SPACE * i, 22 * 2.2);            
        }else{
            aView.center = CGPointMake(70 + AVATAR_VIEW_SPACE * i, 22);
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
    CAAnimation *animation = [AnimationManager missingAnimationWithDuration:5];
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


- (void)didReceiveGuessWord:(NSString*)wordText 
                guessUserId:(NSString*)guessUserId 
               guessCorrect:(BOOL)guessCorrect
                  gainCoins:(int)gainCoins
{
    
    if (![drawGameService.userId isEqualToString:guessUserId]) {
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
}
@end
