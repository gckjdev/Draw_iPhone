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
#import "CommonUserInfoView.h"
#import "ShareImageManager.h"

@interface SearchUserController () {
    ControllerType _type;
}
@end

@implementation SearchUserController

- (void)dealloc {
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

- (void)viewDidLoad
{
    [self.dataTableView updateWidth:CGRectGetWidth(self.view.bounds)];
    [self.dataTableView updateOriginX:0];
    [super viewDidLoad];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
}



SET_CELL_BG_IN_CONTROLLER;


#pragma -mark FriendServiceDelegate Method
- (void)didSearchUsers:(NSArray *)userList result:(int)resultCode
{
    [self hideActivity];
    if (resultCode == 0)
    {
        PPDebug(@"<didSearchUsers> count = %d", [userList count]);
        [self finishLoadDataForTabID:self.currentTab.tabID resultList:userList];
    }else {
        POSTMSG(NSLS(@"kSearchFailed"));
        [self failLoadDataForTabID:self.currentTab.tabID];
    }
    
}


- (void)didFollowUser:(int)resultCode
{
    if (resultCode == 0) {
        POSTMSG(NSLS(@"kFollowSuccessfully"));

    } else {
        POSTMSG(NSLS(@"kFollowFailed"));
    }
}



//implemented by subclass.

- (void)loadDataWithKey:(NSString *)key tabID:(NSInteger)tabID
{
    [self showActivityWithText:NSLS(@"kSearching")];
    TableTab *tab = [_tabManager tabForID:tabID];
    [[FriendService defaultService] searchUsersWithKey:key
                                                offset:tab.offset
                                                 limit:tab.limit
                                              delegate:self];

}

- (UITableViewCell *)cellForData:(id)data
{
    MyFriend *friend = data;
    NSString *indentifier = [FriendCell getCellIdentifier];
    FriendCell *cell = [self.dataTableView dequeueReusableCellWithIdentifier:indentifier];
    if (cell == nil) {
        cell = [FriendCell createCell:self];
    }
    [cell setCellWithMyFriend:friend indexPath:nil statusText:nil];
    return cell;
}
- (CGFloat)heightForData:(id)data
{
    return [FriendCell getCellHeight];
}
- (void)didSelectedCellWithData:(id)data
{
    MyFriend *friend = data;
    if (_type == ControllerTypeShowFriend) {
        [CommonUserInfoView showFriend:friend inController:self needUpdate:YES canChat:YES];
    }
    if (_type == ControllerTypeSelectFriend) {
        if (_delegate && [_delegate respondsToSelector:@selector(searchUserController:didSelectFriend:)]) {
            [_delegate searchUserController:self didSelectFriend:friend];
        }
    }

}
- (NSString *)headerTitle
{
    return NSLS(@"kSearchUser");    
}
- (NSString *)searchTips
{
    return NSLS(@"kSearchUserPlaceholder");
}
- (NSString *)historyStoreKey
{
    return @"USER_SEARCHED_KEY";
}


@end
