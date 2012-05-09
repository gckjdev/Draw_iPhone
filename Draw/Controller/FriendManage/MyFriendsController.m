//
//  MyFriendsController.m
//  Draw
//
//  Created by haodong qiu on 12年5月8日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "MyFriendsController.h"
#import "ShareImageManager.h"
#import "UIImageUtil.h"
#import "SearchUserController.h"
#import "DeviceDetection.h"
#import "FriendService.h"
#import "LogUtil.h"

@interface MyFriendsController ()

- (void)createCellContent:(UITableViewCell *)cell;
- (void)loadMyFriends;

@end

@implementation MyFriendsController
@synthesize titleLabel;
@synthesize editButton;
@synthesize myFollowButton;
@synthesize myFanButton;
@synthesize searchUserButton;
@synthesize myFollowList = _myFollowList;
@synthesize myFanList = _myFanList;

- (void)dealloc {
    [titleLabel release];
    [editButton release];
    [myFollowButton release];
    [myFanButton release];
    [searchUserButton release];
    [_myFollowList release];
    [_myFanList release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [titleLabel setText:NSLS(@"我的好友")];
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    [editButton setBackgroundImage:[imageManager redImage] forState:UIControlStateNormal];
    [editButton setTitle:NSLS(@"编辑") forState:UIControlStateNormal];
    [editButton setTitle:NSLS(@"完成") forState:UIControlStateSelected];
    
    NSString *followTitle = NSLS(@"关注");
    NSString *fanTitle = NSLS(@"粉丝") ;
    [myFollowButton setTitle:followTitle forState:UIControlStateNormal];
    [myFanButton setTitle:fanTitle forState:UIControlStateNormal];
    [myFollowButton setBackgroundImage:[imageManager myFoucsImage] forState:UIControlStateNormal];
    [myFollowButton setBackgroundImage:[imageManager myFoucsSelectedImage] forState:UIControlStateSelected];
    [myFanButton setBackgroundImage:[imageManager foucsMeImage] forState:UIControlStateNormal];
    [myFanButton setBackgroundImage:[imageManager foucsMeSelectedImage] forState:UIControlStateSelected];
    myFollowButton.selected = YES;
    
    [searchUserButton setTitle:NSLS(@"添加好友") forState:UIControlStateNormal];
    [searchUserButton setBackgroundImage:[imageManager greenImage] forState:UIControlStateNormal];
    
    
    //test
    self.myFollowList = [NSArray arrayWithObjects:@"jack", @"jack", @"jack", @"jack",@"jack", @"jack", @"jack", @"jack", @"jack",@"jack", @"jack",nil];
    self.myFanList = [NSArray arrayWithObjects:@"Jenny", @"Jenny", @"Jenny", @"Jenny",nil];
    
    
    
    [myFollowButton setTitle:[NSString stringWithFormat:@"%@(%d)",followTitle,[_myFollowList count]] forState:UIControlStateNormal];
    [myFanButton setTitle:[NSString stringWithFormat:@"%@(%d)",fanTitle,[_myFanList count]] forState:UIControlStateNormal];
    
    
    self.dataList = _myFollowList;
    dataTableView.separatorColor = [UIColor colorWithRed:175.0/255.0 green:124.0/255.0 blue:68.0/255.0 alpha:1.0];
    
    [self loadMyFriends];
}

- (void)loadMyFriends
{
    [[FriendService defaultService] findFriendsByType:1 viewController:self];
    //[[FriendService defaultService] followUser:@"4fa258c98de2d017ce06711b"];
}

- (void)didfindFriendsByType:(int)type friendList:(NSArray *)friendList result:(int)resultCode
{
    PPDebug(@"didfindFriendsByType");
    if (type == 1) {
        
    }
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setEditButton:nil];
    [self setMyFollowButton:nil];
    [self setMyFanButton:nil];
    [self setSearchUserButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#define CELL_HEIGHT_IPHONE  55
#define CELL_HEIGHT_IPAD    110
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([DeviceDetection isIPAD]) {
        return CELL_HEIGHT_IPAD;
    }else {
        return CELL_HEIGHT_IPHONE;
    }
}

#define AVATAR_TAG  71
#define NICK_TAG    72
- (void)createCellContent:(UITableViewCell *)cell
{
    CGFloat cellHeight, avatarWidth, avatarHeight, nickWidth, nickHeight, space;
    cellHeight = CELL_HEIGHT_IPHONE;
    avatarWidth = 37;
    avatarHeight = 39;
    nickWidth = 100;
    nickHeight = 40;
    space = 8;
    
    if ([DeviceDetection isIPAD]) {
        cellHeight = CELL_HEIGHT_IPAD;
        avatarWidth = 2 * avatarWidth;
        avatarHeight = 2 * avatarHeight;
        nickWidth = 2 * nickWidth;
        nickHeight = 2* nickHeight;
        space = 2 * space;
    }
    
    UIImageView *avatarBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, (cellHeight-avatarHeight)/2, avatarWidth, avatarHeight)];
    [avatarBackground setImage:[UIImage imageNamed:@"user_picbg.png"]];
    [cell.contentView addSubview:avatarBackground];
    [avatarBackground release];
    
    UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (cellHeight-avatarHeight)/2, avatarWidth, avatarWidth)];
    avatarImageView.tag = AVATAR_TAG;
    [cell.contentView addSubview:avatarImageView];
    [avatarImageView release];
    
    UILabel *nickLabel = [[UILabel alloc] initWithFrame:CGRectMake(avatarWidth+space, (cellHeight-nickHeight)/2, nickWidth, nickHeight)];
    nickLabel.backgroundColor = [UIColor clearColor];
    nickLabel.textColor = [UIColor colorWithRed:105.0/255.0 green:50.0/255.0 blue:12.0/255.0 alpha:1.0];
    nickLabel.tag = NICK_TAG;
    [cell.contentView addSubview:nickLabel];
    [nickLabel release];
}

#pragma -mark UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MyFriendsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier]autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        [self createCellContent:cell];
    }
    
    UIImageView *avatarImageView = (UIImageView *)[cell.contentView viewWithTag:AVATAR_TAG];
    UILabel *nickLabel = (UILabel *)[cell.contentView viewWithTag:NICK_TAG];
    avatarImageView.image = [UIImage imageNamed:@"man1.png"];
    nickLabel.text = [dataList objectAtIndex:[indexPath row]];
    
    return cell;
}

- (IBAction)clickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)clickMyFollow:(id)sender
{
    editButton.hidden = NO;
    
    myFollowButton.selected = YES;
    myFanButton.selected = NO;
    self.dataList = _myFollowList;
    [self.dataTableView reloadData];
}

- (IBAction)clickMyFan:(id)sender
{
    myFollowButton.selected = NO;
    myFanButton.selected = YES;
    self.dataList = _myFanList;
    [self.dataTableView reloadData];
    
    editButton.selected = NO;
    [dataTableView setEditing:NO animated:YES];
    editButton.hidden = YES;
}

- (IBAction)clickEdit:(id)sender
{
    editButton.selected = !editButton.selected;
    [dataTableView setEditing:editButton.selected animated:YES];
}

- (IBAction)clickSearchUser:(id)sender
{
    SearchUserController *searchUser  = [[SearchUserController alloc] init];
    [self.navigationController pushViewController:searchUser animated:YES];
    [searchUser release];
}


@end
