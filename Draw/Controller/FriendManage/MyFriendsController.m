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

@interface MyFriendsController ()

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

#pragma -mark UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MyFriendsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier]autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell.textLabel setTextColor:[UIColor brownColor]];
        
        UIImageView *avatarBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, (55-39)/2, 37, 39)];
        [avatarBackground setImage:[UIImage imageNamed:@"user_picbg.png"]];
        [cell.contentView addSubview:avatarBackground];
        [avatarBackground release];
    }
    
    UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (55-39)/2, 37, 36)];
    [avatarImageView setImage:[UIImage imageNamed:@"man1.png"]];
    [cell.contentView addSubview:avatarImageView];
    [avatarImageView release];
    
    UILabel *nickLabel = [[UILabel alloc] initWithFrame:CGRectMake(39+6, (55-40)/2, 100, 40)];
    //nickLabel.backgroundColor = [UIColor blueColor];
    //nickLabel.backgroundColor = [UIColor clearColor];
    nickLabel.textColor = [UIColor colorWithRed:105.0/255.0 green:50.0/255.0 blue:12.0/255.0 alpha:1.0];
    nickLabel.text = [dataList objectAtIndex:[indexPath row]];
    [cell.contentView addSubview:nickLabel];
    [nickLabel release];
    
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
