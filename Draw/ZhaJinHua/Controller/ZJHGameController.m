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
#import "MessageView.h"
#import "CommonMessageCenter.h"
#import "ZJHSettingView.h"
#import "ZJHScreenConfig.h"

#define AVATAR_VIEW_TAG_OFFSET   4000
#define AVATAR_PLACE_VIEW_OFFSET    8000
#define POKERS_VIEW_TAG_OFFSET   2000
#define USER_TOTAL_BET_BG_IMAGE_VIEW_OFFSET 3000
#define USER_TOTAL_BET_LABEL 3200

#define CARDS_COUNT 3

//#define TITLE_COLOR_WHEN_DISABLE [UIColor colorWithRed:6.0/255.0 green:41.0/255.0 blue:56.0/255.0 alpha:1]
#define TITLE_COLOR_WHEN_DISABLE [UIColor lightGrayColor]
#define TITLE_COLOR_WHEN_ENABLE [UIColor whiteColor]

#define ACTION_LABEL_FONT ([DeviceDetection isIPAD] ? [UIFont systemFontOfSize:22] : [UIFont systemFontOfSize:11])

@interface ZJHGameController ()
{
    ZJHGameService  *_gameService;
    LevelService    *_levelService;
    UserManager     *_userManager;
    AudioManager    *_audioManager;
    ZJHImageManager *_imageManager;
    PopupViewManager *_popupViewManager;
    ZJHSoundManager  *_soundManager;
    CommonMessageCenter* _msgCenter;
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
    [_gameBgImageView release];
    [_totalBetBgImageView release];
    [_buttonsHolderBgImageView release];
    [_runawayButton release];
    [_settingButton release];
    [_chatButton release];
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
        _audioManager = [AudioManager defaultManager];
        _popupViewManager = [PopupViewManager defaultManager];
        _soundManager = [ZJHSoundManager defaultManager];
        _msgCenter = [CommonMessageCenter defaultCenter];
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _gameService = [ZJHGameService defaultService];
        _userManager = [UserManager defaultManager];
        _imageManager = [ZJHImageManager defaultManager];
        _levelService = [LevelService defaultService];
        _audioManager = [AudioManager defaultManager];
        _popupViewManager = [PopupViewManager defaultManager];
        _soundManager = [ZJHSoundManager defaultManager];
        _msgCenter = [CommonMessageCenter defaultCenter];
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

- (void)setImages
{
    self.gameBgImageView.image = [_imageManager gameBgImage];
    self.totalBetBgImageView.image = [_imageManager totalBetBgImage];
    self.buttonsHolderBgImageView.image = [_imageManager buttonsHolderBgImage];
    [self.runawayButton setBackgroundImage:[_imageManager runawayButtonImage] forState:UIControlStateNormal] ;
    [self.settingButton setBackgroundImage:[_imageManager settingButtonImage] forState:UIControlStateNormal] ;
    [self.chatButton setBackgroundImage:[_imageManager chatButtonImage] forState:UIControlStateNormal] ;
    [self.moneyTree setBackgroundImage:[_imageManager moneyTreeImage] forState:UIControlStateNormal] ;
    self.vsImageView.image = [_imageManager vsImage];
    
    [self.autoBetButton setBackgroundImage:[_imageManager autoBetBtnOnBgImage] forState:UIControlStateSelected];
    [self updateZJHButtons];
    
    for (int tag = USER_TOTAL_BET_BG_IMAGE_VIEW_OFFSET; tag < USER_TOTAL_BET_BG_IMAGE_VIEW_OFFSET + UserPositionMax; tag ++) {
        [((UIImageView *)[self.view viewWithTag:tag]) setImage:[_imageManager userTotalBetBgImage]];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // Do any additional setup after loading the view from its nib.
    
    [self setImages];

    [self initAllAvatars];
    [self updateAllUsersAvatar];
    
    // hidden views below
    [self updateTotalBetAndSingleBet];

    [self hideAllUserTotalBet];
    
    [self updateView];
    
    self.dealerView.delegate = self;
    
    [self.moneyTree startGrow];
    self.moneyTree.delegate = self;
    
    [_audioManager setBackGroundMusicWithURL:[_soundManager gameBGM]];
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

- (void)compareToUser:(NSString*)targetUserId
{
    [_gameService compareCard:targetUserId];
}

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

- (IBAction)clickSettingButton:(id)sender
{
    [[ZJHSettingView createZJHSettingView] showInView:self.view];
}

#pragma mark - player action response

- (void)betSuccess
{
    ZJHUserPlayInfo *userPlayInfo = [_gameService userPlayInfo:_userManager.userId];
    BOOL gender = [_userManager.gender isEqualToString:@"m"];
    NSURL* soundURL;
    if (userPlayInfo.lastAction == PBZJHUserActionRaiseBet) {
        soundURL = [_soundManager raiseBetHumanSound:gender];
    } else {
        soundURL = [_soundManager betHumanSound:gender];
    }
    [_audioManager playSoundByURL:soundURL];
    [_audioManager playSoundByURL:[_soundManager betSoundEffect]];

    //    [_audioManager playSoundByURL:[_soundManager betSoundEffect]];
    
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
    [_audioManager playSoundByURL:[_soundManager checkCardHumanSound:gender]];
    [_audioManager playSoundByURL:[_soundManager checkCardSoundEffect]];
    
    [self updateZJHButtons];
}

- (void)foldCardSuccess
{
    [_audioManager playSoundByURL:_soundManager.foldCardSoundEffect];
    [_audioManager playSoundByURL:[_soundManager foldCardHumanSound:[@"m" isEqualToString:_userManager.gender]]];
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
        }else{
            [_gameService setAutoBet:NO];
        }
    }
}

- (void)someoneBet:(NSString*)userId
{
    ZJHUserPlayInfo *userPlayInfo = [_gameService userPlayInfo:userId];
    BOOL gender = [_gameService.session getUserByUserId:userId].gender;
    NSURL* soundURL;
    if (userPlayInfo.lastAction == PBZJHUserActionRaiseBet) {
        soundURL = [_soundManager raiseBetHumanSound:gender];
        [self popupRaiseBetMessageAtUser:userId];
    } else {
        soundURL = [_soundManager betHumanSound:gender];
        [self popupBetMessageAtUser:userId];
    }
    [_audioManager playSoundByURL:soundURL];
    [_audioManager playSoundByURL:[_soundManager betSoundEffect]];
    
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

#define COMPARE_CARD_OFFSET  ([DeviceDetection isIPAD]?60:30)

- (void)someone:(NSString*)userId
compareCardWith:(NSString*)targetUserId
         didWin:(BOOL)didWin
      initiator:(NSString*)initiatorId
{
    BOOL gender = [_gameService.session getUserByUserId:initiatorId].gender;
    [_audioManager playSoundByURL:[_soundManager compareCardHumanSound:gender]];
    [_audioManager playSoundByURL:[_soundManager compareCardSoundEffect]];
    
    ZJHPokerView* pokerView = [self getPokersViewByUserId:userId];
    ZJHPokerView* otherPokerView = [self getPokersViewByUserId:targetUserId];
    CGPoint pokerViewOrgPoint = pokerView.center;
    CGPoint otherPokerViewOrgPoint = otherPokerView.center;
    _isComparing = YES;
    
    [UIView animateWithDuration:1 animations:^{
        pokerView.layer.position = CGPointMake(self.view.center.x, self.view.center.y - COMPARE_CARD_OFFSET);
        otherPokerView.layer.position = CGPointMake(self.view.center.x, self.view.center.y + COMPARE_CARD_OFFSET);
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
            pokerView.layer.position = CGPointMake(self.view.center.x, self.view.center.y - COMPARE_CARD_OFFSET-0.1);
            otherPokerView.layer.position = CGPointMake(self.view.center.x, self.view.center.y + COMPARE_CARD_OFFSET-0.1);
            
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
                _isShowingComparing = NO;
            }];
        }];
    }];
}

- (void)showCompareCardResult:(NSArray*)userResultList initiator:(NSString*)initiatorId
{
    [self clearAllAvatarReciprocals];
    self.isComparing = NO;
    if (userResultList.count == 2 && !_isShowingComparing) {
        PBUserResult* result1 = [userResultList objectAtIndex:0];
        PBUserResult* result2 = [userResultList objectAtIndex:1];
        
        if ([result1.userId isEqualToString:_userManager.userId] || [result2.userId isEqualToString:_userManager.userId]) {
            [self disableCheckCardAndFoldCardButtons];
        }
        
        [self someone:initiatorId
      compareCardWith:[result2.userId isEqualToString:initiatorId]?result1.userId:result2.userId
               didWin:[result1.userId isEqualToString:initiatorId]?result1.win:result2.win
            initiator:initiatorId];
    }
    
    if (![_userManager isMe:initiatorId]) {
        [self popupCompareCardMessageAtUser:initiatorId];
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
    [_audioManager playSoundByURL:[_soundManager checkCardHumanSound:gender]];
    [_audioManager playSoundByURL:[_soundManager checkCardSoundEffect]];
    [[self getPokersViewByUserId:userId] makeSectorShape:[self getPokerSectorTypeByPosition:[self getPositionByUserId:userId]] animation:YES];
    [self popupCheckCardMessageAtUser:userId];
}

- (void)someoneFoldCard:(NSString*)userId
{
    BOOL gender = [_gameService.session getUserByUserId:userId].gender;
    [_audioManager playSoundByURL:[_soundManager foldCardHumanSound:gender]];
    [[self getAvatarViewByUserId:userId] stopReciprocal];
    [[self getPokersViewByUserId:userId] foldCards:YES];
    [self popupFoldCardMessageAtUser:userId];
}

- (void)someoneWon:(NSString*)userId
{
    if ([_userManager isMe:userId]) {
        [_audioManager playSoundByURL:[_soundManager gameWin]];
        [_audioManager playSoundByURL:[_soundManager fullMoney]];
    } else {
        [_audioManager playSoundByURL:[_soundManager gameOver]];
    }
    [self.betTable userWonAllChips:[self getPositionByUserId:userId]];
}


#pragma mark - private method

- (void)setAllPlayerComparing
{
    if (_gameService.compareUserIdList.count == 1) {
        [self compareToUser:(NSString*)[_gameService.compareUserIdList objectAtIndex:0]];
        return;
    }
    for (NSString* userId in _gameService.compareUserIdList) {
        ZJHPokerView* pokerView = [self getPokersViewByUserId:userId];
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
        
        if (userPlayInfo.alreadCheckCard) {
            [pokerView makeSectorShape:[self getPokerSectorTypeByPosition:[self getPositionByUserId:user.userId]] animation:YES];
        }
        
        if (userPlayInfo.alreadFoldCard) {
            [pokerView foldCards:YES];
        }
        
        if (userPlayInfo.alreadCompareLose) {
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

- (ZJHMyAvatarView*)getMyAvatarView
{
    return (ZJHMyAvatarView*)[self getAvatarViewByPosition:UserPositionCenter];
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
    [self setGameBgImageView:nil];
    [self setTotalBetBgImageView:nil];
    [self setButtonsHolderBgImageView:nil];
    [self setRunawayButton:nil];
    [self setSettingButton:nil];
    [self setChatButton:nil];
    [super viewDidUnload];
}

#pragma mark - ZJHAvatar delegate

- (void)didClickOnAvatar:(ZJHAvatarView*)view
{
    
}

- (void)reciprocalEnd:(ZJHAvatarView*)view
{
    PPDebug(@"################# [controller: %@] TIME OUT: auto fold ##################", [self description]);
    if (_isComparing) {
        [self bet:NO];
        self.isComparing = NO;
        return;
    }
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
    [self compareToUser:avatar.userInfo.userId];
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

- (void)disableCheckCardAndFoldCardButtons
{
    self.checkCardButton.userInteractionEnabled = NO;
    [self.checkCardButton setTitleColor:TITLE_COLOR_WHEN_DISABLE forState:UIControlStateNormal];
    [self.checkCardButton setBackgroundImage:[_imageManager checkCardBtnDisableBgImage] forState:UIControlStateNormal];
    
    self.foldCardButton.userInteractionEnabled = NO;
    [self.foldCardButton setTitleColor:TITLE_COLOR_WHEN_DISABLE forState:UIControlStateNormal];
    [self.foldCardButton setBackgroundImage:[_imageManager foldCardBtnDisableBgImage] forState:UIControlStateNormal];
}

#pragma mark - deal view delegate
- (void)didDealFinish:(DealerView *)view
{
    [self updateAllUsersPokers];
    [self updateZJHButtons];
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
    for (NSString *userId in [_gameService.gameState.usersInfo allKeys]) {
        [self updateUserTotalBet:userId];
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

- (void)popupView:(UIView *)view
       atPosition:(UserPosition)position
{
    CGPoint point = [ZJHScreenConfig getMessageViewOriginByPosition:position];
    view.frame = CGRectMake(point.x, point.y, view.frame.size.width, view.frame.size.height);
    [self.view addSubview:view];

    [UIView animateWithDuration:0.3 animations:^{
        view.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.5 delay:0.5 options:UIViewAnimationCurveEaseInOut animations:^{
            view.center = CGPointMake(view.center.x, view.center.y - ([DeviceDetection isIPAD] ? 30 : 15));
            view.alpha = 0;
        } completion:^(BOOL finished) {
            [view removeFromSuperview];

        }];
    }];
}

- (void)popupBetMessageAtUser:(NSString *)userId
{
    UserPosition pos = [self getPositionByUserId:userId];
    MessageView *view = [MessageView messageViewWithMessage:@"跟注" font:ACTION_LABEL_FONT textAlignment:UITextAlignmentCenter bgImage:[_imageManager betActionImage:pos]];
    
    [self popupView:view atPosition:[self getPositionByUserId:userId]];
}

- (void)popupRaiseBetMessageAtUser:(NSString *)userId
{
    UserPosition pos = [self getPositionByUserId:userId];
    MessageView *view = [MessageView messageViewWithMessage:@"加注" font:ACTION_LABEL_FONT textAlignment:UITextAlignmentCenter bgImage:[_imageManager raiseBetActionImage:pos]];
    
    [self popupView:view atPosition:[self getPositionByUserId:userId]];
}

- (void)popupCheckCardMessageAtUser:(NSString *)userId
{
    UserPosition pos = [self getPositionByUserId:userId];
    MessageView *view = [MessageView messageViewWithMessage:@"看牌" font:ACTION_LABEL_FONT textAlignment:UITextAlignmentCenter bgImage:[_imageManager checkCardActionImage:pos]];
    
    [self popupView:view atPosition:[self getPositionByUserId:userId]];
}

- (void)popupCompareCardMessageAtUser:(NSString *)userId
{
    UserPosition pos = [self getPositionByUserId:userId];
    MessageView *view = [MessageView messageViewWithMessage:@"比牌" font:ACTION_LABEL_FONT textAlignment:UITextAlignmentCenter bgImage:[_imageManager compareCardActionImage:pos]];
    
    [self popupView:view atPosition:[self getPositionByUserId:userId]];
}

- (void)popupFoldCardMessageAtUser:(NSString *)userId
{
    UserPosition pos = [self getPositionByUserId:userId];
    MessageView *view = [MessageView messageViewWithMessage:@"弃牌" font:ACTION_LABEL_FONT textAlignment:UITextAlignmentCenter bgImage:[_imageManager foldCardActionImage:pos]];
    
    [self popupView:view atPosition:[self getPositionByUserId:userId]];
}


#pragma mark - money tree delegate
- (void)getMoney:(int)money fromTree:(MoneyTree *)tree
{
    [_audioManager playSoundByURL:[_soundManager betSoundEffect]];
    [[AccountService defaultService] chargeAccount:money source:MoneyTreeAward];
    [[self getMyAvatarView] update];
    [_msgCenter postMessageWithText:[NSString stringWithFormat:NSLS(@"kGetMoneyFromTree"), money]
                          delayTime:1
                            isHappy:YES];
}

- (void)moneyTreeNotMature:(MoneyTree *)tree
{
    [_msgCenter postMessageWithText:NSLS(@"kMoneyTreeNotMature")
                          delayTime:1];
}



@end
