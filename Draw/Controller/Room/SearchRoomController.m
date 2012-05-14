//
//  SearchRoomController.m
//  Draw
//
//  Created by  on 12-5-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SearchRoomController.h"
#import "Room.h"
#import "RoomManager.h"
#import "RoomService.h"
#import "ShareImageManager.h"
#import "RoomCell.h"

@implementation SearchRoomController
@synthesize searchButton;
@synthesize searchField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        roomService = [RoomService defaultService];
        imageManager = [ShareImageManager defaultManager];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self.searchField becomeFirstResponder];
    [searchField setBackground:[imageManager normalButtonImage]];
    [searchButton setBackgroundImage:[imageManager orangeImage] forState:UIControlStateNormal];
}

- (void)viewDidUnload
{
    [self setSearchField:nil];
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
    [searchField release];
    [searchButton release];
    [super dealloc];
}
- (IBAction)clickSearhButton:(id)sender {
    [self.searchField resignFirstResponder];
    NSString *key = [self.searchField text];
    if ([key length] != 0) {
        [self showActivity];
        [roomService searchRoomsWithKeyWords:key offset:0 limit:20 delegate:self];        
    }else{
        [self popupMessage:NSLS(@"kTextNull") title:nil];
    }
}


#pragma mark - delegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self clickSearhButton:searchButton];
    return YES;
}

- (void)didSearhRoomWithKey:(NSString *)key roomList:(NSArray*)roomList resultCode:(int)resultCode
{    
    [self hideActivity];
    if (resultCode != 0) {
        [self popupMessage:NSLS(@"kSearhRoomListFail") title:nil];
    }else{
        self.dataList = roomList;
        [self.dataTableView reloadData];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [RoomCell getCellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger number = [dataList count];
    if (number == 0) {
        tableView.hidden = YES;
    }else{
        tableView.hidden = NO;
    }
	return [dataList count];			// default implementation
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = [RoomCell getCellIdentifier];
	RoomCell *cell = [theTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
        cell = [RoomCell createCell:self];
	}
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    Room *room = [self.dataList objectAtIndex:indexPath.row];
    [cell setInfo:room];
	return cell;
}


@end
