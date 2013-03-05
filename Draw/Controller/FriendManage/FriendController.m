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
#import "HJManagedImageV.h"
#import "PPApplication.h"
#import "GameNetworkConstants.h"
#import "Room.h"
#import "RoomManager.h"
#import "RoomService.h"
#import "WXApi.h"
#import "DrawAppDelegate.h"
#import "DrawUserInfoView.h"
#import "ConfigManager.h"
#import "NotificationManager.h"
#import "DiceUserInfoView.h"
#import "FriendService.h"
#import "MyFriend.h"
#import "CommonUserInfoView.h"
#import "StatisticManager.h"


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
    TabTypeBlackList = 3,
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
    [_newFanNumber release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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


- (void)initTabButton
{

    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    
    UIButton *myFollowButton = [self tabButtonWithTabID:TabTypeFollow];
    UIButton *myFanButton = [self tabButtonWithTabID:TabTypeFan];
    UIButton *blackListButton = [self tabButtonWithTabID:TabTypeBlackList];
    
    [myFollowButton setTitle:NSLS(@"kFollow") forState:UIControlStateNormal];
    [myFanButton setTitle:NSLS(@"kFans") forState:UIControlStateNormal];
    [blackListButton setTitle:NSLS(@"kBlackList") forState:UIControlStateNormal];
    
    [myFollowButton setBackgroundImage:[imageManager myFoucsImage] 
                              forState:UIControlStateNormal];
    
    [myFollowButton setBackgroundImage:[imageManager myFoucsSelectedImage]
                              forState:UIControlStateSelected];
    
    [myFanButton setBackgroundImage:[imageManager middleTabImage]
                           forState:UIControlStateNormal];
    
    [myFanButton setBackgroundImage:[imageManager middleTabSelectedImage]
                           forState:UIControlStateSelected];
    
    [blackListButton setBackgroundImage:[imageManager focusMeImage]
                           forState:UIControlStateNormal];
    
    [blackListButton setBackgroundImage:[imageManager focusMeSelectedImage]
                           forState:UIControlStateSelected];

    
    
    
    switch (_type) {
        case ControllerTypeInviteFriend:
            [self.titleLabel setText:NSLS(@"kInviteFriendsTitle")];
            editButton.hidden = YES;
            [editButton setBackgroundImage:[imageManager orangeImage] forState:UIControlStateNormal];
            [editButton setTitle:NSLS(@"kInvite") forState:UIControlStateNormal];
            if (_selectedSet == nil) {
                _selectedSet = [[NSMutableSet alloc] init];            
            }
            
            [searchUserButton setTitle:NSLS(@"kSMSInvite") forState:UIControlStateNormal];
//            [searchUserButton setBackgroundImage:[imageManager greenImage] forState:UIControlStateNormal];
            [inviteButton setTitle:NSLS(@"kWeixinInvite") forState:UIControlStateNormal];
//            [inviteButton setBackgroundImage:[imageManager greenImage] forState:UIControlStateNormal];
            break;
        case ControllerTypeSelectFriend:
            [self.titleLabel setText:NSLS(@"kSelectContacts")];    
            self.inviteButton.hidden = self.searchUserButton.hidden = YES;
            [editButton setHidden:YES];
            break;
        case ControllerTypeShowFriend:
        default:
            [self.titleLabel setText:NSLS(@"kMyFriends")];    
            [searchUserButton setTitle:NSLS(@"kSearchUser") forState:UIControlStateNormal];
//            [searchUserButton setBackgroundImage:[imageManager greenImage] forState:UIControlStateNormal];
            [inviteButton setTitle:NSLS(@"kInviteFriends") forState:UIControlStateNormal];
//            [inviteButton setBackgroundImage:[imageManager greenImage] forState:UIControlStateNormal];
            editButton.hidden = YES;
            break;
    }
    [self.searchUserButton setBackgroundImage:[[GameApp getImageManager] commonDialogLeftBtnImage] forState:UIControlStateNormal];
    [self.inviteButton setBackgroundImage:[[GameApp getImageManager] commonDialogRightBtnImage] forState:UIControlStateNormal];
    
    [self.searchUserButton setTitleColor:[GameApp buttonTitleColor] forState:UIControlStateNormal];
    [self.inviteButton setTitleColor:[GameApp buttonTitleColor] forState:UIControlStateNormal];

}

- (void)updateBadge
{
    long badge = [[StatisticManager defaultManager] fanCount];
    NSString *string = [StatisticManager badgeStringFromLongValue:badge];
    if (string) {
        [self.newFanNumber setHidden:NO];
        [self.newFanNumber setTitle:string forState:UIControlStateNormal];
    }else{
        [self.newFanNumber setHidden:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initTabButton];
    self.newFanNumber.hidden = YES;
    [[FriendService defaultService] getRelationCount:self];
    [self clickTabButton:self.currentTabButton];
    
    
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
    [self setNewFanNumber:nil];
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
                if (_delegate && [_delegate respondsToSelector:@selector(friendController:didSelectFriend:)]) {
                    [_delegate friendController:self didSelectFriend:friend];
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
                        [self popupMessage:string title:nil];
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
    return [self isFanTab] ? NSLS(@"kRemoveFan") : NSLS(@"kUnfollow");
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
        SearchUserController *searchUser  = [[SearchUserController alloc] init];
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
        [self popupMessage:NSLS(@"kFollowSuccessfully") title:nil];
        //change the friend relation
        [myFriend setRelation:(myFriend.relation | FriendTypeFollow)];
        
        //add the friend into the follow list
        TableTab *tab = [_tabManager tabForID:TabTypeFollow];
        if (myFriend) {
            [tab.dataList insertObject:myFriend atIndex:0];
            [self.dataTableView reloadData];
        }
    } else {
        [self popupMessage:NSLS(@"kFollowFailed") title:nil];
    }
}
- (void)didUnFollowFriend:(MyFriend *)myFriend resultCode:(int)resultCode
{
    [self hideActivity];
    if (resultCode == 0) {
        [self popupMessage:NSLS(@"kUnfollowSuccessfully") title:nil];
        TableTab *tab = [_tabManager tabForID:TabTypeFollow];
        
        //change the friend relation in fan list
        MyFriend *friend = [self friendInFansWithFriendId:myFriend.friendUserId];
        [friend setRelation:(friend.relation ^ FriendTypeFollow)];
        
        //remove the frined from the follow list
        [tab.dataList removeObject:myFriend];
        [self.dataTableView reloadData];
    }else {
        [self popupMessage:NSLS(@"kUnfollowFailed") title:nil];
    }

}

- (void)didRemoveFan:(MyFriend *)fan resultCode:(NSInteger)resultCode
{
    [self hideActivity];
    if (resultCode == 0) {
        [self popupMessage:NSLS(@"kRemoveSuccessfully") title:nil];
        TableTab *tab = [_tabManager tabForID:TabTypeFan];
        
        //remove the frined from the follow list
        [tab.dataList removeObject:fan];
        [self.dataTableView reloadData];
    }else {
        [self popupMessage:NSLS(@"kRemoveFailed") title:nil];
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
        
        UIButton *fButton = (UIButton *)[self.view viewWithTag:TabTypeFan];
        NSString *fTitle = [NSString stringWithFormat:NSLS(@"kFansNumber"), fanCount];
        [fButton setTitle:fTitle forState:UIControlStateNormal];
        
        fButton = (UIButton *)[self.view viewWithTag:TabTypeFollow];
        fTitle = [NSString stringWithFormat:NSLS(@"kFollowNumber"), followCount];
        [fButton setTitle:fTitle forState:UIControlStateNormal];
        
        fButton = (UIButton *)[self.view viewWithTag:TabTypeBlackList];
        fTitle = [NSString stringWithFormat:NSLS(@"kBlackListNumber"), blackCount];
        [fButton setTitle:fTitle forState:UIControlStateNormal];
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
    NSString *invitedText = [NSString stringWithFormat:NSLS(@"kInvitationInfo"), [UIUtils getAppLink:[ConfigManager appId]]];
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
    if ([WXApi isWXAppInstalled] == NO || [WXApi isWXAppSupportApi] == NO)
    {
        [UIUtils alert:NSLS(@"kWeixinNotInstall")];
    }else{
        SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
        req.bText = YES;
        req.text = message;
        req.scene = WXSceneSession;
        
        [WXApi sendReq:req];
    }
}



#pragma mark - Common tab delegate

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
    NSString *titles[] = {NSLS(@"kFollow"),NSLS(@"kFan"),NSLS(@"kBlackList")};
    return titles[index];
    
}
- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    TableTab *tab = [_tabManager tabForID:tabID];
    [[FriendService defaultService] getFriendList:tabID
                                           offset:tab.offset 
                                            limit:tab.limit 
                                         delegate:self];
}

@end
