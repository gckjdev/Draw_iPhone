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

@interface DiceRoomListController ()

@end

@implementation DiceRoomListController

#pragma mark - Life cycle
@synthesize createRoomButton;
@synthesize fastEntryButton;

- (void)dealloc {
    [createRoomButton release];
    [fastEntryButton release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[[DiceImageManager defaultManager] roomBgImage]];
    
    [createRoomButton setBackgroundImage:[[DiceImageManager defaultManager] createRoomBtnBgImage] forState:UIControlStateNormal];
    
    [fastEntryButton setBackgroundImage:[[DiceImageManager defaultManager] createRoomBtnBgImage] forState:UIControlStateNormal];
    
    [[CommonGameNetworkClient defaultInstance] sendGetRoomsRequest:[[UserManager defaultManager] userId]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(roomsDidUpdate:)
                                                 name:ROOMS_DID_UPDATE
                                               object:nil];
}

- (void)viewDidUnload
{
    [self setCreateRoomButton:nil];
    [self setFastEntryButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    
    return cell;
}

#pragma mark - Button action

- (IBAction)clickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end
