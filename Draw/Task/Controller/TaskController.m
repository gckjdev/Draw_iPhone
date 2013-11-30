//
//  TaskController.m
//  Draw
//
//  Created by qqn_pipi on 13-11-14.
//
//

#import "TaskController.h"
#import "TaskCell.h"
#import "TaskManager.h"
#import "GameTask.h"
#import "CommonTitleView.h"

@interface TaskController ()

@end

@implementation TaskController

- (void)viewDidLoad
{
    [[TaskManager defaultManager] loadTask];
    self.dataList = [[TaskManager defaultManager] taskList];
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    CommonTitleView *titleView = [CommonTitleView createTitleView:self.view];
    [titleView setTarget:self];
    [titleView setTitle:NSLS(@"kTask")];
    [titleView setBackButtonSelector:@selector(clickBack:)];
    
    self.dataTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.dataTableView.separatorColor = [UIColor clearColor];
    
    [self registerNotificationWithName:TASK_DATA_RELOAD_NOTIFICATION
                            usingBlock:^(NSNotification *note) {
                                self.dataList = [[TaskManager defaultManager] taskList];
                                [self.dataTableView reloadData];
                            }];
}

//SET_CELL_BG_IN_VIEW;

#pragma mark - table view delegate

SET_CELL_BG_IN_CONTROLLER

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    // TODO: need to be implemented.
    return [self.dataList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [TaskCell getCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.row < 0 || indexPath.row >= [self.dataList count]){
        return nil;
    }
    
    TaskCell *cell = [tableView dequeueReusableCellWithIdentifier:[TaskCell getCellIdentifier]];
    
    if (cell == nil) {
        cell = [TaskCell createCell:self];
    }
    
    GameTask* task = [self.dataList objectAtIndex:indexPath.row];
    [cell setCellInfo:task];
    cell.indexPath = indexPath;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < 0 || indexPath.row >= [self.dataList count]){
        return;
    }
    
    GameTask* task = [self.dataList objectAtIndex:indexPath.row];
    [[TaskManager defaultManager] execute:task viewController:self];
}

- (void)clickTakeAwardButton:(NSIndexPath*)indexPath
{
    if (indexPath.row < 0 || indexPath.row >= [self.dataList count]){
        return;
    }
    
    GameTask* task = [self.dataList objectAtIndex:indexPath.row];
    [[TaskManager defaultManager] awardTask:task viewController:self];
}


@end
