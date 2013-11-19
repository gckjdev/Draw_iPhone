//
//  TaskController.m
//  Draw
//
//  Created by qqn_pipi on 13-11-14.
//
//

#import "TaskController.h"
#import "TaskCell.h"

@interface TaskController ()

@end

@implementation TaskController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

//SET_CELL_BG_IN_VIEW;

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    // TODO: need to be implemented.
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [TaskCell getCellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TaskCell *cell = [tableView dequeueReusableCellWithIdentifier:[TaskCell getCellIdentifier]];
    
    if (cell == nil) {
        cell = [TaskCell createCell:nil];
    }
    
    // TODO: need to be implemented.
//    [cell setCellInfo:nil];
    
    return cell;
}




@end
