//
//  ChargeHistoryController.m
//  Draw
//
//  Created by Gamy on 14-1-22.
//
//

#import "ChargeHistoryController.h"
#import "GroupService.h"
#import "GameNetworkConstants.h"
#import "GroupNoticeCell.h"

@interface ChargeHistoryController ()

@end

@implementation ChargeHistoryController

- (void)dealloc
{
    PPRelease(_groupId);
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
    [self.titleView setTitle:NSLS(@"kGroupChargeHistory")];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//should be override
- (void)serviceLoadDataWithOffset:(NSInteger)offset
                            limit:(NSInteger)limit
                         callback:(void (^)(NSInteger code, NSArray *list))callback
{
    [[GroupService defaultService] getGroupChargeHistories:_groupId offset:offset limit:limit callback:^(NSArray *list, NSError *error) {
        NSInteger code = (error ? ERROR_NETWORK : ERROR_SUCCESS);
        EXECUTE_BLOCK(callback, code, list);
    }];
}


- (PBGroupNotice *)noticeAtIndexPath:(NSIndexPath *)indexPath
{
    return self.tabDataList[indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [GroupNoticeCell getCellHeightByNotice:[self noticeAtIndexPath:indexPath]];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GroupNoticeCell *cell = [tableView dequeueReusableCellWithIdentifier:[GroupNoticeCell getCellIdentifier]];
    if (cell == nil) {
        cell = [GroupNoticeCell createCell:self];
    }
    [cell setCellInfo:[self noticeAtIndexPath:indexPath]];
    return cell;
}

- (NSString *)noDataTips
{
    return NSLS(@"kNoChargeHistory");
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = (indexPath.row & 0x1)? COLOR_GRAY : COLOR_WHITE;
    [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
}

@end
