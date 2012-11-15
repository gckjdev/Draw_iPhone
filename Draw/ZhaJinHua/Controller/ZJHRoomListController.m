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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.fastEntryButton setRoyButtonWithColor:[UIColor redColor]];
    [self.createRoomButton setRoyButtonWithColor:[UIColor yellowColor]];
    // Do any additional setup after loading the view from its nib.
}

- (NSString*)title
{
    return NSLS(@"kZJHRoomTitle");
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

- (CGPoint)searchViewPoint
{
    return CGPointMake(self.view.center.x, self.friendRoomButton.center.y);
}
- (void)updateOnlineUserCount
{
    NSString* userCount = [NSString stringWithFormat:NSLS(@"kOnlineUser"),[_gameService onlineUserCount]];
    [self.titleFontButton setTitle:[NSString stringWithFormat:@"%@(%@)",[self title], userCount] forState:UIControlStateNormal];
}
- (void)enterGame
{
    ZJHGameController* vc = [[[ZJHGameController alloc] init] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
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
- (JoinGameErrorCode)meetJoinGameCondition
{
    return JoinGameSuccess;
}
- (void)handleJoinGameError:(JoinGameErrorCode)errorCode
{
    
}

- (void)updateRoomList
{
    self.emptyListTips.hidden = YES;
}

- (void)connectServerSuccessfully
{
    self.fastEntryButton.enabled = YES;
    self.createRoomButton.enabled = YES;
}

@end
