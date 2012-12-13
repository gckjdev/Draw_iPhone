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
#import "AnimationManager.h"
#import "RoomTitleView.h"
#import "NotificationName.h"
#import "ZJHRuleConfigFactory.h"
#import "ZJHUserInfoView.h"
#import "ExpressionManager.h"
#import "CommonSettingView.h"

#define AVATAR_VIEW_TAG_OFFSET   4000
//#define AVATAR_PLACE_VIEW_OFFSET    8000
//#define POKERS_VIEW_TAG_OFFSET   2000
//#define USER_TOTAL_BET_BG_IMAGE_VIEW_OFFSET 3000
//#define USER_TOTAL_BET_LABEL 3200

#define CARDS_COUNT 3

//#define TITLE_COLOR_WHEN_DISABLE [UIColor colorWithRed:6.0/255.0 green:41.0/255.0 blue:56.0/255.0 alpha:1]
#define TITLE_COLOR_WHEN_DISABLE [UIColor lightGrayColor]
#define TITLE_COLOR_WHEN_ENABLE [UIColor whiteColor]

#define ACTION_LABEL_FONT ([DeviceDetection isIPAD] ? [UIFont boldSystemFontOfSize:22] : [UIFont boldSystemFontOfSize:11])

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
    ExpressionManager *_expManager;
}
@property (assign, nonatomic) BOOL  isComparing;
@property (retain, nonatomic) ZJHRuleConfig *ruleConfig;
@property (retain, nonatomic) NSDictionary *userPosInfoDic;
@property (retain, nonatomic) ChatView *chatView;
@end

@implementation ZJHGameController
@synthesize betTable = _betTable;
@synthesize dealerView = _dealerView;
@synthesize raiseBetButton = _raiseBetButton;
@synthesize autoBetButton = _autoBetButton;
@synthesize compareCardButton = _compareCardButton;
@synthesize checkCardButton = _checkCardButton;
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
    [_foldCardButton release];
    [_totalBetLabel release];
    [_singleBetLabel release];
    [_moneyTreeHolder release];
    [_vsImageView release];
    [_gameBgImageView release];
    [_totalBetBgImageView release];
    [_buttonsHolderBgImageView release];
    [_runawayButton release];
    [_settingButton release];
    [_chatButton release];
    [_totalBetNoteLabel release];
    [_singleBetNoteLabel release];

    [_moneyTreeView release];

    [_cardTypeLabel release];
    [_roomNameLabel release];

    [_cardTypeBgImageView release];
    [_cardTypeButton release];
    [_waitGameNoteLabel release];
    [_ruleConfig release];
    [_userPosInfoDic release];

    
    [_rightTopAvatar release];
    [_rightAvatar release];
    [_centerAvatar release];
    [_leftAvatar release];
    [_leftTopAvatar release];
    [_leftTopPokers release];
    [_rightTopPokers release];
    [_leftPokers release];
    [_rightPokers release];
    [_centerPokers release];
    [_centerTotalBetBg release];
    [_leftTotalBetBg release];
    [_rightTopTotalBetBg release];
    [_rightTotalBetBg release];
    [_leftTopTotalBetBg release];
    [_centerTotalBet release];
    [_leftTotalBet release];
    [_rightTotalBet release];
    [_rightTopTotalBet release];
    [_leftTopTotalBet release];
    
    [_centerUpPokers release];
    [_centerUpTotalBetBg release];
    [_centerUpTotalBet release];
    [_centerUpAvatar release];
    [_chatView release];
    [super dealloc];
}

//- (id)init
//{
//    self = [super init];
//    if (self) {
//        _gameService = [ZJHGameService defaultService];
//        _userManager = [UserManager defaultManager];
//        _imageManager = [ZJHImageManager defaultManager];
//        _levelService = [LevelService defaultService];
//        _audioManager = [AudioManager defaultManager];
//        _popupViewManager = [PopupViewManager defaultManager];
//        _soundManager = [ZJHSoundManager defaultManager];
//        _msgCenter = [CommonMessageCenter defaultCenter];
//        _expManager = [ExpressionManager defaultManager];
//
//    }
//    
//    return self;
//}

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
        _expManager = [ExpressionManager defaultManager];

    }
    return self;
}

- (void)initAllAvatars
{
    self.userPosInfoDic = [_ruleConfig initAllAvatar:self];
    for (ZJHUserPosInfo *userPosInfo in [_userPosInfoDic allValues]) {
        [self.view addSubview:userPosInfo.avatar];
    }
//    for (int i = UserPositionCenter; i < [_ruleConfig maxPlayerNum]; i ++) {
//        UIView* placeView = [self.view viewWithTag:(i + AVATAR_PLACE_VIEW_OFFSET)];
//        if (i == UserPositionCenter) {
//            ZJHMyAvatarView* myAvatar = [ZJHMyAvatarView createZJHMyAvatarView];
//            [myAvatar setFrame:placeView.frame];
//            [self.view addSubview:myAvatar];
//            myAvatar.tag = AVATAR_VIEW_TAG_OFFSET + i;
//            [myAvatar update];
//            continue;
//        }
//        ZJHAvatarView* anAvatar = [ZJHAvatarView createZJHAvatarView];
//        [anAvatar setFrame:placeView.frame];
//        [self.view addSubview:anAvatar];
//        anAvatar.tag = AVATAR_VIEW_TAG_OFFSET + i;
//    }
}

- (void)setImages
{
    self.gameBgImageView.image = [_ruleConfig gameBgImage];
    self.totalBetBgImageView.image = [_imageManager totalBetBgImage];
    self.buttonsHolderBgImageView.image = [_imageManager buttonsHolderBgImage];
    [self.runawayButton setBackgroundImage:[_imageManager runawayButtonImage] forState:UIControlStateNormal] ;
    [self.settingButton setBackgroundImage:[_imageManager settingButtonImage] forState:UIControlStateNormal] ;
    [self.chatButton setBackgroundImage:[_imageManager chatButtonImage] forState:UIControlStateNormal] ;
    self.vsImageView.image = [_imageManager vsImage];
    [self.autoBetButton setBackgroundImage:[_imageManager autoBetBtnOnBgImage] forState:UIControlStateSelected];
    self.cardTypeBgImageView.image = [_imageManager cardTypeBgImage];
    
    self.centerTotalBetBg.image = [_imageManager userTotalBetBgImage];
    self.leftTotalBetBg.image = [_imageManager userTotalBetBgImage];
    self.leftTopTotalBetBg.image = [_imageManager userTotalBetBgImage];
    self.rightTotalBetBg.image = [_imageManager userTotalBetBgImage];
    self.rightTopTotalBetBg.image = [_imageManager userTotalBetBgImage];
}

- (void)setBeautifulLabels
{
    self.waitGameNoteLabel.shadowColor = nil;
    self.waitGameNoteLabel.shadowOffset = CGSizeMake(0.0f, 2.0f);
    self.waitGameNoteLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.75f];
    self.waitGameNoteLabel.shadowBlur = 5.0f;
    
    self.totalBetNoteLabel.shadowColor = nil;
    self.totalBetNoteLabel.shadowOffset = CGSizeMake(0.0f, 2.0f);
    self.totalBetNoteLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.75f];
    self.totalBetNoteLabel.shadowBlur = 5.0f;
    
    self.singleBetNoteLabel.shadowColor = nil;
    self.singleBetNoteLabel.shadowOffset = CGSizeMake(0.0f, 2.0f);
    self.singleBetNoteLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.75f];
    self.singleBetNoteLabel.shadowBlur = 5.0f;
    
    self.totalBetLabel.gradientStartColor = [UIColor colorWithRed:254.0/255.0 green:241.0/255.0 blue:67.0/255.0 alpha:1];
    self.totalBetLabel.gradientEndColor = [UIColor colorWithRed:238.0/255.0 green:159.0/255.0 blue:7.0/255.0 alpha:1];
    self.totalBetLabel.shadowColor = nil;
    self.totalBetLabel.shadowOffset = CGSizeMake(0.0f, 2.0f);
    self.totalBetLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.75f];
    self.totalBetLabel.shadowBlur = 5.0f;
    
    self.singleBetLabel.gradientStartColor = [UIColor colorWithRed:187.0/255.0 green:252.0/255.0 blue:252.0/255.0 alpha:1];
    self.singleBetLabel.gradientEndColor = [UIColor colorWithRed:0 green:1 blue:1 alpha:1];
    self.singleBetLabel.shadowColor = nil;
    self.singleBetLabel.shadowOffset = CGSizeMake(0.0f, 2.0f);
    self.singleBetLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.75f];
    self.singleBetLabel.shadowBlur = 5.0f;
    
    self.cardTypeLabel.gradientStartColor = [UIColor colorWithRed:254.0/255.0 green:241.0/255.0 blue:67.0/255.0 alpha:1];
    self.cardTypeLabel.gradientEndColor = [UIColor colorWithRed:238.0/255.0 green:159.0/255.0 blue:7.0/255.0 alpha:1];
    self.cardTypeLabel.shadowColor = nil;
    self.cardTypeLabel.shadowOffset = CGSizeMake(0.0f, 2.0f);
    self.cardTypeLabel.shadowColor = [UIColor colorWithWhite:0.0f alpha:0.75f];
    self.cardTypeLabel.shadowBlur = 5.0f;

    self.totalBetNoteLabel.text = NSLS(@"kZJHTotalBet");
    self.singleBetNoteLabel.text = NSLS(@"kZJHSingleBet");
    
    [self.betButton setTitle:NSLS(@"kZJHBet") forState:UIControlStateNormal];
    [self.raiseBetButton setTitle:NSLS(@"kZJHRaise") forState:UIControlStateNormal];
    [self.autoBetButton setTitle:NSLS(@"kZJHAutoBet") forState:UIControlStateNormal];
    [self.checkCardButton setTitle:NSLS(@"kZJHCheck") forState:UIControlStateNormal];
    [self.compareCardButton setTitle:NSLS(@"kZJHCompare") forState:UIControlStateNormal];
    [self.foldCardButton setTitle:NSLS(@"kZJHFold") forState:UIControlStateNormal];
}

- (void)initMoneyTree
{
    self.moneyTreeView = [MoneyTreeView createMoneyTreeView];
    self.moneyTreeView.growthTime = [ConfigManager getTreeMatureTime];
    self.moneyTreeView.gainTime = [ConfigManager getTreeGainTime];
    self.moneyTreeView.coinValue = [ConfigManager getTreeCoinVale];
    self.moneyTreeView.delegate = self;
    [self.moneyTreeView startGrowing];
    [self.moneyTreeView showInView:self.moneyTreeHolder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.ruleConfig = [ZJHRuleConfigFactory createRuleConfig];
    _gameService.chipValues = [_ruleConfig chipValues];
    [_gameService syncAccount:self];
    [_gameService getAccount];

    // Do any additional setup after loading the view from its nib.
    
    // avatars.
    [self initAllAvatars];
    [self updateAllUsersAvatar];

    [self setImages];
    [self setBeautifulLabels];

    // room title.
    [RoomTitleView showRoomTitle:[_gameService getRoomName]inView:self.view];
    
    // dealer view.
    self.dealerView.delegate = self;
    
    // total bet and single bet.
    [self clearTotalBetAndSingleBet];
    
    // pokers and user bet.
    if ([_gameService isGamePlaying]) {
        [self updateAllUsersPokers];
        [self updateAllUserTotalBet];
        [self.betTable betSome:[_gameService.gameState totalBet] minSingleBet:((NSNumber*)[_gameService.chipValues objectAtIndex:0]).intValue];
        [self updateTotalBetAndSingleBet];
    }

    // money tree.
    [self initMoneyTree];
    
    // operation buttons.
    [self updateZJHButtons];
    
    // background music.
    [_audioManager setBackGroundMusicWithURL:[_soundManager gameBGM]];
    // waitting label
    [self updateWaitGameNoteLabel];
}

#define WAIT_GAME_NOTE_DISAPPEAR_DURATION (2.0)

- (void)updateWaitGameNoteLabel
{
    PPDebug(@"isMeStandy: %d", _gameService.session.isMeStandBy);
        PPDebug(@"[_gameService isGamePlaying]: %d", [_gameService isGamePlaying]);
    if (_gameService.session.isMeStandBy && [_gameService isGamePlaying]) {
        self.waitGameNoteLabel.hidden = YES;
        return;
    }
    
    if ([_gameService isGamePlaying]) {
        if (self.waitGameNoteLabel.hidden == YES) {
            return;
        }
        self.waitGameNoteLabel.text = NSLS(@"kGameBegin");
        
        [self.waitGameNoteLabel.layer addAnimation:[AnimationManager moveVerticalAnimationFrom:self.waitGameNoteLabel.center.y to:self.waitGameNoteLabel.center.y - ([DeviceDetection isIPAD] ? 100 : 50) duration:WAIT_GAME_NOTE_DISAPPEAR_DURATION] forKey:nil];
        
        [self.waitGameNoteLabel.layer addAnimation:[AnimationManager disappearAnimationWithDuration:WAIT_GAME_NOTE_DISAPPEAR_DURATION] forKey:nil];
        
        [self.waitGameNoteLabel performSelector:@selector(setHidden:) withObject:[NSNumber numberWithBool:YES] afterDelay:WAIT_GAME_NOTE_DISAPPEAR_DURATION];
    }else {
        self.waitGameNoteLabel.hidden = NO;
        
        if (_gameService.session.roundNumber == 0) {
            if ([_gameService.session.userList count] < 2) {
                if ([self.waitGameNoteLabel.text isEqualToString:NSLS(@"kWaitingForMoreUsers")]) {
                    return;
                }
                self.waitGameNoteLabel.text = NSLS(@"kWaitingForMoreUsers");
            }else {
                if ([self.waitGameNoteLabel.text isEqualToString:NSLS(@"kWaitingForStart")]) {
                    return;
                }
                self.waitGameNoteLabel.text = NSLS(@"kWaitingForStart");
            }
        }else {
            if ([self.waitGameNoteLabel.text isEqualToString:NSLS(@"kWaittingForNextTurn")]) {
                return;
            }
            self.waitGameNoteLabel.text = NSLS(@"kWaittingForNextTurn");
        }
        
        [self.waitGameNoteLabel.layer addAnimation:[AnimationManager appearAnimationFrom:0.7 to:1 duration:0.8] forKey:nil];
    }
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
                                        NSArray *cardIds = [[[CommonGameNetworkService userInfoToMessage:notification.userInfo] showCardRequest] cardIdsList];
                                       [self showCardSuccess:cardIds];
                                   }];
    
    [self registerNotificationWithName:NOTIFICATION_COMPARE_CARD_REQUEST
                                   usingBlock:^(NSNotification *notification) {

                                   }];
    
    [self registerNotificationWithName:NOTIFICATION_COMPARE_CARD_RESPONSE
                                   usingBlock:^(NSNotification *notification) {
                                       NSArray* userResultList = [[[CommonGameNetworkService userInfoToMessage:notification.userInfo] compareCardResponse] userResultList];
                                       NSString *userId = [[CommonGameNetworkService userInfoToMessage:notification.userInfo] userId];
                                       
                                       [self someoneCompareCard:userId resultList:userResultList];
                                   }];
    
    [self registerNotificationWithName:NOTIFICATION_CHANGE_CARD_REQUEST
                            usingBlock:^(NSNotification *notification) {
                                [self someoneChangeCard:[[CommonGameNetworkService userInfoToMessage:notification.userInfo] userId]];
                            }];
    
    [self registerNotificationWithName:NOTIFICATION_CHANGE_CARD_RESPONSE
                            usingBlock:^(NSNotification *notification) {
                                [self changeCardSuccess];
                            }];
    
    [self registerNotificationWithName:NOTIFICATION_BALANCE_UPDATED
                            usingBlock:^(NSNotification *notification) {
                                [self balanceUpdated];
                            }];
    
    [self registerNotificationWithName:NOTIFICAIION_CHAT_REQUEST
                            usingBlock:^(NSNotification *notification) {
                                GameMessage *message = [CommonGameNetworkService userInfoToMessage:notification.userInfo];
                                
                                if (message.chatRequest.contentType == 1) {
                                    [self someoneSendMessage:message.chatRequest.content
                                              contentVoiceId:message.chatRequest.contentVoiceId
                                                      userId:message.userId];
                                }else if (message.chatRequest.contentType == 2) {
                                    [self someoneSendExpression:message.chatRequest.expressionId
                                                         userId:message.userId];
                                }
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
    [self disableAllZJHButtons];
    [_gameService bet:autoBet];
}

- (IBAction)clickBetButton:(id)sender {
    [self bet:NO];
    [_audioManager playSoundByURL:_soundManager.clickButtonSound];
}

- (IBAction)clickRaiseBetButton:(id)sender
{
    [_popupViewManager popupChipsSelectViewAtView:sender
                                           inView:self.view
                                        aboveView:nil
                                         delegate:self];
    [_audioManager playSoundByURL:_soundManager.clickButtonSound];
}

- (IBAction)clickAutoBetButton:(id)sender
{
    self.autoBetButton.selected = !self.autoBetButton.selected;
    [_gameService setAutoBet:self.autoBetButton.selected];
    
    if ([_gameService isMeAutoBet] == YES && [_gameService isMyTurn]) {
        [self bet:YES];
    }
    [_audioManager playSoundByURL:_soundManager.clickButtonSound];
}

- (IBAction)clickCompareCardButton:(id)sender
{
    self.isComparing = YES;
    [self updateZJHButtons];
    [_audioManager playSoundByURL:_soundManager.clickButtonSound];
}

- (IBAction)clickCheckCardButton:(id)sender
{
    [_gameService checkCard];
    [_audioManager playSoundByURL:_soundManager.clickButtonSound];
}

- (IBAction)clickFoldCardButton:(id)sender
{
    [[self getMyAvatarView] stopReciprocal];
    [self disableAllZJHButtons];
    [_gameService foldCard];
    [_audioManager playSoundByURL:_soundManager.clickButtonSound];
}

- (IBAction)clickQuitButton:(id)sender
{
    if (![_gameService.session isMeStandBy] && ([_gameService.session isGamePlaying])) {
        CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kQuitGameAlertTitle")
                                                           message:NSLS(@"kZJHQuitGameAlertMessage")
                                                             style:CommonDialogStyleDoubleButton
                                                          delegate:nil
                                                             clickOkBlock:^{
                                                                 [_gameService quitGame];
                                                                 [self.navigationController popViewControllerAnimated:YES];
                                                                 [_audioManager playSoundByURL:_soundManager.clickButtonSound];
                                                             } clickCancelBlock:^{
                                                                 [_audioManager playSoundByURL:_soundManager.clickButtonSound];
                                                             }];
        [dialog showInView:self.view];
    } else {
        [_gameService quitGame];
        [self.navigationController popViewControllerAnimated:YES];
    }
    [_audioManager playSoundByURL:_soundManager.clickButtonSound];
}

- (IBAction)clickSettingButton:(id)sender
{
    [[CommonSettingView createSettingView] showInView:self.view];
    [_audioManager playSoundByURL:_soundManager.clickButtonSound];
}

#pragma mark - player action response

- (void)betSuccess
{
    [[self getMyAvatarView] stopReciprocal];
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
    
    [self.betTable someBetFrom:[self getPositionByUserId:_userManager.userId]
                     chipValue:_gameService.gameState.singleBet
                         count:[_gameService betCountOfUser:_userManager.userId]];
    
    [self updateTotalBetAndSingleBet];
    [self updateUserTotalBet:_userManager.userId];
    [[self getMyAvatarView] update];
}

- (void)checkCardSuccess
{
    [[self getMyPokersView] faceUpCardsWithCardType:nil
                                        xMotiontype:ZJHPokerXMotionTypeNone
                                          animation:YES];
    [self showMyCardType];
    
    BOOL gender = [_userManager.gender isEqualToString:@"m"];
    [_audioManager playSoundByURL:[_soundManager checkCardHumanSound:gender]];
    [_audioManager playSoundByURL:[_soundManager checkCardSoundEffect]];
    
    [self updateZJHButtons];
}

- (void)foldCardSuccess
{
    [[self getMyAvatarView] stopReciprocal];
    [[self getMyPokersView] foldCards:YES];
    [_audioManager playSoundByURL:_soundManager.foldCardSoundEffect];
    [_audioManager playSoundByURL:[_soundManager foldCardHumanSound:[@"m" isEqualToString:_userManager.gender]]];
}

- (void)showCardSuccess:(NSArray *)cardIds
{
    for (NSNumber *cardId in cardIds) {
        [[self getMyPokersView] setShowCardFlag:cardId.intValue animation:YES];
    }
    [self updateZJHButtons];
}


#pragma mark - service notification request

- (void)roomChanged
{
    [self updateAllUsersAvatar];
    [self updateWaitGameNoteLabel];
    
    for (NSString *userId in [_gameService.session.deletedUserList allKeys]) {
        [self hideTotalBetOfPosition:[self getPositionByUserId:userId]];
        [[self getPokersViewByUserId:userId] clear];
        [_gameService.gameState.usersInfo removeObjectForKey:userId];
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
    NSMutableArray* array = [[[NSMutableArray alloc] initWithCapacity:[_ruleConfig maxPlayerNum]] autorelease];
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
    PPDebug(@"########################### Game Start :%@ ####################", self.description);
    [self updateAllUsersAvatar];
    
    [self updateWaitGameNoteLabel];

    [self.dealerView dealWithPositionArray:[self dealPointsArray]
                                     times:CARDS_COUNT
                                isDualGame:[_gameService rule] == PBZJHRuleTypeDual];
    [self updateTotalBetAndSingleBet];
    [self updateAllUserTotalBet];
    
    for (PBGameUser *user in _gameService.session.userList) {
        [[self getAvatarViewByUserId:user.userId] updateByPBGameUser:[_gameService.session getUserByUserId:user.userId]];
    }
    
    [self allBet];
    
    [self coinAnimationFinished];
}

- (void)showAllUserGameResult
{
    for (NSString *userId in [_gameService.gameState.usersInfo allKeys]) {
        ZJHAvatarView *avatar = [self getAvatarViewByUserId:userId];
        if (avatar.userInfo == nil) {
            continue;
        }
        
        if ([userId isEqualToString:_gameService.winner]) {
            [avatar showWinCoins:[[_gameService userPlayInfo:userId] resultAward]];
        }else {
            [avatar showLoseCoins:[[_gameService userPlayInfo:userId] totalBet]];
        }
        
        [[self getAvatarViewByUserId:userId] updateByPBGameUser:[_gameService.session getUserByUserId:userId]];
    }
    
    [_gameService syncAccount:self];
    [_gameService getAccount];
}

- (void)gameOver
{
    [self updateZJHButtons];
    [self clearAllAvatarReciprocals];

    [self someoneWon:[_gameService winner]];

    [self faceupUserCards];
    [self performSelector:@selector(showAllUserGameResult) withObject:nil afterDelay:3.0];
    [self performSelector:@selector(resetGame) withObject:nil afterDelay:9.0];
    [_levelService addExp:10 delegate:self forSource:LevelSourceZhajinhua];
}

- (void)resetGame
{
    self.autoBetButton.selected = NO;
    [self hideMyCardType];
    [self clearAllUserPokers];
    [self hideAllUserTotalBet];
    [self updateWaitGameNoteLabel];
    [self clearTotalBetAndSingleBet];
}

- (void)faceupUserCards
{
    for (NSString *userId in [_gameService.gameState.usersInfo allKeys]) {
        if (_cardTypeLabel.hidden == YES) {
            [self showMyCardType];
        }
        NSString *cardType = [_userManager isMe:userId] ? nil : [_gameService cardTypeOfUser:userId];
        [[self getPokersViewByUserId:userId] faceUpCardsWithCardType:cardType xMotiontype:[self getPokerXMotionTypeByPosition:[self getPositionByUserId:userId]] animation:YES];
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
    [[self getAvatarViewByUserId:userId] updateByPBGameUser:[_gameService.session getUserByUserId:userId]];
}

- (void)someoneShowCard:(NSString*)userId cardIds:(NSArray *)cardIds
{
    for (NSNumber *cardId in cardIds) {
        [[self getPokersViewByPosition:[self getPositionByUserId:userId]] faceUpCard:cardId.intValue
                                                                           animation:YES];
    }
}

#define COMPARE_CARD_OFFSET  ([DeviceDetection isIPAD]?60:30)

- (void)showCompareCardResult:(NSArray*)resultList
                  initiatorId:(NSString*)initiatorId
{
    PBUserResult* result1 = [resultList objectAtIndex:0];
    PBUserResult* result2 = [resultList objectAtIndex:1];
    NSString *userId = initiatorId;
    NSString *targetUserId = [result1.userId isEqualToString:userId] ?result2.userId : result1.userId;
    BOOL didWin = [result1.userId isEqualToString:initiatorId] ? result1.win :result2.win;
    
    BOOL gender = [_gameService.session getUserByUserId:initiatorId].gender;
    [_audioManager playSoundByURL:[_soundManager compareCardHumanSound:gender]];
    [_audioManager playSoundByURL:[_soundManager compareCardSoundEffect]];
    
    ZJHPokerView* pokerView = [self getPokersViewByUserId:userId];
    ZJHPokerView* otherPokerView = [self getPokersViewByUserId:targetUserId];
    CGPoint pokerViewOrgPoint = pokerView.center;
    CGPoint otherPokerViewOrgPoint = otherPokerView.center;
    
    [UIView animateWithDuration:1 animations:^{
        pokerView.layer.position = CGPointMake(self.view.center.x, self.view.center.y - COMPARE_CARD_OFFSET);
        otherPokerView.layer.position = CGPointMake(self.view.center.x, self.view.center.y + COMPARE_CARD_OFFSET);
//        if ([_userManager isMe:userId]) {
//            pokerView.layer.transform = CATransform3DMakeScale(28/35.0, 37/48.0, 1);
//        }
//        if ([_userManager isMe:targetUserId]) {
//            otherPokerView.layer.transform = CATransform3DMakeScale(28/35.0, 37/48.0, 1);
//        }
        
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
                
                for (PBUserResult *result in resultList) {
                    [[self getAvatarViewByUserId:result.userId] showWinCoins:result.gainCoins];
                    [[self getAvatarViewByUserId:result.userId] updateByPBGameUser:[_gameService.session getUserByUserId:result.userId]];
                }
            }];
        }];
    }];
}

- (void)someoneCompareCard:(NSString*)initiatorId resultList:(NSArray *)resultList
{
    [self clearAllAvatarReciprocals];
    
    if (![_userManager isMe:initiatorId]) {
        [self popupCompareCardMessageAtUser:initiatorId];
    }
    
    if (resultList.count == 2 && !_isShowingComparing) {
        _isShowingComparing = YES;
        PBUserResult* result1 = [resultList objectAtIndex:0];
        PBUserResult* result2 = [resultList objectAtIndex:1];
        
        if ([result1.userId isEqualToString:_userManager.userId] || [result2.userId isEqualToString:_userManager.userId]) {
            [self disableCheckCardButtonAndFoldCardButton];
        }
        
        [self showCompareCardResult:resultList initiatorId:initiatorId];
    }
}

- (void)someoneChangeCard:(NSString *)userId
{
    PPDebug(@"########################### Someone Change Card :%@ ####################", [self getPokersViewByUserId:userId].description);

    ReplacedPoker *replacedPoker = [[_gameService replacedCardsOfUser:userId] lastObject];

    [[self getPokersViewByUserId:userId] changeCard:replacedPoker.oldPoker.pokerId toCard:replacedPoker.newPoker animation:YES];
}

- (void)changeCardSuccess
{
    ReplacedPoker *replacedPoker = [[_gameService myReplacedCards] lastObject];
    [[self getMyPokersView] changeCard:replacedPoker.oldPoker.pokerId toCard:replacedPoker.newPoker animation:YES];
    [self showMyCardType];
}

- (void)balanceUpdated
{
    for (PBGameUser *user in _gameService.session.userList) {
        [[self getAvatarViewByUserId:user.userId] updateByPBGameUser:user];
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
            
        case UserPositionCenterUp:
            return ZJHPokerSectorTypeCenterUp;
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
            
        case UserPositionCenterUp:
            return ZJHPokerXMotionTypeCenter;
            
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

- (void)fallCoins:(int)coinsNum
{
    _coinView = [[[FallingCoinView alloc]initWithFrame:self.view.frame withNum:coinsNum valuePerCoin:10] autorelease];
    _coinView.coindelegate = self;
    [self.view addSubview:_coinView];
    
}

- (void)someoneWon:(NSString*)userId
{
    if ([_userManager isMe:userId]) {
        [_audioManager playSoundByURL:[_soundManager gameWin]];
        [_audioManager playSoundByURL:[_soundManager fullMoney]];
        
        [self fallCoins:[[_gameService userPlayInfo:userId] resultAward]];
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
    for (ZJHUserPosInfo *userPosInfo in [_userPosInfoDic allValues]) {
        [userPosInfo.pokersView clearBomb];
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
    for (ZJHUserPosInfo *userPosInfo in [_userPosInfoDic allValues]) {
        [userPosInfo.avatar resetAvatar];
    }

    // set user on seat
    for (PBGameUser* user in _gameService.session.userList) {
        PPDebug(@"<ZJHGameController>Get user--%@, sitting at %d",user.nickName, user.seatId);
        
        UserPosition pos = [self getPositionByUserId:user.userId];
        [[[self getUserPosInfoByPos:pos] avatar] updateByPBGameUser:user];
        [[[self getUserPosInfoByPos:pos] avatar] setDelegate:self];
    }
}

- (void)updateAllUsersPokers
{
    for (PBGameUser *user in _gameService.session.userList) {

        ZJHUserPlayInfo *userPlayInfo = [_gameService userPlayInfo:user.userId];
        ZJHUserPosInfo *userPosInfo = [self getUserPosInfoByUserId:user.userId];
        ZJHPokerView *pokerView = userPosInfo.pokersView;
        
//        PPDebug(@"##############################################");
//        PPDebug(@"user: %@", [_gameService.session getNickNameByUserId:user.userId]);
//        PPDebug(@"already check card: %d", userPlayInfo.alreadCheckCard);
//        PPDebug(@"##############################################");
        [pokerView updateWithPokers:[_gameService pokersOfUser:user.userId]
                               size:userPosInfo.pokerSize
                                gap:userPosInfo.gap];
        
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

- (ZJHPokerView*)getMyPokersView
{
    return [[self getUserPosInfoByPos:UserPositionCenter] pokersView];
}

- (ZJHPokerView*)getPokersViewByPosition:(UserPosition)position
{
    return [[self getUserPosInfoByPos:position] pokersView];
}

- (ZJHAvatarView*)getAvatarViewByPosition:(UserPosition)position
{
    return [[self getUserPosInfoByPos:position] avatar];
}

- (UserPosition)getPositionByUserId:(NSString*)userId
{
    PBGameUser* user = [_gameService.session getUserByUserId:userId];
    PBGameUser* selfUser = [self getSelfUser];
    int seatIndex = ([_ruleConfig maxPlayerNum] + (user.seatId - selfUser.seatId))%[_ruleConfig maxPlayerNum];
    return [_ruleConfig positionBySeatIndex:seatIndex];
}

- (ZJHPokerView*)getPokersViewByUserId:(NSString*)userId
{
    return [[self getUserPosInfoByPos:[self getPositionByUserId:userId]] pokersView];
}

- (ZJHAvatarView*)getAvatarViewByUserId:(NSString*)userId
{
    return [[self getUserPosInfoByPos:[self getPositionByUserId:userId]] avatar];
}

- (ZJHMyAvatarView*)getMyAvatarView
{
    return (ZJHMyAvatarView*)[[self getUserPosInfoByPos:UserPositionCenter] avatar];
}

- (ZJHUserPosInfo *)getUserPosInfoByPos:(UserPosition)pos
{
    return [_userPosInfoDic valueForKey:[NSString stringWithFormat:@"%d", pos]];
}

- (ZJHUserPosInfo *)getUserPosInfoByUserId:(NSString *)userId
{
    for (ZJHUserPosInfo *userPosInfo in [_userPosInfoDic allValues]) {
        if ([userPosInfo.avatar.userInfo.userId isEqualToString:userId]) {
            return userPosInfo;
        }
    }
    return nil;
}

- (void)viewDidUnload {
    [self setBetTable:nil];
    [self setDealerView:nil];
    [self setBetButton:nil];
    [self setRaiseBetButton:nil];
    [self setAutoBetButton:nil];
    [self setCompareCardButton:nil];
    [self setCheckCardButton:nil];
    [self setFoldCardButton:nil];
    [self setTotalBetLabel:nil];
    [self setSingleBetLabel:nil];
    [self setVsImageView:nil];
    [self setGameBgImageView:nil];
    [self setTotalBetBgImageView:nil];
    [self setButtonsHolderBgImageView:nil];
    [self setRunawayButton:nil];
    [self setSettingButton:nil];
    [self setChatButton:nil];
    [self setTotalBetNoteLabel:nil];
    [self setSingleBetLabel:nil];
    [self setCardTypeLabel:nil];
    [self setRoomNameLabel:nil];
    [self setCardTypeBgImageView:nil];
    [self setCardTypeButton:nil];
    [self setWaitGameNoteLabel:nil];
    [self.moneyTreeView killMoneyTree];
    [self setMoneyTreeHolder:nil];
    [self setRightTopAvatar:nil];
    [self setRightAvatar:nil];
    [self setCenterAvatar:nil];
    [self setLeftAvatar:nil];
    [self setLeftTopAvatar:nil];
    [self setLeftTopPokers:nil];
    [self setRightTopPokers:nil];
    [self setLeftPokers:nil];
    [self setRightPokers:nil];
    [self setCenterPokers:nil];
    [self setCenterTotalBetBg:nil];
    [self setLeftTotalBetBg:nil];
    [self setRightTopTotalBetBg:nil];
    [self setRightTotalBetBg:nil];
    [self setLeftTopTotalBetBg:nil];
    [self setCenterTotalBet:nil];
    [self setLeftTotalBet:nil];
    [self setRightTotalBet:nil];
    [self setRightTopTotalBet:nil];
    [self setLeftTopTotalBet:nil];
    [self setCenterUpPokers:nil];
    [self setCenterUpTotalBetBg:nil];
    [self setCenterUpTotalBet:nil];
    [self setCenterUpAvatar:nil];
    [super viewDidUnload];
}

#pragma mark - ZJHAvatar delegate

- (void)didClickOnAvatar:(ZJHAvatarView*)view
{
    MyFriend *friend = [MyFriend friendWithFid:view.userInfo.userId
                                      nickName:nil
                                        avatar:nil
                                        gender:nil
                                         level:1];
    [CommonUserInfoView showFriend:friend
                      inController:self
                        needUpdate:YES
                           canChat:NO];
}

- (void)reciprocalEnd:(ZJHAvatarView*)view
{
    PPDebug(@"################# [controller: %@] TIME OUT: auto fold ##################", [self description]);
    if ([_userManager isMe:view.userInfo.userId])
    [self clickFoldCardButton:nil];
}

#pragma mark - poker view protocol

- (void)didClickPokerView:(PokerView *)pokerView
{
    [[self getMyPokersView] dismissButtons];
    pokerView.buttonsIsPopup ? [pokerView dismissButtons] : [pokerView popupButtons:[_ruleConfig createButtons:pokerView]  InView:self.view];
}

- (void)didClickShowCardButton:(PokerView *)pokerView
{
    PPDebug(@"didClickShowCardButton: card rank: %d, suit = %d", pokerView.poker.rank, pokerView.poker.suit);
    [_gameService showCard:pokerView.poker.pokerId];
}

- (void)didClickChangeCardButton:(PokerView *)pokerView
{
    PPDebug(@"didClickChangeCardButton: card rank: %d, suit = %d", pokerView.poker.rank, pokerView.poker.suit);
    [_gameService changeCard:pokerView.poker.pokerId];
}

- (void)didClickBombButton:(ZJHPokerView *)zjhPokerView
{
    __block ZJHUserPosInfo *userPosInfo = nil;
    [[_userPosInfoDic allValues] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([((ZJHUserPosInfo *)obj) pokersView] == zjhPokerView) {
            userPosInfo = (ZJHUserPosInfo *)obj;
            *stop = YES;
        }
    }];
    
    
//    ZJHAvatarView* avatar = (ZJHAvatarView*)[self.view viewWithTag:(AVATAR_VIEW_TAG_OFFSET+zjhPokerView.tag - POKERS_VIEW_TAG_OFFSET)];
    [[self getMyAvatarView] stopReciprocal];
    [self disableAllZJHButtons];
    [self compareToUser:userPosInfo.avatar.userInfo.userId];
}

#pragma mark - chipsSelectView protocol

- (void)didSelectChip:(int)chipValue
{
    [[self getMyAvatarView] stopReciprocal];
    [self disableAllZJHButtons];
    [_gameService raiseBet:chipValue];
}

- (void)dismissAllPopupView
{
    [[self getMyPokersView] dismissButtons];
    [_popupViewManager dismissChipsSelectView];
}

- (void)enableFoldCardButton
{
    self.foldCardButton.userInteractionEnabled = YES;
    [self.foldCardButton setTitleColor:TITLE_COLOR_WHEN_ENABLE forState:UIControlStateNormal];
    [self.foldCardButton setBackgroundImage:[_imageManager foldCardBtnBgImage] forState:UIControlStateNormal];
}


- (void)updateZJHButtons
{
    [_popupViewManager dismissChipsSelectView];
    
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
    
    self.compareCardButton.userInteractionEnabled = [_gameService canICompareCard] && !self.isComparing;
    [self.compareCardButton setTitleColor:(self.compareCardButton.userInteractionEnabled ? TITLE_COLOR_WHEN_ENABLE : TITLE_COLOR_WHEN_DISABLE) forState:UIControlStateNormal];
    [self.compareCardButton setBackgroundImage:(self.compareCardButton.userInteractionEnabled ? [_imageManager compareCardBtnBgImage] : [_imageManager compareCardBtnDisableBgImage]) forState:UIControlStateNormal];

    self.checkCardButton.userInteractionEnabled = [_gameService canICheckCard] && !self.dealerView.isDealing;
    [self.checkCardButton setTitleColor:(self.checkCardButton.userInteractionEnabled ? TITLE_COLOR_WHEN_ENABLE : TITLE_COLOR_WHEN_DISABLE) forState:UIControlStateNormal];
    [self.checkCardButton setBackgroundImage:(self.checkCardButton.userInteractionEnabled ? [_imageManager checkCardBtnBgImage] : [_imageManager checkCardBtnDisableBgImage]) forState:UIControlStateNormal];

    self.foldCardButton.userInteractionEnabled = [_gameService canIFoldCard] && !self.dealerView.isDealing;
    [self.foldCardButton setTitleColor:(self.foldCardButton.userInteractionEnabled ? TITLE_COLOR_WHEN_ENABLE : TITLE_COLOR_WHEN_DISABLE) forState:UIControlStateNormal];
    [self.foldCardButton setBackgroundImage:(self.foldCardButton.userInteractionEnabled ? [_imageManager foldCardBtnBgImage] : [_imageManager foldCardBtnDisableBgImage]) forState:UIControlStateNormal];
}

- (void)disableAllZJHButtons
{
    [self dismissAllPopupView];
    self.isComparing = NO;
   
    self.betButton.userInteractionEnabled = NO;
    [self.betButton setTitleColor:TITLE_COLOR_WHEN_DISABLE forState:UIControlStateNormal];
    [self.betButton setBackgroundImage:[_imageManager betBtnDisableBgImage] forState:UIControlStateNormal];
    
    self.raiseBetButton.userInteractionEnabled = NO;
    [self.raiseBetButton setTitleColor:TITLE_COLOR_WHEN_DISABLE forState:UIControlStateNormal];
    [self.raiseBetButton setBackgroundImage:[_imageManager raiseBetBtnDisableBgImage] forState:UIControlStateNormal];
    
    self.autoBetButton.userInteractionEnabled = NO;
    self.autoBetButton.selected = [_gameService isMeAutoBet];
    [self.autoBetButton setTitleColor:TITLE_COLOR_WHEN_DISABLE forState:UIControlStateNormal];
    [self.autoBetButton setBackgroundImage:[_imageManager autoBetBtnDisableBgImage] forState:UIControlStateNormal];
    
    self.compareCardButton.userInteractionEnabled = NO;
    [self.compareCardButton setTitleColor:TITLE_COLOR_WHEN_DISABLE forState:UIControlStateNormal];
    [self.compareCardButton setBackgroundImage:[_imageManager compareCardBtnDisableBgImage] forState:UIControlStateNormal];
    
    self.checkCardButton.userInteractionEnabled = NO;
    [self.checkCardButton setTitleColor:TITLE_COLOR_WHEN_DISABLE forState:UIControlStateNormal];
    [self.checkCardButton setBackgroundImage:[_imageManager checkCardBtnDisableBgImage] forState:UIControlStateNormal];
    
    self.foldCardButton.userInteractionEnabled = NO;
    [self.foldCardButton setTitleColor:TITLE_COLOR_WHEN_DISABLE forState:UIControlStateNormal];
    [self.foldCardButton setBackgroundImage:[_imageManager foldCardBtnDisableBgImage] forState:UIControlStateNormal];
}

- (void)disableCheckCardButtonAndFoldCardButton
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

- (void)showMyCardType
{
    if (![LocaleUtils supportChinese]) {
        return;
    }
    
    [self hideMyCardType];
    
    _cardTypeBgImageView.hidden = NO;
    
    CAAnimation * roateAni = [AnimationManager circlingAnimationWithDirection:AntiClockWise duration:1 repeatedCount:2];
    
    CAAnimation * caseInAni = [AnimationManager appearAnimationFrom:0.5 to:1 duration:1.0];
    
    CAAnimation * caseOutAni = [AnimationManager disappearAnimationWithDuration:1.0];
    caseOutAni.beginTime = 1.0;
        
    CAAnimationGroup* animGroup = [CAAnimationGroup animation];
    animGroup.removedOnCompletion = YES;
    animGroup.duration = 2;
    animGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animGroup.repeatCount = 1;
    animGroup.fillMode = kCAFillModeForwards;
    animGroup.animations = [NSArray arrayWithObjects:roateAni, caseInAni, caseOutAni, nil];

    [_cardTypeBgImageView.layer addAnimation:animGroup forKey:nil];
    
    [self performSelector:@selector(showMyCardTypeString) withObject:nil afterDelay:caseInAni.duration];
}

- (void)showMyCardTypeString
{
    _cardTypeBgImageView.hidden = YES;
    _cardTypeLabel.hidden = NO;
    _cardTypeButton.hidden = NO;
    _cardTypeLabel.text = [_gameService myCardTypeString];

    [_cardTypeLabel.layer addAnimation:[AnimationManager appearAnimationFrom:0.5 to:1.0 duration:0.5] forKey:nil];
}

- (void)hideMyCardType
{
    _cardTypeLabel.hidden = YES;
    _cardTypeButton.hidden = YES;
    _cardTypeBgImageView.hidden = YES;
}

- (void)clearAllUserPokers
{
    for (ZJHUserPosInfo *userPosInfo in [_userPosInfoDic allValues]) {
        [userPosInfo.pokersView clear];
    }
    
//    for (int i = UserPositionCenter; i < [_ruleConfig maxPlayerNum]; i ++){
//        [[self getPokersViewByPosition:i] clear];
//    }
}

- (void)clearAllAvatarReciprocals
{
    for (ZJHUserPosInfo *userPosInfo in [_userPosInfoDic allValues]) {
        [userPosInfo.avatar stopReciprocal];
    }
    
//    for (int i = UserPositionCenter; i < [_ruleConfig maxPlayerNum]; i ++){
//        [[self getAvatarViewByPosition:i] stopReciprocal];
//    }
}

#pragma mark - pravite methods, update bet.

- (void)updateTotalBetAndSingleBet
{
    self.totalBetLabel.text = [self int2String:_gameService.gameState.totalBet];
    self.singleBetLabel.text = [self int2String:_gameService.gameState.singleBet];
}

- (void)clearTotalBetAndSingleBet
{
    self.totalBetLabel.text = @"0";
    self.singleBetLabel.text = @"0";
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
    for (ZJHUserPosInfo *userPosInfo in [_userPosInfoDic allValues]) {
        userPosInfo.totalBetBg.hidden = YES;
        userPosInfo.totalBetLabel.hidden = YES;
    }
    
//    for (int pos = UserPositionCenter; pos < [_ruleConfig maxPlayerNum]; pos ++) {
//        [self hideTotalBetOfPosition:pos];
//    }
}

- (void)hideTotalBetOfPosition:(UserPosition)position
{
    [[self totalBetLabelOfPosition:position] setHidden:YES];
    [[self totalBetBgImageViewOfPosition:position] setHidden:YES];
}

- (UILabel *)totalBetLabelOfUser:(NSString *)userId
{
    return [[self getUserPosInfoByPos:[self getPositionByUserId:userId]] totalBetLabel];
}

- (UIImageView *)totalBetBgImageViewOfUser:(NSString *)userId
{
    return [[self getUserPosInfoByPos:[self getPositionByUserId:userId]] totalBetBg];
}

- (UILabel *)totalBetLabelOfPosition:(UserPosition)position
{
    return [[self getUserPosInfoByPos:position] totalBetLabel];
}

- (UIImageView *)totalBetBgImageViewOfPosition:(UserPosition)position
{
    return [[self getUserPosInfoByPos:position] totalBetBg];
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

- (void)popupActionMessageView:(UIView *)view
                    atPosition:(UserPosition)position
{
    CGPoint point = [ZJHScreenConfig getActionMessageViewOriginByPosition:position];
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

- (void)popupChatMessageView:(UIView *)view
                  atPosition:(UserPosition)position
{
    CGPoint point = [ZJHScreenConfig getChatMessageViewOriginByPosition:position];
    if (position == UserPositionCenter) {
        point.y -= view.frame.size.height;
    }else if (position == UserPositionRight || position == UserPositionRightTop){
        point.x -= view.frame.size.width;
    }
    
    view.frame = CGRectMake(point.x, point.y, view.frame.size.width, view.frame.size.height);
    [self.view addSubview:view];
    
    [UIView animateWithDuration:0.3 animations:^{
        view.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.5 delay:0.5 options:UIViewAnimationCurveEaseInOut animations:^{
            view.alpha = 1;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:1.0 delay:2.0 options:UIViewAnimationCurveEaseInOut animations:^{
                view.alpha = 0;
            } completion:^(BOOL finished) {
                [view removeFromSuperview];
            }];
        }];
    }];
}

- (void)popupChatMessageAtUser:(NSString *)userId
                       message:(NSString *)message
{
    UserPosition pos = [self getPositionByUserId:userId];
    
    MessageView *view = [MessageView chatMessageViewWithMessage:message font:ACTION_LABEL_FONT textColor:[UIColor whiteColor] textAlignment:UITextAlignmentLeft bgImage:[_imageManager chatMesssgeBgImage:pos] pos:pos];
    
    [self popupChatMessageView:view atPosition:[self getPositionByUserId:userId]];
}

- (void)popupBetMessageAtUser:(NSString *)userId
{
    UserPosition pos = [self getPositionByUserId:userId];
    
    MessageView *view = [MessageView actionMessageViewWithMessage:NSLS(@"kZJHBet") font:ACTION_LABEL_FONT textColor:[UIColor blackColor] textAlignment:UITextAlignmentCenter bgImage:[_imageManager betActionImage:pos]];
    
    [self popupActionMessageView:view atPosition:[self getPositionByUserId:userId]];
}

- (void)popupRaiseBetMessageAtUser:(NSString *)userId
{
    UserPosition pos = [self getPositionByUserId:userId];
    
    MessageView *view = [MessageView actionMessageViewWithMessage:NSLS(@"kZJHRaise") font:ACTION_LABEL_FONT textColor:[UIColor blackColor]textAlignment:UITextAlignmentCenter bgImage:[_imageManager raiseBetActionImage:pos]];
    
    [self popupActionMessageView:view atPosition:[self getPositionByUserId:userId]];
}

- (void)popupCheckCardMessageAtUser:(NSString *)userId
{
    UserPosition pos = [self getPositionByUserId:userId];

    MessageView *view = [MessageView actionMessageViewWithMessage:NSLS(@"kZJHCheck") font:ACTION_LABEL_FONT textColor:[UIColor blackColor]textAlignment:UITextAlignmentCenter bgImage:[_imageManager checkCardActionImage:pos]];
    
    [self popupActionMessageView:view atPosition:[self getPositionByUserId:userId]];
}

- (void)popupCompareCardMessageAtUser:(NSString *)userId
{
    UserPosition pos = [self getPositionByUserId:userId];
    MessageView *view = [MessageView actionMessageViewWithMessage:NSLS(@"kZJHCompare") font:ACTION_LABEL_FONT textColor:[UIColor blackColor]textAlignment:UITextAlignmentCenter bgImage:[_imageManager compareCardActionImage:pos]];
    
    [self popupActionMessageView:view atPosition:[self getPositionByUserId:userId]];
}

- (void)popupFoldCardMessageAtUser:(NSString *)userId
{
    UserPosition pos = [self getPositionByUserId:userId];
    MessageView *view = [MessageView actionMessageViewWithMessage:NSLS(@"kZJHFold") font:ACTION_LABEL_FONT textColor:[UIColor blackColor]textAlignment:UITextAlignmentCenter bgImage:[_imageManager foldCardActionImage:pos]];
    
    [self popupActionMessageView:view atPosition:[self getPositionByUserId:userId]];
}

- (IBAction)clickMyCardTypeButton:(id)sender {
    [_popupViewManager popupCardTypesWithCardType:[_gameService myCardType] atView:[self getMyPokersView] inView:self.view];
}

#pragma mark - money tree view delegate
- (void)didGainMoney:(int)money fromTree:(MoneyTreeView *)treeView
{
    [_gameService chargeAccount:money source:MoneyTreeAward];
    [[self getMyAvatarView] update];
}

- (void)didSyncFinish
{
    [[self getMyAvatarView] update]; 
}


- (void)coinAnimationFinished
{
    _coinView = nil;
}

- (IBAction)clickChatButton:(id)sender {
    if (self.chatView == nil) {
        self.chatView = [ChatView createChatView];
        [_chatView loadContent];
        _chatView.delegate = self;
    }
    
    [_chatView popupAtView:[self getMyAvatarView]
                   inView:self.view
             aboveSubView:nil
                 animated:YES
           pointDirection:PointDirectionAuto];
}

- (void)didClickCloseButton
{
    [self.chatView dismissAnimated:YES];
}

- (void)didClickExepression:(NSString *)key
{
    [self.chatView dismissAnimated:YES];
    [[self getMyAvatarView] showExpression:key];
    [_gameService chatWithExpression:key];
}


- (void)didClickMessage:(CommonChatMessage *)message
{
    [self.chatView dismissAnimated:YES];
    
    if ([message.content length] == 0) {
        return;
    }
    
    [self popupChatMessageAtUser:_userManager.userId message:message.content];
    [_gameService chatWithContent:message.content contentVoiceId:[NSString stringWithFormat:@"%d", message.voiceId]];
}

- (void)someoneSendMessage:(NSString *)content
            contentVoiceId:(NSString *)contentVoiceId
                    userId:(NSString *)userId
{
    [self popupChatMessageAtUser:userId message:content];
}

- (void)someoneSendExpression:(NSString *)key
                       userId:(NSString *)userId
{
    ZJHAvatarView *avatar = [self getAvatarViewByUserId:userId];
    [avatar showExpression:key];
}

@end
