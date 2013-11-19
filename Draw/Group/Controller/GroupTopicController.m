//
//  GroupTopicController.m
//  Draw
//
//  Created by Gamy on 13-11-19.
//
//

#import "GroupTopicController.h"
#import "DetailFooterView.h"
#import "GroupInfoView.h"
#import "BBSPostCell.h"
#import "BBSModelExt.h"

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
@property(nonatomic, retain)UITableViewCell *infoCell;
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
    PPRelease(_infoCell);
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


- (PBBBSPost *)postInIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row - BasicRowCount;
    PBBBSPost *post = self.tabDataList[row];
    return post;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case RowGroupInfo:
            return [GroupInfoView getViewHeight];
        case RowTopicHeader:
            return [BBSPostActionHeaderView getViewHeight];
        default:
        {
            PBBBSPost *post = [self postInIndexPath:indexPath];
            return [BBSPostCell getCellHeightWithBBSPost:post];
        }
    }
    return 0;
}

- (void)updateTopicHeader
{
    if(self.topicHeader == nil){
        self.topicHeader = [BBSPostActionHeaderView createView:self];
        [self.topicHeader updateleftName:NSLS(@"kLatest") rightName:NSLS(@"kMarked")];
    }
}

- (void)updateGroupInfo
{
    if (self.infoCell == nil) {
        self.infoCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GroupInfoCell"];
        GroupInfoView *infoView = [GroupInfoView infoViewWithGroup:_group];
        infoView.delegate = self;
        [self.infoCell.contentView addSubview:infoView];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    switch (row) {
        case RowGroupInfo:
        {
            [self updateGroupInfo];
            return self.infoCell;
        }
        case RowTopicHeader:
        {
            [self updateTopicHeader];
            return self.topicHeader;
        }
        default:
        {
            BBSPostCell *cell = [tableView dequeueReusableCellWithIdentifier:[BBSPostCell getCellIdentifier]];
            if (cell == nil) {
                cell = [BBSPostCell createCell:self];
            }
            PBBBSPost *post = [self postInIndexPath:indexPath];
            [cell updateCellWithBBSPost:post];
            return cell;
        }
    }
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

- (void)didClickSupportTabButton
{
    [self clickTab:MarkedTopic];
}
- (void)didClickCommentTabButton
{
    [self clickTab:NewestTopic];
}


@end
