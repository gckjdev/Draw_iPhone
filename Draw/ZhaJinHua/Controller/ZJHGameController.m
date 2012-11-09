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
    [self updateAllPlayersAvatar];
    self.dealerView.delegate = self;
    
    [self disableZJHButtons];
    
    // hidden views below
    self.cardTypeButton.hidden = YES;
    self.cardTypeButton.userInteractionEnabled = NO;
    
    [self updateTotalBetAndSingleBet];
    [self updateAllUserTotalBet];
    [self.moneyTree startGrowth];
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
                                       [self showCompareCardResult:userResultList];
                                       
//                                       [self compareCardSuccess];
                                   }];
    
    [self registerNotificationWithName:NOTIFICATION_GAME_OVER_NOTIFICATION_REQUEST
                                   usingBlock:^(NSNotification *notification) {
                                       [self gameOver];
                                   }];
}

#pragma mark - player action
- (IBAction)clickBetButton:(id)sender {
    [[self getMyAvatarView] stopReciprocol];
    [self disableZJHButtons];
    [_popupViewManager dismissChipsSelectView];
    [_gameService bet:NO];
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
    [[self getMyAvatarView] stopReciprocol];
    self.autoBetButton.selected = YES;
    [self disableZJHButtons];
    [_popupViewManager dismissChipsSelectView];
    [_gameService bet:YES];
}

- (IBAction)clickCompareCardButton:(id)sender
{
    self.isComparing = YES;
}

- (IBAction)clickCheckCardButton:(id)sender
{
    [[self getMyPokersView] faceUpCards:ZJHPokerXMotionTypeNone animation:YES];
    [self showMyCardTypeString];

    [_gameService checkCard];
}

- (IBAction)clickFoldCardButton:(id)sender
{
    [[self getMyAvatarView] stopReciprocol];
    [self disableZJHButtons];
    [[self getMyPokersView] foldCards:YES];
    [_gameService foldCard];
}

- (IBAction)clickQuitButton:(id)sender
{
    [_gameService quitGame];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - player action response

- (void)betSuccess
{
    [self.betTable someBetFrom:[self getPositionByUserId:_userManager.userId]
                     chipValue:_gameService.gameState.singleBet
                         count:[_gameService betCountOfUser:_userManager.userId]];
    
    [self updateTotalBetAndSingleBet];
    [self updateUserTotalBet:_userManager.userId];
    [self updateAutoBetButton];
    [self updateMyAvatar];
}

- (void)checkCardSuccess
{
    [self updateZJHButtons];
}

- (void)foldCardSuccess
{
}

- (void)showCardSuccess
{
    
}

- (void)compareCardSuccess
{
    
}

#pragma mark - service notification request

- (void)roomChanged
{
    [self updateAllPlayersAvatar];
    [self updateWaittingForNextTurnNotLabel];
    
    for (NSString *userId in [_gameService.session.deletedUserList allKeys]) {
        [self hideTotalBetOfUser:userId];
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
    [self updateAutoBetButton];
    
    [self allBet];
}

- (void)gameOver
{
    [self disableZJHButtons];
    [self clearAllAvatarReciprocols];
    [self someoneWon:[_gameService winner]];

    [self faceupUserCards];
    [self performSelector:@selector(resetGame) withObject:nil afterDelay:3.0];
}

- (void)resetGame
{
    self.autoBetButton.selected = NO;
    [self hiddenMyCardTypeString];
    [self clearAllUserPokers];
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
    [[self getAvatarViewByPosition:[self getPositionByUserId:_gameService.session.currentPlayUserId]] startReciprocol:[ConfigManager getZJHTimeInterval]];
        
    [self updateZJHButtons];
    
    if ([_gameService canIContinueAutoBet]) {
            [self clickAutoBetButton:nil];
    }
}

- (void)someoneBet:(NSString*)userId
{
    [[self getAvatarViewByUserId:userId] stopReciprocol];
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
{
    ZJHPokerView* pokerView = [self getPokersViewByUserId:userId];
    ZJHPokerView* otherPokerView = [self getPokersViewByUserId:targetUserId];
    CGPoint pokerViewOrgPoint = pokerView.center;
    CGPoint otherPokerViewOrgPoint = otherPokerView.center;
    
    
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
        [pokerView compare:YES win:didWin];
        [otherPokerView compare:YES win:!didWin];
        [UIView animateWithDuration:1 animations:^{
            pokerView.layer.position = CGPointMake(self.view.center.x, self.view.center.y - 29.9);
            otherPokerView.layer.position = CGPointMake(self.view.center.x, self.view.center.y + 29.9);
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:1 animations:^{
                pokerView.layer.position = pokerViewOrgPoint;
                otherPokerView.layer.position = otherPokerViewOrgPoint;
                if ([_userManager isMe:userId]) {
                    pokerView.layer.transform = CATransform3DMakeScale(1, 1, 1);
                }
                if ([_userManager isMe:targetUserId ]) {
                    otherPokerView.layer.transform = CATransform3DMakeScale(1, 1, 1);
                }
                self.vsImageView.hidden = YES;
            } completion:^(BOOL finished) {
                
            }];
        }];
    }];
    
//    [pokerView.layer addAnimation:[AnimationManager translationAnimationFrom:pokerView.center to:self.view.center duration:2 delegate:self removeCompeleted:NO] forKey:nil];
//    [otherPokerView.layer addAnimation:[AnimationManager translationAnimationFrom:otherPokerView.center to:self.view.center duration:2 delegate:self removeCompeleted:NO] forKey:nil];
//    [CATransaction setCompletionBlock:^{
//        [pokerView compare:YES win:didWin];
//        [otherPokerView compare:YES win:!didWin];
//        [pokerView.layer addAnimation:[AnimationManager translationAnimationFrom:self.view.center to:pokerView.center duration:2 delegate:self removeCompeleted:NO] forKey:nil];
//        [otherPokerView.layer addAnimation:[AnimationManager translationAnimationFrom:self.view.center to:otherPokerView.center duration:2 delegate:self removeCompeleted:NO] forKey:nil];
//    }];
}

- (void)showCompareCardResult:(NSArray*)userResultList
{
    [self clearAllAvatarReciprocols];
    if (userResultList.count == 2) {
        PBUserResult* result1 = [userResultList objectAtIndex:0];
        PBUserResult* result2 = [userResultList objectAtIndex:1];
        
        [self someone:result1.userId compareCardWith:result2.userId didWin:result1.win];
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
    [[self getPokersViewByUserId:userId] makeSectorShape:[self getPokerSectorTypeByPosition:[self getPositionByUserId:userId]] animation:YES];
}

- (void)someoneFoldCard:(NSString*)userId
{
    [[self getAvatarViewByUserId:userId] stopReciprocol];
    [[self getPokersViewByUserId:userId] foldCards:YES];
}

- (void)someoneWon:(NSString*)userId
{
    [self.betTable userWonAllChips:[self getPositionByUserId:userId]];
}

- (void)someoneJoinIn:(NSString*)userId
{
    [[self getAvatarViewByUserId:userId] setUserInfo:[_gameService.session getUserByUserId:userId]];
    [self updateUserTotalBet:userId];
}

- (void)someoneFlee:(NSString*)userId
{
    [self someoneFoldCard:userId];
    [[self getAvatarViewByUserId:userId] resetAvatar];
    [self hideTotalBetOfUser:userId];
}

#pragma mark - private method

//- (void)clickCompareWithSomeone:(id)sender
//{
//    UIButton* compareSomeoneBtn = (UIButton*)sender;
//    ZJHAvatarView* avatar = (ZJHAvatarView*)[self.view viewWithTag:(AVATAR_VIEW_TAG_OFFSET+compareSomeoneBtn.tag - COMPARE_BUTTON_TAG_OFFSET)];
////    [self someone:[_userManager userId] compareCardWith:avatar.userInfo.userId didWin:YES];
//    self.isComparing = NO;
//    [_gameService compareCard:avatar.userInfo.userId];
//}

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

- (void)updateAllPlayersAvatar
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
//        PPDebug(@"<test>get user--%@, sitting at %d",user.nickName, user.seatId);

        ZJHAvatarView* avatar = [self getAvatarViewByUserId:user.userId];
        [avatar updateByPBGameUser:user];
    }
}

- (void)updateAllPokers
{
    for (int i = UserPositionCenter; i < UserPositionMax; i ++) {
        ZJHAvatarView* avatar = (ZJHAvatarView*)[self.view viewWithTag:AVATAR_VIEW_TAG_OFFSET+i];
        ZJHPokerView* pokerView = (ZJHPokerView*)[self.view viewWithTag:POKERS_VIEW_TAG_OFFSET+i];
        
        if (avatar.userInfo) {
            CGSize pokerSize;
            CGFloat gap;
            if ([_userManager isMe:avatar.userInfo.userId]) {
                pokerSize = CGSizeMake(BIG_POKER_VIEW_WIDTH, BIG_POKER_VIEW_HEIGHT);
                gap = BIG_POKER_GAP;
            }else {
                pokerSize = CGSizeMake(SMALL_POKER_VIEW_WIDTH, SMALL_POKER_VIEW_HEIGHT);
                gap = SMALL_POKER_GAP;
            }
            [pokerView updateWithPokers:[_gameService pokersOfUser:avatar.userInfo.userId]
                                   size:pokerSize
                                    gap:gap];
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
    pokerView.showCardButtonIsPopup ? [pokerView dismissShowCardButton] : [pokerView popupShowCardButtonInView:self.view aboveView:nil enabled:[_gameService canIShowCard:pokerView.poker.pokerId]];
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
    [[self getMyAvatarView] stopReciprocol];
    [self disableZJHButtons];
    [_popupViewManager dismissChipsSelectView];
    [_gameService raiseBet:chipValue];
}

- (void)disableZJHButtons
{
    [[self getMyPokersView] dismissShowCardButtons];
    self.betButton.userInteractionEnabled = NO;
    self.raiseBetButton.userInteractionEnabled = NO;
    self.autoBetButton.userInteractionEnabled = NO;
    
    self.compareCardButton.userInteractionEnabled = NO;
    self.checkCardButton.userInteractionEnabled = NO;
    self.foldCardButton.userInteractionEnabled = NO;
    
    [self.betButton setTitleColor:TITLE_COLOR_WHEN_DISABLE forState:UIControlStateNormal];
    [self.raiseBetButton setTitleColor:TITLE_COLOR_WHEN_DISABLE forState:UIControlStateNormal];
    [self.autoBetButton setTitleColor:TITLE_COLOR_WHEN_DISABLE forState:UIControlStateNormal];

    [self.compareCardButton setTitleColor:TITLE_COLOR_WHEN_DISABLE forState:UIControlStateNormal];
    [self.checkCardButton setTitleColor:TITLE_COLOR_WHEN_DISABLE forState:UIControlStateNormal];
    [self.foldCardButton setTitleColor:TITLE_COLOR_WHEN_DISABLE forState:UIControlStateNormal];
    
    [self.betButton setBackgroundImage:[_imageManager betBtnDisableBgImage] forState:UIControlStateNormal];
    [self.raiseBetButton setBackgroundImage: [_imageManager raiseBetBtnDisableBgImage] forState:UIControlStateNormal];
    [self.autoBetButton setBackgroundImage:(self.autoBetButton.userInteractionEnabled ? [_imageManager autoBetBtnBgImage] : [_imageManager autoBetBtnDisableBgImage]) forState:UIControlStateNormal];

    
    [self.compareCardButton setBackgroundImage:[_imageManager compareCardBtnDisableBgImage] forState:UIControlStateNormal];
    [self.checkCardButton setBackgroundImage:[_imageManager checkCardBtnDisableBgImage] forState:UIControlStateNormal];
    [self.foldCardButton setBackgroundImage:[_imageManager foldCardBtnDisableBgImage] forState:UIControlStateNormal];
}

- (void)updateZJHButtons
{
    self.betButton.userInteractionEnabled = [_gameService canIBet];
    [self.betButton setTitleColor:(self.betButton.userInteractionEnabled ? TITLE_COLOR_WHEN_ENABLE : TITLE_COLOR_WHEN_DISABLE) forState:UIControlStateNormal];
    [self.betButton setBackgroundImage:(self.betButton.userInteractionEnabled ? [_imageManager betBtnBgImage] : [_imageManager betBtnDisableBgImage]) forState:UIControlStateNormal];
    
    self.raiseBetButton.userInteractionEnabled = [_gameService canIRaiseBet];
    [self.raiseBetButton setTitleColor:(self.raiseBetButton.userInteractionEnabled ? TITLE_COLOR_WHEN_ENABLE : TITLE_COLOR_WHEN_DISABLE) forState:UIControlStateNormal];
    [self.raiseBetButton setBackgroundImage:(self.raiseBetButton.userInteractionEnabled ? [_imageManager raiseBetBtnBgImage] : [_imageManager raiseBetBtnDisableBgImage]) forState:UIControlStateNormal];

    self.autoBetButton.selected = [_gameService remainderAutoBetCount] > 0 ? YES : NO;
    self.autoBetButton.userInteractionEnabled = [_gameService canIAutoBet];
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
    [self updateAllPokers];
}

- (void)showMyCardTypeString
{
    _cardTypeButton.hidden = NO;
    [_cardTypeButton setTitle:[_gameService myCardType] forState:UIControlStateNormal];
}

- (void)hiddenMyCardTypeString
{
    _cardTypeButton.hidden = YES;
}

- (void)clearAllUserPokers
{
    for (int i = UserPositionCenter; i < UserPositionMax; i ++){
        [[self getPokersViewByPosition:i] clear];
    }
}

- (void)clearAllAvatarReciprocols
{
    for (int i = UserPositionCenter; i < UserPositionMax; i ++){
        [[self getAvatarViewByPosition:i] stopReciprocol];
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

- (void)hideTotalBetOfUser:(NSString *)userId
{
    [[self totalBetLabelOfUser:userId] setHidden:YES];
    [[self totalBetBgImageViewOfUser:userId] setHidden:YES];
}

- (void)updateUserTotalBet:(NSString *)userId
{
    [[self totalBetLabelOfUser:userId] setHidden:NO];
    [[self totalBetBgImageViewOfUser:userId] setHidden:NO];
    [[self totalBetLabelOfUser:userId] setText:[self int2String:[_gameService totalBetOfUser:userId]]];
}

- (UILabel *)totalBetLabelOfUser:(NSString *)userId
{
    return (UILabel *)[self.view viewWithTag:USER_TOTAL_BET_LABEL+[self getPositionByUserId:userId]];
}

- (UIImageView *)totalBetBgImageViewOfUser:(NSString *)userId
{
    return (UIImageView *)[self.view viewWithTag:USER_TOTAL_BET_BG_IMAGE_VIEW_OFFSET+ [self getPositionByUserId:userId]];
}

- (NSString *)int2String:(int)intValue
{
    return [NSString stringWithFormat:@"%d", intValue];
}
- (void)updateAutoBetButton
{
    if ([_gameService remainderAutoBetCount] > 0) {
        [self.autoBetButton setTitle:[NSString stringWithFormat:@"%d", [_gameService remainderAutoBetCount]] forState:UIControlStateNormal];
        
    }else{
        [self.autoBetButton setTitle:@"k跟到底" forState:UIControlStateNormal];
    }
    
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
