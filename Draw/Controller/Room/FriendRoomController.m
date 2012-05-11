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
#import "PPDebug.h"
#import "Room.h"
@implementation FriendRoomController
@synthesize editButton;
@synthesize createButton;
@synthesize searchButton;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    [self initButtons];
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
    [[RoomService defaultService] createRoom:@"甘米的房间" password:@"sysu" delegate:self];
}

- (IBAction)clickSearchButton:(id)sender {
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
    }
}
@end
