//
//  FriendController.m
//  Draw
//
//  Created by haodong qiu on 12年5月8日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "FriendController.h"
#import "ShareImageManager.h"
#import "UIImageUtil.h"
#import "SearchUserController.h"
#import "DeviceDetection.h"
#import "FriendService.h"
#import "LogUtil.h"
//#import "HJManagedImageV.h"
#import "PPApplication.h"
#import "GameNetworkConstants.h"
#import "Room.h"
#import "RoomManager.h"
#import "RoomService.h"
//#import "WXApi.h"
#import "DrawAppDelegate.h"
//#import "DrawUserInfoView.h"
#import "PPConfigManager.h"
#import "NotificationManager.h"
//#import "DiceUserInfoView.h"
#import "FriendService.h"
#import "MyFriend.h"
#import "CommonUserInfoView.h"
#import "StatisticManager.h"
#import "ViewUserDetail.h"
#import "UserDetailViewController.h"
#import "UIViewUtils.h"
#import "GameSNSService.h"

@interface FriendController ()
{
    MyFriend *_selectedFriend;
    ControllerType _type;
    NSSet *_invitedFidSet;
    NSMutableSet *_selectedSet;
    NSString *_inviteText;
    NSInteger _capacity;
    id<FriendControllerDelegate> _delegate;
}
- (void)sendSMS:(NSString *)message;
- (void)sendWeixin:(NSString *)message;
- (BOOL)isFanTab;
- (MyFriend *)friendInFansWithFriendId:(NSString *)fid;
@end

typedef enum{
    TabTypeFan = 2,
    TabTypeFollow = 1,
    TabTypeBlackList = 4,
}TabType;

@implementation FriendController

@synthesize editButton;
@synthesize searchUserButton;
@synthesize tipsLabel;
@synthesize inviteButton;
//@synthesize room = _room;


- (void)dealloc {
    PPRelease(editButton);
    PPRelease(searchUserButton);
    PPRelease(tipsLabel);
//    PPRelease(_room);
    PPRelease(_selectedSet);
    PPRelease(_invitedFidSet);
    PPRelease(_inviteText);
    PPRelease(inviteButton);

    RELEASE_BLOCK(_selectCallback);
    
    [_buttonBgImageView release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        _defaultTabIndex = 0;
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

+ (FriendController*)searchUser:(PPViewController*)fromController delegate:(id<FriendControllerDelegate>)delegate
{
    FriendController *fc = [[FriendController alloc] initWithDelegate:delegate];
    [fromController.navigationController pushViewController:fc animated:YES];
    [fc release];
    return fc;
}

+ (FriendController*)searchUser:(PPViewController*)fromController callback:(FriendControllerCallback)callback
{
    FriendController *fc = [[FriendController alloc] initWithCallback:callback];
    [fromController.navigationController pushViewController:fc animated:YES];
    [fc release];
    return fc;
}

- (id)initWithInviteText:(NSString *)inviteText //a invite text send to friends via sms        
      invitedFriendIdSet:(NSSet *)fSet 
                capacity:(NSInteger)capacity
                delegate:(id<FriendControllerDelegate>)delegate
{
    self = [super init];
    if (self) {
        _type = ControllerTypeInviteFriend;
        _inviteText = [inviteText retain];
        _invitedFidSet = [fSet retain];
        _delegate = delegate;
        _capacity = capacity;
    }
    return self;
}

//select a friend
- (id)initWithDelegate:(id<FriendControllerDelegate>)delegate
{
    self = [super init];
    if (self) {
        _type = ControllerTypeSelectFriend;
        _delegate = delegate;
    }
    return self;
}

//select a friend
- (id)initWithCallback:(FriendControllerCallback)callback
{
    self = [super init];
    if (self) {
        _type = ControllerTypeSelectFriend;
        _delegate = nil;
        self.selectCallback = callback;        
    }
    return self;
}

- (void)setDefaultTabIndex:(FriendTabIndexType)tabIndex
{
    _defaultTabIndex = tabIndex;
}

#define VALUE(X) (ISIPAD ? 2 * X : X)
#define PAPER_TAG 1000
#define OFFSET VALUE(40)

- (UIView *)paper
{
    return [self.view viewWithTag:PAPER_TAG];
}

- (void)hideBottomButtons
{
    self.inviteButton.hidden = YES;
    [self.searchUserButton setCenter:CGPointMake(self.view.bounds.size.width/2, self.searchUserButton.center.y)];
}

- (void)initTabButton
{
    
    [super initTabButtons];
    ShareImageManager *imageManager = [ShareImageManager defaultManager];

    NSString* title = @"";
    switch (_type) {
        case ControllerTypeInviteFriend:
            [self.titleLabel setText:NSLS(@"kInviteFriendsTitle")];
            title = NSLS(@"kInviteFriendsTitle");
            editButton.hidden = YES;
            [editButton setBackgroundImage:[imageManager orangeImage] forState:UIControlStateNormal];
            [editButton setTitle:NSLS(@"kInvite") forState:UIControlStateNormal];
            if (_selectedSet == nil) {
                _selectedSet = [[NSMutableSet alloc] init];            
            }
            
            [searchUserButton setTitle:NSLS(@"kSMSInvite") forState:UIControlStateNormal];
            [inviteButton setTitle:NSLS(@"kWeixinInvite") forState:UIControlStateNormal];
            break;
        case ControllerTypeSelectFriend:
            [self.titleLabel setText:NSLS(@"kSelectContacts")];
            title = NSLS(@"kSelectContacts");
            [editButton setHidden:YES];
            [self hideBottomButtons];
            break;
        case ControllerTypeShowFriend:
        default:
            [self.titleLabel setText:NSLS(@"kMyFriends")];    
            title = NSLS(@"kMyFriends");
            [searchUserButton setTitle:NSLS(@"kSearchUser") forState:UIControlStateNormal];
            [inviteButton setTitle:NSLS(@"kInviteFriends") forState:UIControlStateNormal];
            editButton.hidden = YES;
            break;
    }
    [self.searchUserButton setBackgroundImage:[[GameApp getImageManager] commonDialogLeftBtnImage] forState:UIControlStateNormal];
    [self.inviteButton setBackgroundImage:[[GameApp getImageManager] commonDialogRightBtnImage] forState:UIControlStateNormal];
    
    [self.searchUserButton setTitleColor:[GameApp buttonTitleColor] forState:UIControlStateNormal];
    [self.inviteButton setTitleColor:[GameApp buttonTitleColor] forState:UIControlStateNormal];
    
    [self.titleView setTitle:title];
    [self.titleView setTarget:self];
    

}

- (void)updateBadge
{
    NSInteger badge = [[StatisticManager defaultManager] fanCount];
    [self setBadge:badge onTab:TabTypeFan];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTabButton];
    [[FriendService defaultService] getRelationCount:self];
    self.dataTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.dataTableView.separatorColor = [UIColor clearColor];
    
    
    [self.view sendSubviewToBack:self.dataTableView];
    self.view.backgroundColor = COLOR_WHITE;
    
    [self.dataTableView updateOriginDataViewTableY:(COMMON_TAB_BUTTON_Y + COMMON_TAB_BUTTON_HEIGHT)];
    
    SET_BUTTON_ROUND_STYLE_YELLOW(searchUserButton);
    SET_BUTTON_ROUND_STYLE_YELLOW(inviteButton);
    [_buttonBgImageView setBackgroundColor:COLOR_GRAY];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[NotificationManager defaultManager] hideNotificationForType:NotificationTypeFan];
    [super viewDidAppear:animated];
    [self updateBadge];
}

- (void)viewDidUnload
{
    [self setEditButton:nil];
    [self setSearchUserButton:nil];
    [self setTipsLabel:nil];
    [self setInviteButton:nil];
    [_selectedSet removeAllObjects];
    [self setButtonBgImageView:nil];
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (IBAction)clickTabButton:(id)sender
{
    [super clickTabButton:sender];
    UIButton *button = (UIButton *)sender;
    NSInteger tag = button.tag;
    TableTab *tab = [_tabManager tabForID:tag];
    if (tab.status != TableTabStatusLoading) {
        [self reloadTableViewDataSource];
    }

}


#pragma mark - Get Friend Method
- (BOOL)isFanTab
{
    return self.currentTab.tabID == TabTypeFan;
}

- (MyFriend *)friendInFansWithFriendId:(NSString *)fid
{
    TableTab *tab = [_tabManager tabForID:TabTypeFan];
    for (MyFriend *friend in tab.dataList) {
        if ([friend.friendUserId isEqualToString:fid]) {
            return friend;
        }
    }
    return nil;
}

- (MyFriend *)friendForIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if ([self.tabDataList count] > row) {
        return [self.tabDataList objectAtIndex:row];
    }
    return nil;
}

#pragma mark - Judge invited set
- (BOOL)isFriendInvited:(MyFriend *)friend
{
    return [_invitedFidSet containsObject:friend.friendUserId];
}


- (BOOL)isFriendSelected:(MyFriend *)friend
{
    for (MyFriend *aFriend in _selectedSet) {
        if ([friend.friendUserId isEqualToString:aFriend.friendUserId]) {
            PPDebug(@"<isFriendSelected> fid = %@, nick1 = %@, nick2 = %@", 
                    friend.friendUserId, friend.nickName,aFriend.nickName);
            return YES;
        }
    }
    return NO;
}

- (void)unSelectFriend:(MyFriend *)friend
{
    MyFriend *temp = nil;
    for (MyFriend *aFriend in _selectedSet) {
        if ([friend.friendUserId isEqualToString:aFriend.friendUserId]) {
            temp = aFriend;
            break;
        }
    }
    [_selectedSet removeObject:temp];
}

- (void)selectFriend:(MyFriend *)friend
{
    MyFriend *temp = nil;
    for (MyFriend *aFriend in _selectedSet) {
        if ([friend.friendUserId isEqualToString:aFriend.friendUserId]) {
            temp = aFriend;
            break;
        }
    }
    [_selectedSet removeObject:temp];
}

#pragma mark - table view delegate

SET_CELL_BG_IN_CONTROLLER;

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [FriendCell getCellHeight];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath == nil) {
        return nil;
    }
    NSString *indentifier = [FriendCell getCellIdentifier];
    FriendCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (cell == nil) {
        cell = [FriendCell createCell:self];
    }
    
    MyFriend *friend = [self.tabDataList objectAtIndex:[indexPath row]];
    
    NSString *statusText = nil;
    if ([self isFriendInvited:friend]) {
        statusText = NSLS(@"kInvited");
    }
    
    [cell setCellWithMyFriend:friend indexPath:indexPath statusText:statusText];

    if ([self isFriendSelected:friend]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    

    return cell;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    return UITableViewCellEditingStyleDelete;
//    return [self isFanTab] ? UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyFriend *friend = (MyFriend *)[self friendForIndexPath:indexPath];
    if (friend) {
        if (self.currentTab.tabID == TabTypeFan) {
            [[FriendService defaultService] removeFan:friend delegate:self];
        }else if (self.currentTab.tabID == TabTypeFollow){
            [[FriendService defaultService] unFollowUser:friend delegate:self];
        } else if (self.currentTab.tabID == TabTypeBlackList) {
            [[FriendService defaultService] unblackFriend:friend.friendUserId successBlock:^{
                [self reloadTableViewDataSource];
            }];
        }
    }
}



- (void)showUserInfo:(MyFriend *)friend
{
    [CommonUserInfoView showFriend:friend inController:self needUpdate:YES canChat:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyFriend *friend = [self friendForIndexPath:indexPath];
    if (friend) {        
        switch (_type) {
            case ControllerTypeSelectFriend:
            {
                if (_delegate && [_delegate respondsToSelector:@selector(friendController:didSelectFriend:)]) {
                    [_delegate friendController:self didSelectFriend:friend];
                }
                else if (self.selectCallback){
                    EXECUTE_BLOCK(self.selectCallback, self, friend);
                    RELEASE_BLOCK(_selectCallback);                    
                }
                
            }
                break;
                
            case ControllerTypeInviteFriend:
                if ([self isFriendSelected:friend]) {
                    [self unSelectFriend:friend];
                }else{
                    NSInteger userCount = [_invitedFidSet count] + [_selectedSet count];
                    if (userCount >= _capacity) {
                        NSString *string = [NSString stringWithFormat:NSLS(@"kInviteFull"),
                                            _capacity,
                                            userCount];
                        POSTMSG(string);
                        return;
                    }
                    [_selectedSet addObject:friend];
                }
                [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                                 withRowAnimation:UITableViewRowAnimationFade];
                editButton.hidden = ([_selectedSet count] == 0);

                break;
            case ControllerTypeShowFriend:
            default:
                [self showUserInfo:friend];

                break;
        }
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_type == ControllerTypeShowFriend) {
        return YES;        
    }
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.currentTab.tabID) {
        case TabTypeFan:
            return NSLS(@"kRemoveFan");
        case TabTypeFollow:
            return NSLS(@"kUnfollow");
        case TabTypeBlackList:
            return NSLS(@"kUnblackFriend");
        default:
            break;
    }
    return nil;
}


#pragma -mark Button Action

- (IBAction)clickEdit:(id)sender
{
    
    switch (_type) {
        case ControllerTypeInviteFriend:
            if (_delegate && [_delegate respondsToSelector:@selector(friendController:didInviteFriendSet:)]) {
                [_delegate friendController:self didInviteFriendSet:_selectedSet];
            }
            break;
        case ControllerTypeSelectFriend:
            break;
        default:
            break;
    }
}


- (IBAction)clickSearchUser:(id)sender
{
    if (_type == ControllerTypeInviteFriend) {
        [self sendSMS:_inviteText];
    }else {
        editButton.selected = NO;
        [dataTableView setEditing:editButton.selected animated:NO];
        SearchUserController *searchUser  = [[SearchUserController alloc] initWithType:_type];
        searchUser.delegate = self;
        [self.navigationController pushViewController:searchUser animated:YES];
        [searchUser release];
    }
}

- (IBAction)clickInviteButton:(id)sender
{
    if (_type == ControllerTypeInviteFriend) {
        [self sendWeixin:_inviteText];
    }else {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLS(@"kSelectInvitation") 
                                                                 delegate:self 
                                                        cancelButtonTitle:NSLS(@"kCancel") 
                                                   destructiveButtonTitle:NSLS(@"kSMSInvite") 
                                                        otherButtonTitles:NSLS(@"kWeixinInvite"), nil];
        [actionSheet showInView:self.view];
        [actionSheet release];
    }
}

#pragma mark - Custom methods



#pragma mark - FriendServiceDelegate Method
- (void)didfindFriendsByType:(int)type friendList:(NSArray *)friendList result:(int)resultCode
{
    if (resultCode == 0) {
        [self finishLoadDataForTabID:type resultList:friendList];
        if (type == TabTypeFan) {
            [[StatisticManager defaultManager] setFanCount:0];
            [self updateBadge];
        }
    }else{
        [self failLoadDataForTabID:type];
    }
}


- (void)didFollowFriend:(MyFriend *)myFriend resultCode:(int)resultCode
{
    [self hideActivity];
    if (resultCode == 0) {
        POSTMSG(NSLS(@"kFollowSuccessfully"));
        //change the friend relation
        [myFriend setRelation:(myFriend.relation | FriendTypeFollow)];
        
        //add the friend into the follow list
        TableTab *tab = [_tabManager tabForID:TabTypeFollow];
        if (myFriend) {
            [tab.dataList insertObject:myFriend atIndex:0];
            [self.dataTableView reloadData];
        }
    } else {
        POSTMSG(NSLS(@"kFollowFailed"));
    }
}
- (void)didUnFollowFriend:(MyFriend *)myFriend resultCode:(int)resultCode
{
    [self hideActivity];
    if (resultCode == 0) {
        POSTMSG(NSLS(@"kUnfollowSuccessfully"));
        TableTab *tab = [_tabManager tabForID:TabTypeFollow];
        
        //change the friend relation in fan list
        MyFriend *friend = [self friendInFansWithFriendId:myFriend.friendUserId];
        [friend setRelation:(friend.relation ^ FriendTypeFollow)];
        
        //remove the frined from the follow list
        [tab.dataList removeObject:myFriend];
        [self.dataTableView reloadData];
    }else {
        POSTMSG(NSLS(@"kUnfollowFailed"));
    }

}

- (void)didRemoveFan:(MyFriend *)fan resultCode:(NSInteger)resultCode
{
    [self hideActivity];
    if (resultCode == 0) {
        POSTMSG(NSLS(@"kRemoveSuccessfully"));
        TableTab *tab = [_tabManager tabForID:TabTypeFan];
        
        //remove the frined from the follow list
        [tab.dataList removeObject:fan];
        [self.dataTableView reloadData];
    }else {
        POSTMSG(NSLS(@"kRemoveFailed"));        
    }
    
}


#pragma -mark FollowDelegate Method
- (void)didClickFollowButtonWithFriend:(MyFriend *)myFriend
{
    if (myFriend) {
        [[FriendService defaultService] followUser:myFriend delegate:self];            
    }
}

#pragma mark -  FriendDelegate Method

- (void)didInviteFriendAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath) {
        Friend *friend = [self.tabDataList objectAtIndex:indexPath.row];
        if (friend) {
            [_selectedSet addObject:friend];
            [self.dataTableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                                      withRowAnimation:UITableViewRowAnimationFade];
            editButton.hidden = NO;
        }
    }
}

- (void)didGetFanCount:(NSInteger)fanCount
           followCount:(NSInteger)followCount
            blackCount:(NSInteger)blackCount
            resultCode:(NSInteger)resultCode
{
    if (resultCode == 0) {
        //update fan Count and follow count
        [self setTab:TabTypeFan titleNumber:fanCount];
        [self setTab:TabTypeFollow titleNumber:followCount];
        [self setTab:TabTypeBlackList titleNumber:blackCount];
    }
}

#pragma mark - invite with SMS and Weixin
enum {
    INVITE_SMS = 0,
    INVITE_WEIXIN = 1
};

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    PPDebug(@"%d",buttonIndex);
    NSString *invitedText = [NSString stringWithFormat:NSLS(@"kInvitationInfo"), [UIUtils getAppName], [UIUtils getAppLink:[PPConfigManager appId]]];
    if (buttonIndex == INVITE_SMS) {
        [self sendSMS:invitedText];
    }else if (buttonIndex == INVITE_WEIXIN){
        [self sendWeixin:invitedText];
    }else {
        return;
    }
}


- (void)sendSMS:(NSString *)message
{
    [self sendSms:nil body:message];
}


- (void)sendWeixin:(NSString *)message
{
    
    
//    if ([WXApi isWXAppInstalled] == NO || [WXApi isWXAppSupportApi] == NO)
//    {
//        [UIUtils alert:NSLS(@"kWeixinNotInstall")];
//    }else{
//        SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
//        req.bText = YES;
//        req.text = message;
//        req.scene = WXSceneSession;
//        
//        [WXApi sendReq:req];
//    }


    [[GameSNSService defaultService] publishWeibo:TYPE_WEIXIN_SESSION
                                             text:message
                                           inView:self.view
                                       awardCoins:0
                                   successMessage:nil
                                   failureMessage:nil];

}



#pragma mark - Common tab delegate

- (NSString *)tabNoDataTipsforIndex:(NSInteger)index{
    
    NSString *titles[] = {NSLS(@"kNoFollow"),NSLS(@"kNoFans"),NSLS(@"kNoBlackList")};
    return titles[index];
}

- (NSInteger)tabCount
{
    return 3;
}

- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index
{
    return 15;
}
- (NSInteger)tabIDforIndex:(NSInteger)index
{
    int indexs[] = {TabTypeFollow,TabTypeFan,TabTypeBlackList};
    return indexs[index];
}
- (NSString *)tabTitleforIndex:(NSInteger)index
{
    NSString *titles[] = {NSLS(@"kFollow"),NSLS(@"kFans"),NSLS(@"kBlackList")};
    return titles[index];
    
}
- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    [self showActivityWithText:NSLS(@"kLoading")];
    TableTab *tab = [_tabManager tabForID:tabID];
    [[FriendService defaultService] getFriendList:tabID
                                           offset:tab.offset 
                                            limit:tab.limit 
                                         delegate:self];
}


#pragma mark - search user controller delegate
- (void)searchUserController:(SearchUserController *)controller didSelectFriend:(MyFriend *)aFriend
{
    [controller.navigationController popViewControllerAnimated:NO];
    if (_type == ControllerTypeSelectFriend) {
        if (_delegate && [_delegate respondsToSelector:@selector(friendController:didSelectFriend:)]) {
            [_delegate friendController:self didSelectFriend:aFriend];
        }
        else if (self.selectCallback){
            EXECUTE_BLOCK(self.selectCallback, self, aFriend);
            RELEASE_BLOCK(_selectCallback);
        }
    }
}
@end
