//
//  ZJHGameController.m
//  Draw
//
//  Created by 王 小涛 on 12-10-24.
//
//

#import "ZJHGameController.h"
#import "ZJHGameService.h"
#import "LevelService.h"
#import "UserManager.h"
#import "AudioManager.h"
//#import "AccountService.h"
#import "ZJHImageManager.h"
#import "ZJHAvatarView.h"
#import "CommonGameSession.h"
#import "ZJHPokerView.h"
#import "ZJHUserPlayInfo.h"
#import "GameMessage.pb.h"
#import "BetTable.h"
#import "ConfigManager.h"
#import "PopupViewManager.h"
#import "ZJHMyAvatarView.h"
#import "MoneyTree.h"
#import "AnimationManager.h"
#import "LevelService.h"
#import "ZJHSoundManager.h"

#define AVATAR_VIEW_TAG_OFFSET   4000
#define AVATAR_PLACE_VIEW_OFFSET    8000
#define POKERS_VIEW_TAG_OFFSET   2000
#define USER_TOTAL_BET_BG_IMAGE_VIEW_OFFSET 3000
#define USER_TOTAL_BET_LABEL 3200

#define CARDS_COUNT 3

#define COMPARE_BUTTON_TAG_OFFSET   5000

#define TITLE_COLOR_WHEN_DISABLE [UIColor colorWithRed:6.0/255.0 green:41.0/255.0 blue:56.0/255.0 alpha:1]

#define TITLE_COLOR_WHEN_ENABLE [UIColor whiteColor]

@interface ZJHGameController ()
{
    ZJHGameService  *_gameService;
    LevelService    *_levelService;
    UserManager     *_userManager;
    AudioManager    *_audioManager;
//    AccountService  *_accountService;
    ZJHImageManager *_imageManager;
    PopupViewManager *_popupViewManager;
    ZJHSoundManager  *_soundManager;
}
@property (assign, nonatomic) BOOL  isComparing;

@end

@implementation ZJHGameController
@synthesize betTable = _betTable;
@synthesize dealerView = _dealerView;
@synthesize raiseBetButton = _raiseBetButton;
@synthesize autoBetButton = _autoBetButton;
@synthesize compareCardButton = _compareCardButton;
@synthesize checkCardButton = _checkCardButton;
@synthesize cardTypeButton = _cardTypeButton;
@synthesize foldCardButton = _foldCardButton;
@synthesize totalBetLabel = _totalBetLabel;
@synthesize singleBetLabel = _singleBetLabel;
@synthesize betButton = _betButton;
#pragma mark - life cycle

- (void)dealloc
{
    [_betTable release];
    [_dealerView release];
    [_betButton release];
    [_raiseBetButton release];
    [_autoBetButton release];
    [_compareCardButton release];
    [_checkCardButton release];
    [_cardTypeButton release];
    [_foldCardButton release];
    [_totalBetLabel release];
    [_singleBetLabel release];
    [_moneyTree release];
    [_vsImageView release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        _gameService = [ZJHGameService defaultService];
        _userManager = [UserManager defaultManager];
        _imageManager = [ZJHImageManager defaultManager];
        _levelService = [LevelService defaultService];
//        _accountService = [AccountService defaultService];
        _audioManager = [AudioManager defaultManager];
        _popupViewManager = [PopupViewManager defaultManager];
        _soundManager = [ZJHSoundManager defaultManager];
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initAllAvatars
{
    for (int i = UserPositionCenter; i < UserPositionMax; i ++) {
        UIView* placeView = [self.view viewWithTag:(i + AVATAR_PLACE_VIEW_OFFSET)];
        if (i == UserPositionCenter) {
            ZJHMyAvatarView* myAvatar = [ZJHMyAvatarView createZJHMyAvatarView];
            [myAvatar setFrame:placeView.frame];
            [self.view addSubview:myAvatar];
            myAvatar.tag = AVATAR_VIEW_TAG_OFFSET + i;
            [myAvatar update];
            continue;
        }
        ZJHAvatarView* anAvatar = [ZJHAvatarView createZJHAvatarView];
        [anAvatar setFrame:placeView.frame];
        [self.view addSubview:anAvatar];
        anAvatar.tag = AVATAR_VIEW_TAG_OFFSET + i;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.

    [self initAllAvatars];
    [self updateAllUsersAvatar];
    
    [self updateZJHButtons];
    
    // hidden views below
    [self updateTotalBetAndSingleBet];

    [self hideAllUserTotalBet];
    
    [self updateView];
    
    self.dealerView.delegate = self;
    
    [self.moneyTree startGrow];
    
    [_audioManager setBackGroundMusicWithName:[_soundManager gameBGM]];

}

- (void)updateView
{
    if ([_gameService gameState] == nil) {
        return;
    }
    [self updateAllUsersPokers];
    [self updateAllUserTotalBet];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self registerZJHGameNotifications];
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self unregisterAllNotifications];
    [super viewDidDisappear:animated];
}


- (void)didReceiveMemoryWarning
{
    // dealloc resource here when memory is not enough
    [self unregisterAllNotifications];
    [super didReceiveMemoryWarning];
}

#pragma mark - Register notifications.

- (void)registerZJHGameNotifications
{
    [self registerNotificationWithName:NOTIFICATION_ROOM
                            usingBlock:^(NSNotification *notification) {
                                [self roomChanged];
                            }];
    
    [self registerNotificationWithName:NOTIFICATION_GAME_START_NOTIFICATION_REQUEST
                            usingBlock:^(NSNotification *notification) {
                                [self gameStart];
                            }];
    
    [self registerNotificationWithName:NOTIFICATION_NEXT_PLAYER_START
                            usingBlock:^(NSNotification *notification) {
                                [self nextPlayerStart];
                            }];
    
    [self registerNotificationWithName:NOTIFICATION_BET_REQUEST
                            usingBlock:^(NSNotification *notification) {
                                [self someoneBet:[[CommonGameNetworkService userInfoToMessage:notification.userInfo] userId]];
                            }];
    
    [self registerNotificationWithName:NOTIFICATION_BET_RESPONSE
                            usingBlock:^(NSNotification *notification) {
                                [self betSuccess];
                            }];
    
    [self registerNotificationWithName:NOTIFICATION_CHECK_CARD_REQUEST
                            usingBlock:^(NSNotification *notification) {
                                [self someoneCheckCard:[[CommonGameNetworkService userInfoToMessage:notification.userInfo] userId]];
                            }];
    
    [self registerNotificationWithName:NOTIFICATION_CHECK_CARD_RESPONSE
                            usingBlock:^(NSNotification *notification) {
                                [self checkCardSuccess];
                            }];
    
    [self registerNotificationWithName:NOTIFICATION_FOLD_CARD_REQUEST
                                   usingBlock:^(NSNotification *notification) {
                                       [self someoneFoldCard:[[CommonGameNetworkService userInfoToMessage:notification.userInfo] userId]];
                                   }];
    
    [self registerNotificationWithName:NOTIFICATION_FOLD_CARD_RESPONSE
                                   usingBlock:^(NSNotification *notification) {
                                       [self foldCardSuccess];
                                   }];
    
    [self registerNotificationWithName:NOTIFICATION_SHOW_CARD_REQUEST
                                   usingBlock:^(NSNotification *notification) {
                                       NSString *userId = [[CommonGameNetworkService userInfoToMessage:notification.userInfo] userId];
                                       NSArray *cardIds = [[[CommonGameNetworkService userInfoToMessage:notification.userInfo] showCardRequest] cardIdsList];
                                       [self someoneShowCard:userId
                                                     cardIds:cardIds];
                                   }];
    
    [self registerNotificationWithName:NOTIFICATION_SHOW_CARD_RESPONSE
                                   usingBlock:^(NSNotification *notification) {
                                       [self showCardSuccess];
                                   }];
    
    [self registerNotificationWithName:NOTIFICATION_COMPARE_CARD_REQUEST
                                   usingBlock:^(NSNotification *notification) {

                                   }];
    
    [self registerNotificationWithName:NOTIFICATION_COMPARE_CARD_RESPONSE
                                   usingBlock:^(NSNotification *notification) {
                                       NSArray* userResultList = [[[CommonGameNetworkService userInfoToMessage:notification.userInfo] compareCardResponse] userResultList];
                                       NSString *userId = [[CommonGameNetworkService userInfoToMessage:notification.userInfo] userId];
                                       [self showCompareCardResult:userResultList initiator:userId];
                                   }];
    
    [self registerNotificationWithName:NOTIFICATION_GAME_OVER_NOTIFICATION_REQUEST
                                   usingBlock:^(NSNotification *notification) {
                                       [self gameOver];
                                   }];
}

#pragma mark - player action

- (void)bet:(BOOL)autoBet
{
    [[self getMyAvatarView] stopReciprocal];
    [_gameService bet:autoBet];
}

- (IBAction)clickBetButton:(id)sender {
    [self bet:NO];
}

- (IBAction)clickRaiseBetButton:(id)sender
{
    [_popupViewManager popupChipsSelectViewAtView:sender
                                           inView:self.view
                                        aboveView:nil
                                         delegate:self];
}

- (IBAction)clickAutoBetButton:(id)sender
{
    self.autoBetButton.selected = !self.autoBetButton.selected;
    [_gameService setAutoBet:self.autoBetButton.selected];
    
    if ([_gameService isMeAutoBet] == YES && [_gameService isMyTurn]) {
        [self bet:YES];
    }
}

- (IBAction)clickCompareCardButton:(id)sender
{
    self.isComparing = YES;
    [self disableZJHButtons];
}

- (IBAction)clickCheckCardButton:(id)sender
{
    [[self getMyPokersView] faceUpCards:ZJHPokerXMotionTypeNone animation:YES];
    [self showMyCardTypeString];
    [_gameService checkCard];
}

- (IBAction)clickFoldCardButton:(id)sender
{
    [[self getMyAvatarView] stopReciprocal];
    [[self getMyPokersView] foldCards:YES];
    [_gameService foldCard];
    [self setIsComparing:NO];
}

- (IBAction)clickQuitButton:(id)sender
{
    [_gameService quitGame];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - player action response

- (void)betSuccess
{
    ZJHUserPlayInfo *userPlayInfo = [_gameService userPlayInfo:_userManager.userId];
    BOOL gender = [_userManager.gender isEqualToString:@"m"];
    NSString* soundName;
    if (userPlayInfo.lastAction == PBZJHUserActionRaiseBet) {
        soundName = [_soundManager raiseBetHumanSound:gender];
    } else {
        soundName = [_soundManager betHumanSound:gender];
    }
    [_audioManager playSoundByName:soundName];
    [_audioManager playSoundByName:[_soundManager betSoundEffect]];
    
    [self updateZJHButtons];
    [self dismissAllPopupView];

    [self.betTable someBetFrom:[self getPositionByUserId:_userManager.userId]
                     chipValue:_gameService.gameState.singleBet
                         count:[_gameService betCountOfUser:_userManager.userId]];
    
    [self updateTotalBetAndSingleBet];
    [self updateUserTotalBet:_userManager.userId];
    [self updateMyAvatar];
}

- (void)checkCardSuccess
{
    BOOL gender = [_userManager.gender isEqualToString:@"m"];
    [_audioManager playSoundByName:[_soundManager checkCardHumanSound:gender]];
    [_audioManager playSoundByName:[_soundManager checkCardSoundEffect]];
    
    [self updateZJHButtons];
}

- (void)foldCardSuccess
{
    [_audioManager playSoundByName:_soundManager.foldCardSoundEffect];
    [_audioManager playSoundByName:[_soundManager foldCardHumanSound:[@"m" isEqualToString:_userManager.gender]]];
    [self updateZJHButtons];
    [self dismissAllPopupView];
}

- (void)showCardSuccess
{
    [self updateZJHButtons];
}


#pragma mark - service notification request

- (void)roomChanged
{
    [self updateAllUsersAvatar];
    [self updateWaittingForNextTurnNotLabel];
    
    for (NSString *userId in [_gameService.session.deletedUserList allKeys]) {
        [self hideTotalBetOfPosition:[self getPositionByUserId:userId]];
        [[self getPokersViewByUserId:userId] clear];
    }
}


- (CGPoint)calRelativePointByPokerView:(ZJHPokerView*)view
{
    float x = view.center.x - self.dealerView.frame.origin.x;
    float y = view.center.y - self.dealerView.frame.origin.y;
    return CGPointMake(x, y);
}

- (NSArray*)dealPointsArray
{
    NSMutableArray* array = [[[NSMutableArray alloc] initWithCapacity:UserPositionMax] autorelease];
    for (PBGameUser* user in _gameService.session.userList) {
        ZJHPokerView* view = [self getPokersViewByUserId:user.userId];
        if (view) {
            CGPoint point = [self calRelativePointByPokerView:view];
            [array addObject:[DealPoint pointWithCGPoint:point]];
        }
    }
    return array;
}

- (void)gameStart
{
//    PPDebug(@"<ZJHGameController> game start!");
    [self.dealerView dealWithPositionArray:[self dealPointsArray]
                                     times:CARDS_COUNT];
    [self updateTotalBetAndSingleBet];
    [self updateAllUserTotalBet];

    [self updateMyAvatar];
    [self allBet];
}

- (void)gameOver
{
    [self updateZJHButtons];
    [self clearAllAvatarReciprocals];

    [self someoneWon:[_gameService winner]];

    [self faceupUserCards];
    [self performSelector:@selector(resetGame) withObject:nil afterDelay:3.0];
}

- (void)resetGame
{
    self.autoBetButton.selected = NO;
    [self hideMyCardTypeString];
    [self clearAllUserPokers];
    [self hideAllUserTotalBet];
}

- (void)faceupUserCards
{
    for (NSString *userId in [_gameService.gameState.usersInfo allKeys]) {
        [[self getPokersViewByUserId:userId] faceUpCards:[self getPokerXMotionTypeByPosition:[self getPositionByUserId:userId]] animation:YES];
    }
}

- (void)nextPlayerStart
{
    PPDebug(@"################# [controller: %@] next player: %@ ##################", [self description],_gameService.session.currentPlayUserId);
    
    [self clearAllAvatarReciprocals];
    [[self getAvatarViewByPosition:[self getPositionByUserId:_gameService.session.currentPlayUserId]] startReciprocal:[ConfigManager getZJHTimeInterval]];

    [self updateZJHButtons];
    
    if ([_gameService isMyTurn] && [_gameService isMeAutoBet]) {
        if ([_gameService isMyBalanceEnough]) {
            [self bet:YES];
            return;
        }else{
            [_gameService setAutoBet:NO];
        }
    }
}

- (void)someoneBet:(NSString*)userId
{
    ZJHUserPlayInfo *userPlayInfo = [_gameService userPlayInfo:userId];
    BOOL gender = [_gameService.session getUserByUserId:userId].gender;
    NSString* soundName;
    if (userPlayInfo.lastAction == PBZJHUserActionRaiseBet) {
        soundName = [_soundManager raiseBetHumanSound:gender];
    } else {
        soundName = [_soundManager betHumanSound:gender];
    }
    [_audioManager playSoundByName:soundName];
    [_audioManager playSoundByName:[_soundManager betSoundEffect]];
    
    [[self getAvatarViewByUserId:userId] stopReciprocal];
    [self.betTable someBetFrom:[self getPositionByUserId:userId]
                     chipValue:_gameService.gameState.singleBet
                         count:[_gameService betCountOfUser:userId]];
    [self updateTotalBetAndSingleBet];
    [self updateUserTotalBet:userId];
}

- (void)someoneShowCard:(NSString*)userId cardIds:(NSArray *)cardIds
{
    for (NSNumber *cardId in cardIds) {
        [[self getPokersViewByPosition:[self getPositionByUserId:userId]] faceUpCard:cardId.intValue
                                                                           animation:YES];
    }
}

- (void)someone:(NSString*)userId
compareCardWith:(NSString*)targetUserId
         didWin:(BOOL)didWin
      initiator:(NSString*)initiatorId
{
    BOOL gender = [_gameService.session getUserByUserId:initiatorId].gender;
    [_audioManager playSoundByName:[_soundManager compareCardHumanSound:gender]];
    [_audioManager playSoundByName:[_soundManager compareCardSoundEffect]];
    
    ZJHPokerView* pokerView = [self getPokersViewByUserId:userId];
    ZJHPokerView* otherPokerView = [self getPokersViewByUserId:targetUserId];
    CGPoint pokerViewOrgPoint = pokerView.center;
    CGPoint otherPokerViewOrgPoint = otherPokerView.center;
    _isComparing = YES;
    
    [UIView animateWithDuration:1 animations:^{
        pokerView.layer.position = CGPointMake(self.view.center.x, self.view.center.y - 30);
        otherPokerView.layer.position = CGPointMake(self.view.center.x, self.view.center.y + 30);
        if ([_userManager isMe:userId]) {
            pokerView.layer.transform = CATransform3DMakeScale(28/35.0, 37/48.0, 1);
        }
        if ([_userManager isMe:targetUserId ]) {
            otherPokerView.layer.transform = CATransform3DMakeScale(28/35.0, 37/48.0, 1);
        }
        
    } completion:^(BOOL finished) {
        self.vsImageView.hidden = NO;

        if (didWin) {
            [pokerView winCards:YES];
            [otherPokerView loseCards:YES];
        }else {
            [pokerView loseCards:YES];
            [otherPokerView winCards:YES];
        }

        [UIView animateWithDuration:1 animations:^{
            pokerView.layer.position = CGPointMake(self.view.center.x, self.view.center.y - 29.9);
            otherPokerView.layer.position = CGPointMake(self.view.center.x, self.view.center.y + 29.9);
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:1 animations:^{
                pokerView.layer.position = pokerViewOrgPoint;
                otherPokerView.layer.position = otherPokerViewOrgPoint;
                PPDebug(@"<test>poker view move to org point,(%.2f, %.2f)",pokerViewOrgPoint.x, pokerViewOrgPoint.y);
                PPDebug(@"<test>otherPoker view move to org point,(%.2f, %.2f)", otherPokerViewOrgPoint.x, otherPokerViewOrgPoint.y);
                if ([_userManager isMe:userId]) {
                    pokerView.layer.transform = CATransform3DMakeScale(1, 1, 1);
                }
                if ([_userManager isMe:targetUserId ]) {
                    otherPokerView.layer.transform = CATransform3DMakeScale(1, 1, 1);
                }
                self.vsImageView.hidden = YES;
            } completion:^(BOOL finished) {
                _isComparing = NO;
            }];
        }];
    }];
}

- (void)showCompareCardResult:(NSArray*)userResultList initiator:(NSString*)initiatorId
{
    [self clearAllAvatarReciprocals];
    if (userResultList.count == 2 && !_isComparing) {
        PBUserResult* result1 = [userResultList objectAtIndex:0];
        PBUserResult* result2 = [userResultList objectAtIndex:1];
        
        [self someone:result1.userId compareCardWith:result2.userId didWin:result1.win initiator:initiatorId];
    }
}

- (ZJHPokerSectorType)getPokerSectorTypeByPosition:(UserPosition)position
{
    switch (position) {
        case UserPositionLeft:
        case UserPositionLeftTop:
            return ZJHPokerSectorTypeRight;
            break;
            
        case UserPositionRight:
        case UserPositionRightTop:
            return ZJHPokerSectorTypeLeft;
            break;
            
        default:
            return ZJHPokerSectorTypeNone;
            break;
    }
}

- (ZJHPokerXMotionType)getPokerXMotionTypeByPosition:(UserPosition)position
{
    switch (position) {
        case UserPositionLeft:
        case UserPositionLeftTop:
            return ZJHPokerXMotionTypeRight;
            break;
            
        case UserPositionRight:
        case UserPositionRightTop:
            return ZJHPokerXMotionTypeLeft;
            break;
            
        default:
            return ZJHPokerXMotionTypeNone;
            break;
    }
}

- (void)someoneCheckCard:(NSString*)userId
{
    BOOL gender = [_gameService.session getUserByUserId:userId].gender;
    [_audioManager playSoundByName:[_soundManager checkCardHumanSound:gender]];
    [_audioManager playSoundByName:[_soundManager checkCardSoundEffect]];
    [[self getPokersViewByUserId:userId] makeSectorShape:[self getPokerSectorTypeByPosition:[self getPositionByUserId:userId]] animation:YES];
}

- (void)someoneFoldCard:(NSString*)userId
{
    BOOL gender = [_gameService.session getUserByUserId:userId].gender;
    [_audioManager playSoundByName:[_soundManager foldCardHumanSound:gender]];
    [[self getAvatarViewByUserId:userId] stopReciprocal];
    [[self getPokersViewByUserId:userId] foldCards:YES];
}

- (void)someoneWon:(NSString*)userId
{
    if ([_userManager isMe:userId]) {
        [_audioManager playSoundByName:[_soundManager gameWin]];
        [_audioManager playSoundByName:[_soundManager fullMoney]];
    } else {
        [_audioManager playSoundByName:[_soundManager gameOver]];
    }
    [self.betTable userWonAllChips:[self getPositionByUserId:userId]];
}


#pragma mark - private method

- (void)setAllPlayerComparing
{
    for (PBGameUser* user in _gameService.session.userList) {
        ZJHAvatarView* avatar = [self getAvatarViewByUserId:user.userId];
        if (![_gameService canUserCompareCard:user.userId]) {
            continue;
        }
//        UIButton* btn = (UIButton*)[self.view viewWithTag:avatar.tag - AVATAR_VIEW_TAG_OFFSET + COMPARE_BUTTON_TAG_OFFSET];
//        if (!btn) {
//            btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//            [btn setTitle:@"比" forState:UIControlStateNormal];
//            btn.frame = avatar.frame;
//            btn.tag = avatar.tag - AVATAR_VIEW_TAG_OFFSET + COMPARE_BUTTON_TAG_OFFSET;
//            [btn addTarget:self action:@selector(clickCompareWithSomeone:) forControlEvents:UIControlEventTouchUpInside];
//            [self.view addSubview:btn];
//        }
//        btn.hidden = NO;
//        [self.view bringSubviewToFront:btn];
        ZJHPokerView* pokerView = (ZJHPokerView*)[self.view viewWithTag:(avatar.tag - AVATAR_VIEW_TAG_OFFSET + POKERS_VIEW_TAG_OFFSET)];
        [pokerView showBomb];
    }
}

- (void)setAllPlayerNotComparing
{
    for (int i = UserPositionCenter; i < UserPositionMax; i ++) {
        ZJHAvatarView* avatar = [self getAvatarViewByPosition:i];
        ZJHPokerView* pokerView = (ZJHPokerView*)[self.view viewWithTag:(avatar.tag - AVATAR_VIEW_TAG_OFFSET + POKERS_VIEW_TAG_OFFSET)];
        [pokerView clearBomb];
        
    }
}

- (void)setIsComparing:(BOOL)isComparing
{
    _isComparing = isComparing;
    if (isComparing) {
        [self setAllPlayerComparing];
    } else {
        [self setAllPlayerNotComparing];
    }

}

- (PBGameUser*)getSelfUser
{
    return [_gameService.session getUserByUserId:_userManager.userId];
}

- (void)updateAllUsersAvatar
{
    //init seats
    for (int i = UserPositionCenter; i < UserPositionMax; i ++) {
        ZJHAvatarView* avatar = (ZJHAvatarView*)[self.view viewWithTag:AVATAR_VIEW_TAG_OFFSET+i];
        [avatar resetAvatar];
    }
    
    [[self getAvatarViewByPosition:UserPositionCenter] updateByPBGameUser:[_userManager toPBGameUser]];
    [[self getAvatarViewByPosition:UserPositionCenter] setDelegate:self];
    
    // set user on seat
    for (PBGameUser* user in _gameService.session.userList) {
        PPDebug(@"<ZJHGameController>Get user--%@, sitting at %d",user.nickName, user.seatId);

        ZJHAvatarView* avatar = [self getAvatarViewByUserId:user.userId];
        [avatar updateByPBGameUser:user];
    }
}

- (void)updateAllUsersPokers
{
    for (PBGameUser *user in _gameService.session.userList) {
        ZJHPokerView *pokerView = [self getPokersViewByUserId:user.userId];
        ZJHUserPlayInfo *userPlayInfo = [_gameService userPlayInfo:user.userId];

        CGSize pokerSize;
        CGFloat gap;
        if ([_userManager isMe:user.userId]) {
            pokerSize = CGSizeMake(BIG_POKER_VIEW_WIDTH, BIG_POKER_VIEW_HEIGHT);
            gap = BIG_POKER_GAP;
        }else {
            pokerSize = CGSizeMake(SMALL_POKER_VIEW_WIDTH, SMALL_POKER_VIEW_HEIGHT);
            gap = SMALL_POKER_GAP;
        }
        [pokerView updateWithPokers:[_gameService pokersOfUser:user.userId]
                               size:pokerSize
                                gap:gap];
        
        if (userPlayInfo.alreadFoldCard) {
            [pokerView foldCards:YES];
        }
        
        if (userPlayInfo.alreadLose) {
            [pokerView loseCards:YES];
        }
    }
}


- (void)updateWaittingForNextTurnNotLabel
{
    
}

- (ZJHPokerView*)getMyPokersView
{
    return (ZJHPokerView*)[self.view viewWithTag:(POKERS_VIEW_TAG_OFFSET+UserPositionCenter)];
}

- (ZJHPokerView*)getPokersViewByPosition:(UserPosition)position
{
    return (ZJHPokerView*)[self.view viewWithTag:(POKERS_VIEW_TAG_OFFSET+position)];
}


- (ZJHAvatarView*)getAvatarViewByPosition:(UserPosition)position
{
    return (ZJHAvatarView*)[self.view viewWithTag:(AVATAR_VIEW_TAG_OFFSET+position)];
}

- (UserPosition)getPositionByUserId:(NSString*)userId
{
    PBGameUser* user = [_gameService.session getUserByUserId:userId];
    PBGameUser* selfUser = [self getSelfUser];
    return (UserPositionMax + (user.seatId - selfUser.seatId))%UserPositionMax;
}

- (ZJHPokerView*)getPokersViewByUserId:(NSString*)userId
{
    return [self getPokersViewByPosition:[self getPositionByUserId:userId]];
}

- (ZJHAvatarView*)getAvatarViewByUserId:(NSString*)userId
{
    return [self getAvatarViewByPosition:[self getPositionByUserId:userId]];
}

- (ZJHAvatarView*)getMyAvatarView
{
    return [self getAvatarViewByPosition:[self getPositionByUserId:_userManager.userId]];
}

- (void)viewDidUnload {
    [self setBetTable:nil];
    [self setDealerView:nil];
    [self setBetButton:nil];
    [self setRaiseBetButton:nil];
    [self setAutoBetButton:nil];
    [self setCompareCardButton:nil];
    [self setCheckCardButton:nil];
    [self setCardTypeButton:nil];
    [self setFoldCardButton:nil];
    [self setTotalBetLabel:nil];
    [self setSingleBetLabel:nil];
    [self setMoneyTree:nil];
    [self setVsImageView:nil];
    [self.moneyTree kill];
    [super viewDidUnload];
}

#pragma mark - ZJHAvatar delegate

- (void)didClickOnAvatar:(ZJHAvatarView*)view
{
    
}

- (void)reciprocalEnd:(ZJHAvatarView*)view
{
    PPDebug(@"################# [controller: %@] TIME OUT: auto fold ##################", [self description]);
    
    [self clickFoldCardButton:nil];
}

#pragma mark - poker view protocol

- (void)didClickPokerView:(PokerView *)pokerView
{
    if (![_gameService canIShowCard:pokerView.poker.pokerId]) {
        return;
    }
    
    pokerView.showCardButtonIsPopup ? [pokerView dismissShowCardButton] : [pokerView popupShowCardButtonInView:self.view aboveView:nil];
}

- (void)didClickShowCardButton:(PokerView *)pokerView
{
    PPDebug(@"didClickShowCardButton: card rank: %d, suit = %d", pokerView.poker.rank, pokerView.poker.suit);
    [_gameService showCard:pokerView.poker.pokerId];
}

- (void)didClickBombButton:(ZJHPokerView *)zjhPokerView
{
    ZJHAvatarView* avatar = (ZJHAvatarView*)[self.view viewWithTag:(AVATAR_VIEW_TAG_OFFSET+zjhPokerView.tag - POKERS_VIEW_TAG_OFFSET)];
    //    [self someone:[_userManager userId] compareCardWith:avatar.userInfo.userId didWin:YES];
    self.isComparing = NO;
    [_gameService compareCard:avatar.userInfo.userId];
}

#pragma mark - chipsSelectView protocol

- (void)didSelectChip:(int)chipValue
{
    PPDebug(@"didSelectChip: %d", chipValue);
    [[self getMyAvatarView] stopReciprocal];
    [_popupViewManager dismissChipsSelectView];
    [_gameService raiseBet:chipValue];
}

- (void)dismissAllPopupView
{
    [[self getMyPokersView] dismissShowCardButtons];
    [_popupViewManager dismissChipsSelectView];
}

- (void)disableZJHButtons
{
    self.betButton.userInteractionEnabled = NO;
    [self.betButton setTitleColor:TITLE_COLOR_WHEN_DISABLE forState:UIControlStateNormal];
    [self.betButton setBackgroundImage:[_imageManager betBtnDisableBgImage] forState:UIControlStateNormal];
    
    self.raiseBetButton.userInteractionEnabled = NO;
    [self.raiseBetButton setTitleColor:TITLE_COLOR_WHEN_DISABLE forState:UIControlStateNormal];
    [self.raiseBetButton setBackgroundImage:[_imageManager raiseBetBtnDisableBgImage] forState:UIControlStateNormal];
    
    self.autoBetButton.userInteractionEnabled = NO;
    [self.autoBetButton setTitleColor:TITLE_COLOR_WHEN_DISABLE forState:UIControlStateNormal];
    [self.autoBetButton setBackgroundImage:[_imageManager autoBetBtnDisableBgImage] forState:UIControlStateNormal];
    
    self.compareCardButton.userInteractionEnabled = NO;
    [self.compareCardButton setTitleColor:TITLE_COLOR_WHEN_DISABLE forState:UIControlStateNormal];
    [self.compareCardButton setBackgroundImage:[_imageManager compareCardBtnDisableBgImage] forState:UIControlStateNormal];
    
    self.checkCardButton.userInteractionEnabled = NO;
    [self.checkCardButton setTitleColor:TITLE_COLOR_WHEN_DISABLE forState:UIControlStateNormal];
    [self.checkCardButton setBackgroundImage:[_imageManager checkCardBtnDisableBgImage] forState:UIControlStateNormal];
    
//    self.foldCardButton.userInteractionEnabled = NO;
//    [self.foldCardButton setTitleColor:TITLE_COLOR_WHEN_DISABLE forState:UIControlStateNormal];
//    [self.foldCardButton setBackgroundImage:[_imageManager foldCardBtnDisableBgImage] forState:UIControlStateNormal];
}

- (void)updateZJHButtons
{
    self.betButton.userInteractionEnabled = [_gameService canIBet];
    [self.betButton setTitleColor:(self.betButton.userInteractionEnabled ? TITLE_COLOR_WHEN_ENABLE : TITLE_COLOR_WHEN_DISABLE) forState:UIControlStateNormal];
    [self.betButton setBackgroundImage:(self.betButton.userInteractionEnabled ? [_imageManager betBtnBgImage] : [_imageManager betBtnDisableBgImage]) forState:UIControlStateNormal];
    
    self.raiseBetButton.userInteractionEnabled = [_gameService canIRaiseBet];
    [self.raiseBetButton setTitleColor:(self.raiseBetButton.userInteractionEnabled ? TITLE_COLOR_WHEN_ENABLE : TITLE_COLOR_WHEN_DISABLE) forState:UIControlStateNormal];
    [self.raiseBetButton setBackgroundImage:(self.raiseBetButton.userInteractionEnabled ? [_imageManager raiseBetBtnBgImage] : [_imageManager raiseBetBtnDisableBgImage]) forState:UIControlStateNormal];
    
    self.autoBetButton.userInteractionEnabled = [_gameService canIAutoBet];
    self.autoBetButton.selected = [_gameService isMeAutoBet];
    [self.autoBetButton setTitleColor:(self.autoBetButton.userInteractionEnabled ? TITLE_COLOR_WHEN_ENABLE : TITLE_COLOR_WHEN_DISABLE) forState:UIControlStateNormal];
    [self.autoBetButton setBackgroundImage:(self.autoBetButton.userInteractionEnabled ? [_imageManager autoBetBtnBgImage] : [_imageManager autoBetBtnDisableBgImage]) forState:UIControlStateNormal];
    
    self.compareCardButton.userInteractionEnabled = [_gameService canICompareCard];
    [self.compareCardButton setTitleColor:(self.compareCardButton.userInteractionEnabled ? TITLE_COLOR_WHEN_ENABLE : TITLE_COLOR_WHEN_DISABLE) forState:UIControlStateNormal];
    [self.compareCardButton setBackgroundImage:(self.compareCardButton.userInteractionEnabled ? [_imageManager compareCardBtnBgImage] : [_imageManager compareCardBtnDisableBgImage]) forState:UIControlStateNormal];

    self.checkCardButton.userInteractionEnabled = [_gameService canICheckCard];
    [self.checkCardButton setTitleColor:(self.checkCardButton.userInteractionEnabled ? TITLE_COLOR_WHEN_ENABLE : TITLE_COLOR_WHEN_DISABLE) forState:UIControlStateNormal];
    [self.checkCardButton setBackgroundImage:(self.checkCardButton.userInteractionEnabled ? [_imageManager checkCardBtnBgImage] : [_imageManager checkCardBtnDisableBgImage]) forState:UIControlStateNormal];

    self.foldCardButton.userInteractionEnabled = [_gameService canIFoldCard];
    [self.foldCardButton setTitleColor:(self.foldCardButton.userInteractionEnabled ? TITLE_COLOR_WHEN_ENABLE : TITLE_COLOR_WHEN_DISABLE) forState:UIControlStateNormal];
    [self.foldCardButton setBackgroundImage:(self.foldCardButton.userInteractionEnabled ? [_imageManager foldCardBtnBgImage] : [_imageManager foldCardBtnDisableBgImage]) forState:UIControlStateNormal];
}

#pragma mark - deal view delegate
- (void)didDealFinish:(DealerView *)view
{
    [self updateAllUsersPokers];
}

- (void)showMyCardTypeString
{
    _cardTypeButton.hidden = NO;
    [_cardTypeButton setTitle:[_gameService myCardType] forState:UIControlStateNormal];
}

- (void)hideMyCardTypeString
{
    _cardTypeButton.hidden = YES;
}

- (void)clearAllUserPokers
{
    for (int i = UserPositionCenter; i < UserPositionMax; i ++){
        [[self getPokersViewByPosition:i] clear];
    }
}

- (void)clearAllAvatarReciprocals
{
    for (int i = UserPositionCenter; i < UserPositionMax; i ++){
        [[self getAvatarViewByPosition:i] stopReciprocal];
    }
}

#pragma mark - pravite methods, update bet.

- (void)updateTotalBetAndSingleBet
{
    self.totalBetLabel.text = [self int2String:_gameService.gameState.totalBet];
    self.singleBetLabel.text = [self int2String:_gameService.gameState.singleBet];
}

- (void)updateAllUserTotalBet
{
    for (PBGameUser *user in _gameService.session.userList) {
        [self updateUserTotalBet:user.userId];
    }
}

- (void)updateUserTotalBet:(NSString *)userId
{
    [[self totalBetLabelOfUser:userId] setHidden:NO];
    [[self totalBetBgImageViewOfUser:userId] setHidden:NO];
    [[self totalBetLabelOfUser:userId] setText:[self int2String:[_gameService totalBetOfUser:userId]]];
}

- (void)hideAllUserTotalBet
{
    for (int pos = UserPositionCenter; pos < UserPositionMax; pos ++) {
        [self hideTotalBetOfPosition:pos];
    }
}

- (void)hideUserTotalBet:(NSString *)userId
{
    [[self totalBetLabelOfUser:userId] setHidden:YES];
    [[self totalBetBgImageViewOfUser:userId] setHidden:YES];
}

- (void)hideTotalBetOfPosition:(UserPosition)position
{
    [[self totalBetLabelOfPosition:position] setHidden:YES];
    [[self totalBetBgImageViewOfPosition:position] setHidden:YES];
}

- (UILabel *)totalBetLabelOfUser:(NSString *)userId
{
    return (UILabel *)[self.view viewWithTag:USER_TOTAL_BET_LABEL+[self getPositionByUserId:userId]];
}

- (UIImageView *)totalBetBgImageViewOfUser:(NSString *)userId
{
    return (UIImageView *)[self.view viewWithTag:USER_TOTAL_BET_BG_IMAGE_VIEW_OFFSET+ [self getPositionByUserId:userId]];
}

- (UILabel *)totalBetLabelOfPosition:(UserPosition)position
{
    return (UILabel *)[self.view viewWithTag:USER_TOTAL_BET_LABEL+position];
}

- (UIImageView *)totalBetBgImageViewOfPosition:(UserPosition)position
{
    return (UIImageView *)[self.view viewWithTag:USER_TOTAL_BET_BG_IMAGE_VIEW_OFFSET+ position];
}

- (NSString *)int2String:(int)intValue
{
    return [NSString stringWithFormat:@"%d", intValue];
}

#pragma mark - test

- (IBAction)testBet:(id)sender
{
    [self.betTable someBetFrom:UserPositionCenter chipValue:5 count:1];

}

- (IBAction)testWin:(id)sender
{
    [self.betTable userWonAllChips:UserPositionLeftTop];

}

#pragma mark - test end

- (void)allBet
{
    for (PBGameUser *user in _gameService.session.userList) {
        [self.betTable someBetFrom:[self getPositionByUserId:user.userId]
                         chipValue:_gameService.gameState.singleBet
                             count:[_gameService betCountOfUser:user.userId]];

    }
}

- (void)updateMyAvatar
{
    [(ZJHMyAvatarView*)[self getAvatarViewByPosition:UserPositionCenter] update];
}


@end
