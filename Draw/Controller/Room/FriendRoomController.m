//
//  FriendRoomController.m
//  Draw
//
//  Created by  on 12-5-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FriendRoomController.h"
#import "ShareImageManager.h"
#import "MyFriendsController.h"
#import "SearchRoomController.h"
#import "UserManager.h"
#import "PPDebug.h"
#import "Room.h"
#import "RoomCell.h"

@implementation FriendRoomController
@synthesize editButton;
@synthesize createButton;
@synthesize searchButton;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        roomService = [RoomService defaultService];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)initButtons
{
    //bg image
    ShareImageManager *manager = [ShareImageManager defaultManager];
    [self.editButton setBackgroundImage:[manager redImage] forState:UIControlStateNormal];
    [self.createButton setBackgroundImage:[manager greenImage] forState:UIControlStateNormal];
    [self.searchButton setBackgroundImage:[manager orangeImage] forState:UIControlStateNormal];
    //text
    [self.editButton setTitle:NSLS(@"kEdit") forState:UIControlStateNormal];
    [self.createButton setTitle:NSLS(@"kCreateRoom") forState:UIControlStateNormal];
    [self.searchButton setTitle:NSLS(@"kSearchRoom") forState:UIControlStateNormal];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataList = [[[NSMutableArray alloc] init]autorelease];
    [self initButtons];
    [roomService findMyRoomsWithOffset:0 limit:20 delegate:self];
}

- (void)viewDidUnload
{
    [self setEditButton:nil];
    [self setCreateButton:nil];
    [self setSearchButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [editButton release];
    [createButton release];
    [searchButton release];
    [super dealloc];
}
- (IBAction)clickEditButton:(id)sender {

}

- (IBAction)clickCreateButton:(id)sender {
    static NSInteger number = 1;
    NSString *nick = [[UserManager defaultManager]nickName];
    NSString *string = [NSString stringWithFormat:@"%@的房间%d",nick,number ++];
    [roomService createRoom:string password:@"sysu" delegate:self];
    [self showActivity];
}

- (IBAction)clickSearchButton:(id)sender {
//    [roomService searchRoomsWithKeyWords:@"MIMI的房间5" offset:0 limit:20 delegate:self];
    SearchRoomController *src = [[SearchRoomController alloc] init];
    [self.navigationController pushViewController:src animated:YES];
    [src release];
}

- (IBAction)clickMyFriendButton:(id)sender {
    MyFriendsController *mfc = [[MyFriendsController alloc] init];
    [self.navigationController pushViewController:mfc animated:YES];
    [mfc release];
}

- (void)didCreateRoom:(Room*)room resultCode:(int)resultCode;
{
    [self hideActivity];
    if (resultCode != 0) {
        [self popupMessage:NSLS(@"kCreateFail") title:nil];
    }else{
        PPDebug(@"room = %@", [room description]);
        if (room) {
            NSMutableArray *list = (NSMutableArray *)self.dataList;
            [list insertObject:room atIndex:0];
            [dataTableView beginUpdates];
            NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]];
            [self.dataTableView insertRowsAtIndexPaths:paths withRowAnimation:UITableViewRowAnimationTop];
            [dataTableView endUpdates];
        }
    }
}

- (void)didFindRoomByUser:(NSString *)userId roomList:(NSArray*)roomList resultCode:(int)resultCode
{
    [self hideActivity];
    if (resultCode != 0) {
        [self popupMessage:NSLS(@"kFindRoomListFail") title:nil];
    }else{
        if (roomList == nil) {
            [((NSMutableArray *)self.dataList) removeAllObjects];  ;            
        }else
        {
            self.dataList = roomList;            
        }
        [self.dataTableView reloadData];
    }

}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [RoomCell getCellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [dataList count];			// default implementation
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = [RoomCell getCellIdentifier];
	RoomCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
        cell = [RoomCell createCell:self];
	}
    cell.accessoryType = UITableViewCellAccessoryNone;
    Room *room = [self.dataList objectAtIndex:indexPath.row];
    [cell setInfo:room];
	return cell;
}

@end
