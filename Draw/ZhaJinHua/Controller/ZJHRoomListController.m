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

#define BUTTON_FONT_SIZE ([DeviceDetection isIPAD] ? 40 : 20)

@interface ZJHRoomListController ()

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
    [self.createRoomButton setRoyButtonWithColor:[DiceColorManager dialoggreenColor]];
    [self.createRoomButton.titleLabel setFont:[UIFont systemFontOfSize:BUTTON_FONT_SIZE]];
    [self.createRoomButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    
    [self.fastEntryButton setRoyButtonWithColor:[DiceColorManager dialogYellowColor]];
    [self.fastEntryButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    [self.fastEntryButton.titleLabel setFont:[UIFont systemFontOfSize:BUTTON_FONT_SIZE]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initButtons];
    [self.backgroundImageView setImage:[ZJHImageManager defaultManager].roomBackgroundImage];
    // Do any additional setup after loading the view from its nib.
}

- (NSString*)title
{
    return NSLS(@"kZJHGameTitle");
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
    PBGameSession* session = [_gameService.roomList objectAtIndex:indexPath.row];
    [cell setCellInfo:session];
    cell.delegate = self;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _gameService.roomList.count;
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
    return CGPointMake(self.view.center.x, self.friendRoomButton.center.y);
}
- (void)handleUpdateOnlineUserCount
{
    NSString* userCount = [NSString stringWithFormat:NSLS(@"kOnlineUser"),[_gameService onlineUserCount]];
    [self.titleFontButton setTitle:[NSString stringWithFormat:@"%@(%@)",[self title], userCount] forState:UIControlStateNormal];
}
- (void)handleDidJoinGame
{
    ZJHGameController* vc = nil;
    switch ([DeviceDetection deviceScreenType]) {
        case DEVICE_SCREEN_IPAD:
        case DEVICE_SCREEN_NEW_IPAD:
            vc = [[[ZJHGameController alloc] initWithNibName:@"ZJHGameController~ipad" bundle:[NSBundle mainBundle]] autorelease];
            break;
            
        case DEVICE_SCREEN_IPHONE5:
            vc = [[[ZJHGameController alloc] initWithNibName:@"ZJHGameController~ip5" bundle:[NSBundle mainBundle]] autorelease];
            break;
            
        case DEVICE_SCREEN_IPHONE:
            vc = [[[ZJHGameController alloc] initWithNibName:@"ZJHGameController" bundle:[NSBundle mainBundle]] autorelease];
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
    [_backgroundImageView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setBackgroundImageView:nil];
    [super viewDidUnload];
}

- (void)didQueryUser:(NSString *)userId
{
    return;
}
@end
