//
//  ZJHRoomListController.m
//  Draw
//
//  Created by Kira on 12-11-14.
//
//

#import "ZJHRoomListController.h"
#import "ZJHGameService.h"
#import "ZJHRoomListCell.h"
#import "UserManager.h"
#import "ZJHGameController.h"
#import "DiceColorManager.h"
#import "ZJHUserInfoView.h"
#import "ZJHRuleConfigFactory.h"

#define BUTTON_FONT_SIZE ([DeviceDetection isIPAD] ? 40 : 20)

@interface ZJHRoomListController ()

@property (retain, nonatomic) ZJHRuleConfig *ruleConfig;

@end

@implementation ZJHRoomListController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        _gameService = [ZJHGameService defaultService];
    }
    return self;
}

- (void)initButtons
{
    [self.leftTabButton setTitle:NSLS(@"kAll") forState:UIControlStateNormal];
    [self.rightTabButton setTitle:NSLS(@"kFriend") forState:UIControlStateNormal];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.ruleConfig = [ZJHRuleConfigFactory createRuleConfig];

    [self initButtons];
    
    [self handleUpdateOnlineUserCount];

    
    // Do any additional setup after loading the view from its nib.
}

- (NSString*)title
{
    return [_ruleConfig getRoomListTitle];
}

#pragma mark - TableView delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ZJHRoomListCell getCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    ZJHRoomListCell *cell = [tableView dequeueReusableCellWithIdentifier:[ZJHRoomListCell getCellIdentifier]];
    if (cell == nil) {
        cell = [ZJHRoomListCell createCell:[ZJHRoomListCell getCellIdentifier]];
    }
    PBGameSession* session = [[_gameService roomList] objectAtIndex:indexPath.row];
    [cell setCellInfo:session roomListTitile:[_ruleConfig getRoomListTitle]];
    cell.delegate = self;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[_gameService roomList] count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    self.currentSession = [_gameService sessionInRoom:indexPath.row];
    if (self.currentSession.password == nil
        || self.currentSession.password.length <= 0
        || [[UserManager defaultManager] isMe:self.currentSession.createBy])
    {
        [self checkAndJoinGame:self.currentSession.sessionId];
    } else {
        [self showPasswordDialog];
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGPoint)getSearchViewPosition
{
    return CGPointMake(self.view.center.x, self.rightTabButton.center.y);
}
- (void)handleUpdateOnlineUserCount
{
    NSString* userCount = [NSString stringWithFormat:NSLS(@"kOnlineUser"),[_gameService onlineUserCount]];
    [self.titleFontButton setTitle:[NSString stringWithFormat:@"%@(%@)",[self title], userCount] forState:UIControlStateNormal];
}
- (void)handleDidJoinGame
{
    ZJHGameController* vc = nil;
    NSString *xibName = nil;
    switch ([DeviceDetection deviceScreenType]) {
        case DEVICE_SCREEN_IPAD:
        case DEVICE_SCREEN_NEW_IPAD:
            xibName = ([_gameService rule] == PBZJHRuleTypeDual) ? @"ZJHGameController_dual~ipad" : @"ZJHGameController~ipad";
            vc = [[[ZJHGameController alloc] initWithNibName:xibName bundle:[NSBundle mainBundle]] autorelease];
            break;
            
        case DEVICE_SCREEN_IPHONE5:
            xibName = ([_gameService rule] == PBZJHRuleTypeDual) ? @"ZJHGameController_dual~ip5" : @"ZJHGameController~ip5";
            vc = [[[ZJHGameController alloc] initWithNibName:xibName bundle:[NSBundle mainBundle]] autorelease];
            break;
            
        case DEVICE_SCREEN_IPHONE:
            xibName = ([_gameService rule] == PBZJHRuleTypeDual) ? @"ZJHGameController_dual" : @"ZJHGameController";
            vc = [[[ZJHGameController alloc] initWithNibName:xibName bundle:[NSBundle mainBundle]] autorelease];
            break;
            
        default:
            break;
    }
    
    [self.navigationController pushViewController:vc
                                         animated:YES];
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

- (void)dealloc {
    [_ruleConfig release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setBackgroundImageView:nil];
    [super viewDidUnload];
}

- (void)didQueryUser:(NSString *)userId
{
    MyFriend *friend = [MyFriend friendWithFid:userId
                                      nickName:nil
                                        avatar:nil
                                        gender:nil
                                         level:1];
    [ZJHUserInfoView showFriend:friend inController:self needUpdate:YES canChat:YES];
    return;
}

- (IBAction)clickAll:(id)sender
{
    [self.leftTabButton setSelected:YES];
    [self.rightTabButton setSelected:NO];
    [self.centerTabButton setSelected:NO];
    [self refreshRoomsByFilter:CommonRoomFilterAllRoom];
    [self continueRefreshingRooms];
    [self showActivityWithText:NSLS(@"kRefreshingRoomList")];
}
- (IBAction)clickFriendRoom:(id)sender
{
    [self.leftTabButton setSelected:NO];
    [self.rightTabButton setSelected:YES];
    [self.centerTabButton setSelected:NO];
    [self refreshRoomsByFilter:CommonRoomFilterFriendRoom];
    [self pauseRefreshingRooms];
    [self showActivityWithText:NSLS(@"kSearchingRoom")];
}
- (IBAction)clickNearBy:(id)sender
{
    [self.leftTabButton setSelected:NO];
    [self.rightTabButton setSelected:NO];
    [self.centerTabButton setSelected:YES];
    [self refreshRoomsByFilter:CommonRoomFilterNearByRoom];
}
@end
