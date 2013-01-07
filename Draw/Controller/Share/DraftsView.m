//
//  DraftsView.m
//  Draw
//
//  Created by 王 小涛 on 13-1-5.
//
//

#import "DraftsView.h"
#import "AutoCreateViewByXib.h"

@implementation DraftsView

AUTO_CREATE_VIEW_BY_XIB(DraftsView);

- (void)dealloc {
    [_tableView release];
    [super dealloc];
}

+ (void)showInView:(UIView *)view
{
    DraftsView *draftsView = [self createView];
    draftsView.tableView.delegate = draftsView;
    draftsView.tableView.dataSource = draftsView;
    
    [view addSubview:draftsView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

@end
