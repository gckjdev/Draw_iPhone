//
//  RoomListController.m
//  Draw
//
//  Created by 小涛 王 on 12-7-27.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceRoomListController.h"
#import "DiceImageManager.h"
#import "DiceRoomListCell.h"
#import "CommonGameNetworkClient.h"
#import "UserManager+DiceUserManager.h"
#import "NotificationName.h"
#import "DiceGameService.h"
#import "DiceNotification.h"
#import "GameMessage.pb.h"
#import "DiceGamePlayController.h"
#import "GameConstants.pb.h"
#import "CommonMessageCenter.h"
#import "DiceColorManager.h"
#import "AccountService.h"
#import "ConfigManager.h"
#import "CoinShopController.h"
#import "LmWallService.h"
#import "DiceUserInfoView.h"
#import "PPResourceService.h"
#import "FXLabel.h"

#define KEY_GAME_MESSAGE @"KEY_GAME_MESSAGE"
#define ROOMS_COUNT_PER_PAGE  20

#define REFRESH_ROOMS_TIME_INTERVAL 2

#define CREATE_ROOM_DIALOG_TAG  120120824
#define ENTER_ROOM_DIALOG_TAG   220120824



@interface DiceRoomListController ()
{
    AccountService *_accountService;
    DiceGameRuleType _ruleType;
}

@end

@implementation DiceRoomListController

#pragma mark - Life cycle

- (id)initWithRuleType:(DiceGameRuleType)ruleType
{
    self = [super init];
    if (self) {
        firstLoad = YES;
        _ruleType = ruleType;
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"CommonRoomListController" bundle:nibBundleOrNil];
    if (self) {
        _gameService = [DiceGameService defaultService];
        _diceGameService = [DiceGameService defaultService];

    }
    return self;
}


- (void)dealloc {
    [super dealloc];
}

- (void)joinGame
{
    [self hideActivity];
    DiceGamePlayController *controller = [[[DiceGamePlayController alloc] init] autorelease];
    [self.navigationController pushViewController:controller animated:YES];

}

- (void)registerDiceRoomNotification
{
    [self registerNotificationWithName:NOTIFICAIION_CREATE_ROOM_RESPONSE
                            usingBlock:^(NSNotification *note) {
        PPDebug(@"<DiceRoomListController> NOTIFICAIION_CREATE_ROOM_RESPONSE"); 
        [self hideActivity];
        GameMessage* message = [CommonGameNetworkService userInfoToMessage:note.userInfo];
        if (message.resultCode == GameResultCodeSuccess) {
            [self joinGame];
        } else if (message.resultCode == GameResultCodeErrorSessionNameDuplicated) {
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kRoomNameDuplicated") delayTime:2 isHappy:NO];
        }else {
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kJoinGameFailure") delayTime:1.5 isHappy:NO];
        }
    }];


}

- (void)handleUpdateOnlineUserCount
{
    
}

- (void)unregisterDiceRoomNotification
{
    [self unregisterAllNotifications];                                               
}

- (NSString *)title
{
    NSString *title = nil;
    switch (_ruleType) {
        case DiceGameRuleTypeRuleNormal:
            title = NSLS(@"kDiceMenuHappyRoom");
            break;
            
        case DiceGameRuleTypeRuleHigh:
            title = NSLS(@"kDiceMenuHighRoom");
            break;
            
        case DiceGameRuleTypeRuleSuperHigh:
            title = NSLS(@"kDiceMenuSuperHighRoom");
            break;     
            
        default:
            break;
    }
    
    return title;
}

- (UIImage *)bgImage
{
    switch (_ruleType) {
        case DiceGameRuleTypeRuleNormal:
            return [[DiceImageManager defaultManager] diceNormalRoomListBgImage];
            break;
            
        case DiceGameRuleTypeRuleHigh:
            return [[DiceImageManager defaultManager] diceHighRoomListBgImage];
            break;
            
        case DiceGameRuleTypeRuleSuperHigh:
            return [[DiceImageManager defaultManager] diceSuperHighRoomListBgImage];
            break;
            
        default:
            return nil;
            break;
    }
}

- (void)initLabels
{
    [self.titleLabel setGradientStartColor:[UIColor colorWithRed:52/255.0 green:30/255.0 blue:10/255.0 alpha:1.0]];
    [self.titleLabel setGradientEndColor:[UIColor colorWithRed:88/255.0 green:56/255.0 blue:22/255.0 alpha:1.0]];
    [self.titleLabel setShadowColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.48]];
    [self.titleLabel setShadowOffset:CGSizeMake(-0.5, 0.5)];
    
    [self.leftTabButton setTitleColor:[UIColor colorWithRed:62/255.0 green:43/255.0 blue:23/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.leftTabButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.leftTabButton setTitleShadowColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.48] forState:UIControlStateNormal];
    [self.leftTabButton setTitleShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.68] forState:UIControlStateSelected];
    [self.leftTabButton.titleLabel setShadowOffset:CGSizeMake(-0.5, 0.5)];
    [self.rightTabButton setTitleColor:[UIColor colorWithRed:62/255.0 green:43/255.0 blue:23/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.rightTabButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.rightTabButton setTitleShadowColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.48] forState:UIControlStateNormal];
    [self.rightTabButton setTitleShadowColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.68] forState:UIControlStateSelected];
    [self.rightTabButton.titleLabel setShadowOffset:CGSizeMake(-0.5, 0.5)];
    
    [self.fastEntryButton setTitleColor:[UIColor colorWithRed:62/255.0 green:43/255.0 blue:23/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.fastEntryButton setTitleShadowColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.48] forState:UIControlStateNormal];
    [self.fastEntryButton.titleLabel setShadowOffset:CGSizeMake(-0.5, 0.5)];
    [self.createRoomButton setTitleColor:[UIColor colorWithRed:62/255.0 green:43/255.0 blue:23/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.createRoomButton setTitleShadowColor:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.48] forState:UIControlStateNormal];
    [self.createRoomButton.titleLabel setShadowOffset:CGSizeMake(-0.5, 0.5)];
    
    [self.emptyListTips setTextColor:[UIColor colorWithRed:62/255.0 green:43/255.0 blue:23/255.0 alpha:1.0]];
    [self.emptyListTips setShadowOffset:CGSizeMake(-0.5, 0.5)];
    [self.emptyListTips setShadowColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:0.48]];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.rightTabButton setTitle:NSLS(@"kFriend") forState:UIControlStateNormal];
    [self.leftTabButton setTitle:NSLS(@"kAll") forState:UIControlStateNormal];
    [self.titleLabel setText:[self title]];
    [self hideCenterTabButton];
    [self initLabels];
    
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [self registerDiceRoomNotification];    
    [super viewDidAppear:animated];    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self unregisterDiceRoomNotification];
    [super viewDidDisappear:animated];
}

#pragma mark - TableView delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [DiceRoomListCell getCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DiceRoomListCell *cell = [tableView dequeueReusableCellWithIdentifier:[DiceRoomListCell getCellIdentifier]];
    if (cell == nil) {
        cell = [DiceRoomListCell createCell:[DiceRoomListCell getCellIdentifier]];
    }
    PBGameSession* session = [[DiceGameService defaultService].roomList objectAtIndex:indexPath.row];
    [cell setCellInfo:session ruleType:_ruleType];
    cell.delegate = self;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [DiceGameService defaultService].roomList.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    self.currentSession = [[DiceGameService defaultService] sessionInRoom:indexPath.row];
    if (self.currentSession.password == nil 
        || self.currentSession.password.length <= 0 
        || [[UserManager defaultManager] isMe:self.currentSession.createBy]) 
    {
        [self checkAndJoinGame:self.currentSession.sessionId];
    } else {
        InputDialog *inputDialog = [InputDialog dialogWith:NSLS(@"kPassword") 
                                                  delegate:self];
        inputDialog.targetTextField.text = nil;
        inputDialog.targetTextField.placeholder = NSLS(@"kEnterPassword");
        [inputDialog showInView:self.view]; 
        inputDialog.tag = ENTER_ROOM_DIALOG_TAG;
    }
    
    
}

#pragma mark - Button action


- (void)showCoinsNotEnoughView
{
    CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kNotEnoughCoin") message:[DiceConfigManager coinsNotEnoughNoteWithRuleType:_diceGameService.ruleType] style:CommonDialogStyleDoubleButton delegate:self];
    [dialog showInView:self.view];
}


- (IBAction)clickHelpButton:(id)sender {
//    if (!helpButton.selected) {
//        helpButton.selected = YES;
//        HelpView *view = [HelpView createHelpView:@"DiceHelpView"];
//        view.delegate = self;
//        [view showInView:self.view];
//    }
}

- (void)didHelpViewHide
{
//    helpButton.selected = NO;
}

#pragma mark - common dialog delegate
- (void)clickOk:(CommonDialog *)dialog
{
    if ([ConfigManager wallEnabled]) {
        [self showWall];
    }else {
        CoinShopController* controller = [[[CoinShopController alloc] init] autorelease];
        [self.navigationController pushViewController:controller animated:YES]; 
    }
}

- (void)clickBack:(CommonDialog *)dialog
{
    
}

- (void)showWall
{        
    [UIUtils alertWithTitle:@"免费金币获取提示" msg:@"下载免费应用即可获取金币！下载完应用一定要打开才可以获得奖励哦！"];
    [[LmWallService defaultService] show:self];
}

#pragma mark - common room list delegate


- (void)handleDidJoinGame
{
    [self hideActivity];
    [self joinGame];
    
}
- (PrejoinGameErrorCode)handlePrejoinGameCheck
{
    return canJoinGame;
}
- (PrejoinGameErrorCode)handlePrejoinGameCheckBySessionId:(int)sessionId
{
    return canJoinGame;
}
- (void)handleJoinGameError:(PrejoinGameErrorCode)errorCode
{
    
}
- (void)handleUpdateRoomList
{
    self.emptyListTips.hidden = YES;
}
- (void)handleDidConnectServer
{
    [self hideActivity];
    self.fastEntryButton.enabled = YES;
    self.createRoomButton.enabled = YES;
}

- (void)handleNoRoomMessage
{
    self.emptyListTips.hidden = NO;
    if (_currentRoomType == CommonRoomFilterFriendRoom) {
        [self.emptyListTips setText:NSLS(@"kNoFriendRoom")];
    }
    if (_searchView) {
        [self.emptyListTips setText:NSLS(@"kSearchEmpty")];
    }
}


- (void)didQueryUser:(NSString *)userId
{
    [self hideActivity];
    MyFriend *friend = [MyFriend friendWithFid:userId
                                      nickName:nil
                                        avatar:nil
                                        gender:nil
                                         level:1];
    [DiceUserInfoView showFriend:friend infoInView:self canChat:NO needUpdate:YES];
    return;
}

- (void)handleLeftTabAction
{
    [self refreshRoomsByFilter:CommonRoomFilterAllRoom];
    [self continueRefreshingRooms];
    [self showActivityWithText:NSLS(@"kRefreshingRoomList")];
}
- (void)handleRightTabAction
{
    [self refreshRoomsByFilter:CommonRoomFilterFriendRoom];
    [self pauseRefreshingRooms];
    [self showActivityWithText:NSLS(@"kSearchingRoom")];
}


@end
