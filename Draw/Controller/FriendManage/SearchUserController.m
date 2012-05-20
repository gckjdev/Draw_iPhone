//
//  SearchUserController.m
//  Draw
//
//  Created by haodong qiu on 12年5月8日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "SearchUserController.h"
#import "ShareImageManager.h"
#import "UIImageUtil.h"
#import "DeviceDetection.h"
#import "FriendService.h"
#import "LogUtil.h"
#import "HJManagedImageV.h"
#import "PPApplication.h"
#import "FriendManager.h"
#import "GameNetworkConstants.h"
#import "TimeUtils.h"
#import "CommonDialog.h"
#import "FriendCell.h"

@interface SearchUserController ()

@property (assign, nonatomic) int selectedIndex;
- (void)clickFollowButton:(id)sender;

@end

@implementation SearchUserController
@synthesize searchButton;
@synthesize titleLabel;
@synthesize resultLabel;
@synthesize inputImageView;
@synthesize inputTextField;
@synthesize selectedIndex;

- (void)dealloc {
    [searchButton release];
    [titleLabel release];
    [resultLabel release];
    [inputTextField release];
    [inputImageView release];
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
    [titleLabel setText:NSLS(@"kSearchUser")];
    
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    
    [inputImageView setImage:[imageManager inputImage]];
    [inputTextField setPlaceholder:NSLS(@"kSearchUserPlaceholder")];
    inputTextField.delegate = self;
    inputTextField.returnKeyType = UIReturnKeyDone;
    
    [searchButton setBackgroundImage:[imageManager orangeImage] forState:UIControlStateNormal];
    [searchButton setTitle:NSLS(@"kSearch") forState:UIControlStateNormal];
    
    resultLabel.textColor = [UIColor colorWithRed:105.0/255.0 green:50.0/255.0 blue:12.0/255.0 alpha:1.0];
    resultLabel.hidden = YES;
    
    dataTableView.separatorColor = [UIColor clearColor];
    dataTableView.hidden = YES;
    
    [inputTextField becomeFirstResponder];
}


- (void)viewDidUnload
{
    [self setSearchButton:nil];
    [self setTitleLabel:nil];
    [self setResultLabel:nil];
    [self setInputTextField:nil];
    [self setInputImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [FriendCell getCellHeight];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *indentifier = [FriendCell getCellIdentifier];
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (cell == nil) {
        cell = [FriendCell createCell:self];
        cell.followDelegate = self;
    }
    NSDictionary *userDic = (NSDictionary *)[dataList objectAtIndex:[indexPath row]];
    [cell setCellByDictionary:userDic indexPath:indexPath];
    
    return cell;
}


- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}


#pragma -mark Button Action
- (IBAction)clickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)backgroundTap:(id)sender
{
    [inputTextField resignFirstResponder];
}


- (IBAction)clickSearch:(id)sender
{
    [inputTextField resignFirstResponder];
    
    if ([inputTextField.text length] == 0) {
        resultLabel.hidden = NO;
        dataTableView.hidden = YES;
        [resultLabel setText:NSLS(@"kEnterWords")];
    }else {
        resultLabel.hidden = YES;
        [[FriendService defaultService] searchUsersByString:inputTextField.text viewController:self];
    }
}


- (void)clickFollowButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    selectedIndex = button.tag;
    NSDictionary *userDic = (NSDictionary *)[dataList objectAtIndex:selectedIndex];
    NSString* userId = [userDic objectForKey:PARA_USERID];
    
    [[FriendService defaultService] followUser:userId viewController:self
     ];
}

#pragma -mark FollowDelegate Method
- (void)didClickFollowButtonAtIndexPath:(NSIndexPath *)indexPath user:(NSDictionary *)user
{
    NSString* userId = [user objectForKey:PARA_USERID];
    
    selectedIndex = [indexPath row];
    
    [[FriendService defaultService] followUser:userId viewController:self
     ];
}


#pragma -mark FriendServiceDelegate Method
- (void)didSearchUsers:(NSArray *)userList result:(int)resultCode
{
    if (resultCode == 0)
    {
        self.dataList = userList;
        [dataTableView reloadData];
        if ([dataList count] == 0) {
            dataTableView.hidden = YES;
            resultLabel.hidden = NO;
            [resultLabel setText:NSLS(@"kDidNottFindThisUser")];
        }
        else {
            dataTableView.hidden = NO;
            resultLabel.hidden = YES;
        }
    }else {
        [self popupMessage:NSLS(@"kSearchFailed") title:nil];
    }
    
    
    /**********************************/
    //test data
//    NSMutableArray *testUserList = [[NSMutableArray alloc] init];
//    for (int i=0; i<20; i++) {
//        NSMutableDictionary *userDic = [[NSMutableDictionary alloc] init];
//        [userDic setObject:[NSString stringWithFormat:@"4fab294a03649bc45d248e3%d",i]  forKey:PARA_USERID];
//        [userDic setObject:[NSString stringWithFormat:@"name%d",i] forKey:PARA_NICKNAME];
//        
//        if (i%2 ==0) {
//            [userDic setObject:[NSString stringWithFormat:@"name%d",i] forKey:PARA_SINA_NICKNAME];
//            [userDic setObject:@"m" forKey:PARA_GENDER];
//        }else {
//            [userDic setObject:[NSString stringWithFormat:@"name%d",i] forKey:PARA_QQ_NICKNAME];
//            [userDic setObject:@"f" forKey:PARA_GENDER];
//        }
//        
//        [testUserList addObject:userDic];
//        [userDic release];
//    }
//    self.dataList = testUserList;
//    [testUserList release];
//    [dataTableView reloadData];
//    if ([dataList count] == 0) {
//        dataTableView.hidden = YES;
//        resultLabel.hidden = NO;
//        [resultLabel setText:NSLS(@"kDidNottFindThisUser")];
//    }
//    else {
//        dataTableView.hidden = NO;
//        resultLabel.hidden = YES;
//    }
    /**********************************/
}


- (void)didFollowUser:(int)resultCode
{
    if (resultCode == 0) {
        [self popupMessage:NSLS(@"kFollowSuccessfully") title:nil];
        NSDictionary *userDic = (NSDictionary *)[dataList objectAtIndex:selectedIndex];
        [userDic setValue:[NSNumber numberWithInt:FOLLOW] forKey:PARA_FRIENDSTYPE];
        [[FriendManager defaultManager] createFriendByDictionary:userDic];
        [dataTableView reloadData];
    } else {
        [self popupMessage:NSLS(@"kFollowFailed") title:nil];
    }
}


#pragma mark - text field delegate.
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self clickSearch:searchButton];
    return YES;
}



@end
