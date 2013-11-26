//
//  GroupNoticeController.m
//  Draw
//
//  Created by Gamy on 13-11-26.
//
//

#import "GroupNoticeController.h"
#import "GroupService.h"
#import "GroupNoticeCell.h"
#import "BBSUserActionCell.h"

typedef enum{
    GroupComment = 100,
    GroupRequest = 101,
    GroupNotice = 102
}TabID;

@interface GroupNoticeController ()

@end

@implementation GroupNoticeController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.forGroup = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id data = self.tabDataList[indexPath.row];
    
    if (self.currentTab.tabID == GroupComment) {
        return [BBSUserActionCell getCellHeightWithBBSAction:data];
    }else{
        return [GroupNoticeCell getCellHeightByNotice:data];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Class cellClass = nil;

    if (self.currentTab.tabID == GroupComment) {
        cellClass = [BBSUserActionCell class];
    }else{
        cellClass = [GroupNoticeCell class];
    }
    NSString *identifier = [cellClass getCellIdentifier];
    id cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [cellClass createCell:self];
    }
    id data = self.tabDataList[indexPath.row];
    [cell setCellInfo:data];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PPDebug(@"did select at row = %d", indexPath.row);
}

- (NSInteger)tabCount
{
    return 3;
}
- (NSInteger)currentTabIndex
{
    return 0;
}
- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index
{
    return 15;
}
- (NSInteger)tabIDforIndex:(NSInteger)index
{
    NSInteger tabIDs[] = {GroupComment,GroupRequest,GroupNotice};
    return tabIDs[index];
}
- (NSString *)tabTitleforIndex:(NSInteger)index
{
    NSArray *titles = @[NSLS(@"kGroupComment"),NSLS(@"GroupRequest"),NSLS(@"GroupNotice")];
    return titles[index];
}
- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    TableTab *tab = [_tabManager tabForID:tabID];
    [self showActivityWithText:NSLS(@"kLoading")];
    switch (tabID) {
        case GroupComment:
        {
            NSString *userID = [[UserManager defaultManager] userId];
            [[self bbsService] getBBSActionListWithTargetUid:userID
                                                      offset:tab.offset
                                                       limit:tab.limit
                                                    delegate:self];
            break;
        }
        case GroupRequest:
        case GroupNotice:
        {
            GroupNoticeType type = ((tabID == GroupRequest) ? GroupNoticeTypeRequest :GroupNoticeTypeNotice);
            
            [[GroupService defaultService] getGroupNoticeByType:type
                                                         offset:tab.offset
                                                          limit:tab.limit
                                                       callback:^(NSArray *list, NSError *error) {
               [self hideActivity];
               if (error) {
                   [self failLoadDataForTabID:tabID];
               }else{
                   [self finishLoadDataForTabID:tabID resultList:list];
               }
            }];
            break;
        }
        default:
            [self hideActivity];
            break;
    }
}

- (void)didGetActionList:(NSArray *)actionList
               targetUid:(NSString *)targetUid
              resultCode:(NSInteger)resultCode
{
    [self hideActivity];
    if (resultCode == 0) {
        PPDebug(@"<didGetActionList> count = %d",[actionList count]);
        [self finishLoadDataForTabID:GroupComment resultList:actionList];
    }else{
        PPDebug(@"<didGetActionList> fail!");
        [self failLoadDataForTabID:GroupComment];
    }
}

@end
