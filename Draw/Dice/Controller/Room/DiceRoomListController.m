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
#import "UserManager.h"
#import "NotificationName.h"
#import "DiceGameService.h"
#import "DiceNotification.h"
#import "GameMessage.pb.h"
#import "DiceGamePlayController.h"
#import "FontButton.h"

#define KEY_GAME_MESSAGE @"KEY_GAME_MESSAGE"

@interface DiceRoomListController ()

@end

@implementation DiceRoomListController

#pragma mark - Life cycle
@synthesize titleFontButton;
@synthesize createRoomButton;
@synthesize fastEntryButton;
@synthesize allRoomButton;
@synthesize friendRoomButton;
@synthesize nearByRoomButton;

- (void)dealloc {
    [createRoomButton release];
    [fastEntryButton release];
    [titleFontButton release];
    [allRoomButton release];
    [friendRoomButton release];
    [nearByRoomButton release];
    [super dealloc];
}

- (void)registerDiceRoomNotification
{
    [[NSNotificationCenter defaultCenter] 
     addObserverForName:NOTIFICAIION_CREATE_ROOM_RESPONSE
     object:nil     
     queue:[NSOperationQueue mainQueue]     
     usingBlock:^(NSNotification *notification) {                       
         PPDebug(@"<DiceRoomListController> NOTIFICAIION_CREATE_ROOM_RESPONSE"); 
         if(_isJoiningDice) {
             DiceGamePlayController *controller = [[[DiceGamePlayController alloc] init] autorelease];
             [self.navigationController pushViewController:controller animated:YES];
             _isJoiningDice = NO; 
         }
     }];
    
    [[NSNotificationCenter defaultCenter] 
     addObserverForName:NOTIFICAIION_GET_ROOMS_RESPONSE
     object:nil     
     queue:[NSOperationQueue mainQueue]     
     usingBlock:^(NSNotification *notification) {                       
         PPDebug(@"<DiceRoomListController> NOTIFICAIION_GET_ROOMS_RESPONSE");  
         CommonGameNetworkService* service = [DiceGameService defaultService];
         self.dataList = [NSArray arrayWithArray:service.roomList];
         [self.dataTableView reloadData];
     }];
    [[NSNotificationCenter defaultCenter] 
     addObserverForName:NOTIFICATION_JOIN_GAME_RESPONSE
     object:nil     
     queue:[NSOperationQueue mainQueue]     
     usingBlock:^(NSNotification *notification) {                       
         PPDebug(@"<DiceRoomListController> NOTIFICATION_JOIN_GAME_RESPONSE"); 
         if(_isJoiningDice) {
             DiceGamePlayController *controller = [[[DiceGamePlayController alloc] init] autorelease];
             [self.navigationController pushViewController:controller animated:YES];
             _isJoiningDice = NO; 
         }
     }];
    
    [[NSNotificationCenter defaultCenter] 
     addObserverForName:NOTIFICATION_ROOM
     object:nil     
     queue:[NSOperationQueue mainQueue]     
     usingBlock:^(NSNotification *notification) {                       
         PPDebug(@"<DiceRoomListController> NOTIFICATION_ROOM"); 
         if ([DiceGameService defaultService].roomList.count <= 0) {
             [[DiceGameService defaultService] getRoomList:0 count:10];
         }
     }];
}

- (void)unregisterDiceRoomNotification
{
    [notifications enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        //        if ([obj isKindOfClass:[NSNotification class]]) {
        NSNotification *notification = (NSNotification *)obj;
        [[NSNotificationCenter defaultCenter] removeObserver:notification];
        //        }
        
    }];    
    
    [notifications removeAllObjects];                                                
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[[DiceImageManager defaultManager] roomListBgImage]];
    
    [createRoomButton setBackgroundImage:[[DiceImageManager defaultManager] createRoomBtnBgImage] forState:UIControlStateNormal];
    
    [fastEntryButton setBackgroundImage:[[DiceImageManager defaultManager] fastGameBtnBgImage] forState:UIControlStateNormal];
    
    [self.titleFontButton.fontLable setTextColor:[UIColor whiteColor]]; 
    [self.allRoomButton.fontLable setTextColor:[UIColor whiteColor]]; 
    [self.friendRoomButton.fontLable setTextColor:[UIColor whiteColor]]; 
    [self.nearByRoomButton.fontLable setTextColor:[UIColor whiteColor]]; 
    
    [self.allRoomButton.fontLable setText:NSLS(@"kAll")];
    [self.friendRoomButton.fontLable setText:NSLS(@"kFriend")];
    [self.nearByRoomButton.fontLable setText:NSLS(@"kNearBy")];
    
    

//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(roomsDidUpdate:)
//                                                 name:ROOMS_DID_UPDATE
//                                               object:nil];
}

- (void)viewDidUnload
{
    [self setCreateRoomButton:nil];
    [self setFastEntryButton:nil];
    [self setTitleFontButton:nil];
    [self setAllRoomButton:nil];
    [self setFriendRoomButton:nil];
    [self setNearByRoomButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self registerDiceRoomNotification];
    [[DiceGameService defaultService] setServerAddress:@"192.168.1.10"];
    [[DiceGameService defaultService] setServerPort:8080];
    [[DiceGameService defaultService] connectServer:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self unregisterDiceRoomNotification];
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
    [cell setCellInfo:session];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [DiceGameService defaultService].roomList.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _isJoiningDice = YES;
    PBGameSession* session = [[DiceGameService defaultService].roomList objectAtIndex:indexPath.row];
    [[DiceGameService defaultService] enterRoom:session.sessionId];
}

#pragma mark - Button action

- (IBAction)clickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickFastEntryButton:(id)sender {
    
    
}

- (IBAction)creatRoom:(id)sender
{
    [[DiceGameService defaultService] creatRoomWithName:nil];
    _isJoiningDice  = YES;
}
- (IBAction)clickAll:(id)sender
{
    [self.allRoomButton setSelected:YES];
    [self.friendRoomButton setSelected:NO];
    [self.nearByRoomButton setSelected:NO];
}
- (IBAction)clickFriendRoom:(id)sender
{
    [self.allRoomButton setSelected:NO];
    [self.friendRoomButton setSelected:YES];
    [self.nearByRoomButton setSelected:NO];
}
- (IBAction)clickNearBy:(id)sender
{
    [self.allRoomButton setSelected:NO];
    [self.friendRoomButton setSelected:NO];
    [self.nearByRoomButton setSelected:YES];
}

#pragma mark - CommonGameServiceDelegate
- (void)didConnected
{
    if ([DiceGameService defaultService].roomList.count <= 0) {
        [[DiceGameService defaultService] getRoomList:0 count:10];
    }
    
}

- (void)didBroken
{
    
}

@end
