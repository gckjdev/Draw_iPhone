//
//  GroupTopicController.m
//  Draw
//
//  Created by Gamy on 13-11-19.
//
//

#import "GroupTopicController.h"
#import "DetailFooterView.h"


typedef enum{
    NewestTopic = 1,
    MarkedTopic = 2,
}TopicType;

typedef enum {
    RowGroupInfo = 0,
    RowTopicHeader,
    BasicRowCount,
}CellRow;

@interface GroupTopicController ()
@property(nonatomic, retain)BBSPostActionHeaderView *topicHeader;
@property(nonatomic, retain)PBGroup *group;
@end

@implementation GroupTopicController

- (GroupTopicController *)enterWithGroup:(PBGroup *)group
                          fromController:(PPViewController *)controller
{
    GroupTopicController *gt = [[GroupTopicController alloc] init];
    gt.group = group;
    [controller.navigationController pushViewController:gt animated:YES];
    return [gt autorelease];
}


- (void)dealloc
{
    PPRelease(_topicHeader);
    PPRelease(_group);
    [super dealloc];
}

- (void)clickJoin:(id)sender
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.titleView setTransparentStyle];

    //TODO check if user has join a group
    [self.titleView setRightButtonTitle:NSLS(@"kJoin")];
    [self.titleView setRightButtonSelector:@selector(clickJoin:)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-- TableView delegate



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger number = [super tableView:tableView numberOfRowsInSection:section];
    return number + BasicRowCount;
}


#pragma mark-- Common Tab Controller delegate

- (NSInteger)tabCount
{
    return 2;
}
- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index
{
    return 10;
}

- (NSInteger)tabIDforIndex:(NSInteger)index
{
    NSInteger tabs[] = {NewestTopic, MarkedTopic};
    return tabs[index];
}

- (NSString *)tabTitleforIndex:(NSInteger)index{
    NSArray *names = @[NSLS(@"kLatest"), NSLS(@"kMarked")];
    return names[index];
}

- (void)serviceLoadDataForTabID:(NSInteger)tabID{
    //TODO fetch data through service.
    [self finishLoadDataForTabID:tabID resultList:nil];
}

@end
