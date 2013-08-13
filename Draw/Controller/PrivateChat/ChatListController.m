//
//  ChatListController.m
//  Draw
//
//  Created by haodong qiu on 12年6月7日.
//  Copyright (c) 2012年 orange. All rights reserved.
//

#import "ChatListController.h"
#import "ChatCell.h"
#import "ShareImageManager.h"
#import "ChatDetailController.h"
//#import "MessageTotal.h"
//#import "MessageTotalManager.h"
//#import "ChatMessageManager.h"
#import "MyFriend.h"
#import "FriendManager.h"
//#import "ChatMessage.h"
//#import "DrawUserInfoView.h"
//#import "DiceUserInfoView.h"
#import "MessageStat.h"
#import "PPMessageManager.h"
#import "UserManager.h"
#import "CommonUserInfoView.h"
#import "GameApp.h"

@interface ChatListController ()


- (void)openChatDetail:(MessageStat *)messageStat;
//- (void)uniqueMessageStats; 
@end

@implementation ChatListController

@synthesize addChatButton;


- (void)dealloc {
    PPRelease(addChatButton);
    [super dealloc];
}

#pragma mark read && write data into files

- (void)initListWithLocalData
{
    NSArray* list = [PPMessageManager localMessageStatList];
    PPDebug(@"<initListWithLocalData> list count = %d", [list count]);
    if ([list count] != 0) {
        [self.tabDataList addObjectsFromArray:list];
    }
}

- (void)bgRunBlock:(dispatch_block_t)block
{
    block();
    
//    dispatch_queue_t queue = dispatch_get_main_queue();  //dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    if (queue) {
//        dispatch_async(queue, block);
//    }
}
- (void)bgSaveMessageStatList
{
    [self bgRunBlock:^{
        [PPMessageManager saveMessageStatList:self.tabDataList]; 
    }];
}

- (void)bgDeleteMessageStat:(MessageStat *)messageStat
{
    [self bgRunBlock:^{
        [PPMessageManager deleteLocalFriendMessageList:messageStat.friendId];
    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self bgSaveMessageStatList];
}

- (void)viewDidLoad
{
    [self setPullRefreshType:PullRefreshTypeBoth];
    [super viewDidLoad];

    //use local data
    [self initListWithLocalData];    
    
    [self.titleLabel setText:NSLS(@"kChatListTitle")];
    
    [addChatButton setTitle:NSLS(@"kAddChat") forState:UIControlStateNormal];
    
    /*
    
    if (isCallTrackAPP()) {
        [self.titleLabel setText:NSLS(@"kSecureSmsLocateTitle")];
    } else {
        [self.titleLabel setText:NSLS(@"kChatListTitle")];
    }
     */
    
    [CommonTitleView createTitleView:self.view];
    CommonTitleView* titleView = [CommonTitleView titleView:self.view];
    [titleView setTitle:NSLS(@"kChatListTitle")];
    [titleView setRightButtonTitle:NSLS(@"kAddChat")];
    [titleView setTarget:self];
    [titleView setRightButtonSelector:@selector(clickAddChatButton:)];
    
    
    TableTab *tab = [self currentTab];    
    [self clickTab:tab.tabID];
}


- (void)viewDidUnload
{
    [self setAddChatButton:nil];
    [super viewDidUnload];
}


//- (void)uniqueMessageStats
//{
//    NSInteger count = [self.tabDataList count];
//    if (count == 0) {
//        return;
//    }
//    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:count];
//    NSMutableArray *list = [self tabDataList];
//    NSMutableArray *repeatList = [NSMutableArray arrayWithCapacity:count];
//    for (MessageStat *stat in list) {
//        NSString *key = stat.friendId;
//        MessageStat *stat2 = [dict objectForKey:key];
//        if (stat2 == nil) {
//            [dict setObject:stat forKey:key];
//        }else{
//            NSTimeInterval it1 = [stat.latestCreateDate timeIntervalSince1970];
//            NSTimeInterval it2 = [stat2.latestCreateDate timeIntervalSince1970];
//            if (it2 < it1) {
//                [dict setObject:stat forKey:key];
//                [repeatList removeObject:stat2];
//                [repeatList addObject:stat];
//            }
//        }
//    }
//    [list removeObjectsInArray:repeatList];
//    repeatList = nil;
//    dict = nil;
//}

- (void)viewDidAppear:(BOOL)animated
{
//    [self uniqueMessageStats];
    [self.dataTableView reloadData];
    [super viewDidAppear:animated];
}

#pragma mark - custom methods


- (void)openChatDetail:(MessageStat *)messageStat
{
    ChatDetailController *controller = [[ChatDetailController alloc] initWithMessageStat:messageStat];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];

}


- (void)didMessageStat:(MessageStat *)messageStat createNewMessage:(PPMessage *)message
{
    if (message && messageStat) {
        messageStat.messageType = message.messageType;
        messageStat.latestText = message.text;
        messageStat.latestCreateDate = message.createDate;
        messageStat.numberOfMessage++;
        messageStat.numberOfNewMessage = 0;
        
        [self.tabDataList removeObject:messageStat];
        [self.tabDataList insertObject:messageStat atIndex:0];        
    }
}

#define NODATA_LABEL_TAG  90
#define NODATA_LABEL_FONT  (([DeviceDetection isIPAD])?(28.0):(14.0))



#pragma mark - ChatServiceDelegate methods
- (void)didGetMessageStats:(NSArray *)statList resultCode:(int)resultCode
{
    if (resultCode == 0) {
        if (self.currentTab.offset == 0) {
            [self.tabDataList removeAllObjects];
        }
        [self finishLoadDataForTabID:self.currentTab.tabID resultList:statList];
        if ([statList count] < MESSAGE_STAT_MAX_COUNT) {
            [self.currentTab setHasMoreData:NO];
        }
    }else{
        [self failLoadDataForTabID:self.currentTab.tabID];
    }
}


//- (void)didDeleteMessageStat:(NSString *)friendUserId resultCode:(int)resultCode
//{
//    [self del
//}

#pragma mark - table methods

- (MessageStat *)messageStatOfIndex:(NSInteger)index
{
    NSArray *list = [self tabDataList];
    if ([list count] > index && index >= 0) {
        return [list objectAtIndex:index];
    }
    return nil;
}

- (MyFriend *)friendOfIndex:(NSInteger)index
{
    MessageStat *stat = [self messageStatOfIndex:index];
    if (stat) {
        MyFriend *aFriend = [MyFriend friendWithFid:stat.friendId nickName:stat.friendNickName avatar:stat.friendAvatar gender:stat.friendGenderString level:1];
        return aFriend;
    }
    return nil;
}


//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    NSInteger count = [super tableView:tableView numberOfRowsInSection:section];
//    if (count < MESSAGE_STAT_MAX_COUNT ) {
//        self.noMoreData = YES;
//    }
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ChatCell getCellHeight];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *indentifier = [ChatCell getCellIdentifier];
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier];
    if (cell == nil) {
        cell = [ChatCell createCell:self];
    }

    MessageStat *stat = [self messageStatOfIndex:indexPath.row];

    if (stat) {
        [cell setCellByMessageStat:stat indexPath:indexPath];
        cell.chatCellDelegate = self;        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageStat *messageStat = [self messageStatOfIndex:indexPath.row];
    if (messageStat) {
        [self openChatDetail:messageStat];
    }
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
                
        MessageStat *stat = [self messageStatOfIndex:indexPath.row];
        
        NSString *friendUserId = stat.friendId;
        
        //delete message total
        [[ChatService defaultService] deleteMessageStat:self friendUserId:friendUserId];
        [self.tabDataList removeObjectAtIndex:indexPath.row];
        [dataTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
        
        [self bgDeleteMessageStat:stat];
        
    }
}




- (IBAction)clickAddChatButton:(id)sender 
{
    FriendController *fc = [[FriendController alloc] initWithDelegate:self];
    [self.navigationController pushViewController:fc animated:YES];
    [fc release];
}


- (MessageStat *)messageStatForFriend:(MyFriend *)friend
{
    
    for (MessageStat *stat in self.tabDataList) {
        if ([stat.friendId isEqualToString:friend.friendUserId]) {
            return stat;
        }
    }
    return [MessageStat messageStatWithFriend:friend];

}

- (void)friendController:(FriendController *)controller didSelectFriend:(MyFriend *)aFriend
{
    if (aFriend) {
        [controller.navigationController popViewControllerAnimated:NO];
        MessageStat *stat = [self messageStatForFriend:aFriend];
        [self openChatDetail:stat];
    }
}


#pragma mark - ChatCellDelegate method
- (void)didClickAvatar:(NSIndexPath *)aIndexPath
{
    MyFriend *aFriend = [self friendOfIndex:aIndexPath.row];
    [CommonUserInfoView showFriend:aFriend inController:self needUpdate:YES canChat:YES];
}


#pragma mark - common tab controller delegate

- (NSInteger)tabCount
{
    return 1;
}
- (NSInteger)currentTabIndex
{
    return 0;
}
- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index
{
    return MESSAGE_STAT_MAX_COUNT;
}
- (NSInteger)tabIDforIndex:(NSInteger)index
{
    return 201210253;
}
- (NSString *)tabTitleforIndex:(NSInteger)index
{
    return nil;
}
- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    TableTab *tab = [_tabManager tabForID:tabID];
    [[ChatService defaultService] getMessageStats:self 
                                            offset:tab.offset
                                              limit:tab.limit];
}

- (NSString *)tabNoDataTipsforIndex:(NSInteger)index
{
    return NSLS(@"kNoChatListInfo");
}


@end
