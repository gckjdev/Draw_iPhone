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
#import "FriendService.h"
#import "LogUtil.h"
#import "TimeUtils.h"
#import "CommonDialog.h"
#import "FriendCell.h"
//#import "DrawUserInfoView.h"
//#import "DiceUserInfoView.h"
#import "CommonUserInfoView.h"

@interface SearchUserController () {
    ControllerType _type;
}
@end

@implementation SearchUserController
@synthesize searchButton;
@synthesize inputImageView;
@synthesize inputTextField;

- (void)dealloc {
    PPRelease(searchButton);
    PPRelease(inputTextField);
    PPRelease(inputImageView);
    [super dealloc];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _defaultTabIndex = 0;
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        _type = ControllerTypeShowFriend;
    }
    return self;
}

- (id)initWithType:(ControllerType)type
{
    self = [super init];
    if (self) {
        _type = type;
    }
    return self;
}

#define SEARCH_BUTTON_TAG 20121025
- (void)viewDidLoad
{
    [self setPullRefreshType:PullRefreshTypeFooter];
    [super viewDidLoad];
    [self.titleLabel setText:NSLS(@"kSearchUser")];
    
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    
    [inputImageView setImage:[imageManager inputImage]];
    [inputTextField setPlaceholder:NSLS(@"kSearchUserPlaceholder")];
    inputTextField.delegate = self;
    inputTextField.returnKeyType = UIReturnKeyDone;
    
//    [searchButton setBackgroundImage:[imageManager orangeImage] forState:UIControlStateNormal];
    [searchButton setTitle:NSLS(@"kSearch") forState:UIControlStateNormal];
    searchButton.tag = SEARCH_BUTTON_TAG;
    
    
    [inputTextField becomeFirstResponder];
}


- (void)viewDidUnload
{
    [self setSearchButton:nil];
    [self setTitleLabel:nil];
    [self setInputTextField:nil];
    [self setInputImageView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (MyFriend *)friendOfIndex:(NSInteger)index
{
    NSArray *list = self.tabDataList;
    if (index < [list count]) {
        MyFriend *friend = [list objectAtIndex:index];
        return friend;
    }
    return nil;
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
    }
    MyFriend *friend = [self friendOfIndex:indexPath.row];
    if (friend) {
        [cell setCellWithMyFriend:friend indexPath:indexPath statusText:nil];        
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MyFriend *friend = [self friendOfIndex:indexPath.row];
    if (friend == nil) {
        return;
    }
    if (_type == ControllerTypeShowFriend) {
        [CommonUserInfoView showFriend:friend inController:self needUpdate:YES canChat:YES];
    }
    if (_type == ControllerTypeSelectFriend) {
        if (_delegate && [_delegate respondsToSelector:@selector(searchUserController:didSelectFriend:)]) {
            [_delegate searchUserController:self didSelectFriend:friend];
        }
    }

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
        [self popupMessage:NSLS(@"kEnterWords") title:nil];
    }else {
        NSInteger tabID = self.currentTab.tabID;
        self.currentTab.offset = 0;
        [self startToLoadDataForTabID:tabID];
        [self serviceLoadDataForTabID:tabID];
        [self showActivityWithText:NSLS(@"kSearching")];
    }
}




#pragma -mark FriendServiceDelegate Method
- (void)didSearchUsers:(NSArray *)userList result:(int)resultCode
{
    [self hideActivity];
    if (resultCode == 0)
    {
        PPDebug(@"<didSearchUsers> count = %d", [userList count]);
        [self finishLoadDataForTabID:self.currentTab.tabID resultList:userList];
    }else {
        [self popupMessage:NSLS(@"kSearchFailed") title:nil];
        [self failLoadDataForTabID:self.currentTab.tabID];
    }
    
}


- (void)didFollowUser:(int)resultCode
{
    if (resultCode == 0) {
        [self popupMessage:NSLS(@"kFollowSuccessfully") title:nil];
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



#pragma mark - common tab controller delegate

- (NSInteger)tabCount
{
    return 1;
}
- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index
{
    return 20;
}
- (NSInteger)tabIDforIndex:(NSInteger)index
{
    return SEARCH_BUTTON_TAG;
}
- (NSString *)tabTitleforIndex:(NSInteger)index
{
    return nil;
}

- (NSInteger)currentTabIndex
{
    return 0;
}

- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    
    TableTab *tab = [_tabManager tabForID:tabID];
    [[FriendService defaultService] searchUsersWithKey:inputTextField.text
                                                offset:tab.offset 
                                                 limit:tab.limit
                                              delegate:self];
}


@end
