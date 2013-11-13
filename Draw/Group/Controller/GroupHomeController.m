//
//  GroupHomeController.m
//  Draw
//
//  Created by Gamy on 13-11-5.
//
//

#import "GroupHomeController.h"
#import "GroupService.h"
#import "DrawError.h"
#import "GroupManager.h"
#import "GroupCell.h"

typedef enum{
    GroupTabGroup = 100,
    GroupTabTopic = 101,
    GroupTabFollow = 102,    

    GroupTabGroupFollow = GetGroupListTypeFollow,
    GroupTabGroupNew = GetGroupListTypeNew,
    GroupTabGroupBalance = GetGroupListTypeBalance,
    GroupTabGroupActive = GetGroupListTypeActive,
    GroupTabGroupFame = GetGroupListTypeFame,
    
}GroupTab;

@interface GroupHomeController ()
{
    UIButton *currentTabButton;
    UIButton *currentGroupSubButton;
}
@end



@implementation GroupHomeController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initTabButtons
{
    NSInteger count = [self tabCount];
    for (int i = 0; i < count; ++ i) {
        GroupTab tab = [self tabIDforIndex:i];
        if ([self isSubGroupTab:tab]) {
            UIButton *button = (id)[self.subTabsHolder viewWithTag:tab];
            SET_BUTTON_SQUARE_STYLE_YELLOW(button);
            [button setTitleColor:COLOR_WHITE forState:UIControlStateNormal];
            [button setBackgroundImage:IMAGE_FROM_COLOR(COLOR_YELLOW) forState:UIControlStateSelected];
        }else{
            UIButton *button = (id)[self.tabsHolderView viewWithTag:tab];
            SET_BUTTON_AS_COMMON_TAB_STYLE(button);
        }
    }
}

- (UIButton *)defaultTabButton
{
    return (id)[self.tabsHolderView viewWithTag:GroupTabGroup];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.titleView setTitle:NSLS(@"kGroup")];
    [self.titleView setTarget:self];
    [self.titleView setBackButtonSelector:@selector(clickBack:)];
    [self initTabButtons];
    [self clickTabButton:[self defaultTabButton]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)isGroupTab:(NSInteger)tab
{
    if (tab == GroupTabFollow || tab == GroupTabTopic) {
        return NO;
    }
    return YES;
}
- (BOOL)isSubGroupTab:(NSInteger)tab
{
    NSArray *tabs =@[
                    @(GroupTabGroupFollow),
                    @(GroupTabGroupNew),
                    @(GroupTabGroupBalance),
                    @(GroupTabGroupActive),
                    @(GroupTabGroupFame)];
    return [tabs containsObject:@(tab)];
}

- (GroupTab)defaultGroupTab
{
    return GroupTabGroupFame;
}

- (void)clickTabButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (button == currentTabButton || button == currentGroupSubButton) {
        return;
    }
    [button setSelected:YES];
    NSInteger tag = button.tag;
    if (![self isSubGroupTab:tag]) {
        [currentTabButton setSelected:NO];
        currentTabButton = button;
    }

    CGFloat originHeight = CGRectGetHeight(self.dataTableView.frame);
    CGFloat newHeight = originHeight;
    
    if ([self isGroupTab:tag]) {
        //don't load data. just show the sub tab buttons.
        self.subTabsHolder.hidden = NO;
        [self.dataTableView updateOriginY:CGRectGetMaxY(self.subTabsHolder.frame)];
        newHeight = (CGRectGetMinY(self.footerView.frame) - CGRectGetMaxY(self.subTabsHolder.frame));
        [self.dataTableView updateHeight:newHeight];
        if ([self isSubGroupTab:tag]) {
            [currentGroupSubButton setSelected:NO];
            currentGroupSubButton = sender;
            [self clickTab:tag];
        }else{
            if (!currentGroupSubButton) {
                [self clickTab:[self defaultGroupTab]];
                currentGroupSubButton = (id)[self.subTabsHolder viewWithTag:[self defaultGroupTab]];
            }else{
                [self clickTab:currentGroupSubButton.tag];
            }
        }
        currentGroupSubButton.selected = YES;
    }else{
        self.subTabsHolder.hidden = YES;
        [self.dataTableView updateOriginY:CGRectGetMinY(self.subTabsHolder.frame)];
        newHeight = (CGRectGetMinY(self.footerView.frame) -CGRectGetMinY(self.subTabsHolder.frame));
        [self.dataTableView updateHeight:newHeight];
        [self clickTab:button.tag];
    }
}

- (NSInteger)tabCount
{
    return 8;
}
- (NSInteger)currentTabIndex
{
    return 0;
}
- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index
{
    return 20;
}
- (NSInteger)tabIDforIndex:(NSInteger)index
{
    NSInteger tabs[] = {
    GroupTabGroup,
    GroupTabTopic,
    GroupTabFollow,
        
    GroupTabGroupFollow,
    GroupTabGroupNew,
    GroupTabGroupBalance,
    GroupTabGroupActive,
    GroupTabGroupFame
    };
    return tabs[index];
}

- (NSString *)tabTitleforIndex:(NSInteger)index
{
    NSString *titles[]={
        NSLS(@"kGroupTabGroup"),
        NSLS(@"kGroupTabTopic"),
        NSLS(@"kGroupTabFollow"),
        NSLS(@"kGroupTabGroupFollow"),
        NSLS(@"kGroupTabGroupNew"),
        NSLS(@"kGroupTabGroupBalance"),
        NSLS(@"kGroupTabGroupActive"),
        NSLS(@"kGroupTabGroupFame")};
    return titles[index];
}


- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    //test
    TableTab *tab = [_tabManager tabForID:tabID];

//    PPDebug(@"click tab id = %d, title = %@", tab.tabID, tab.title);
//    [self finishLoadDataForTabID:tabID resultList:nil];
//    return;
    
    switch (tabID) {
        case GroupTabGroupFollow:
        case GroupTabGroupNew:
        case GroupTabGroupBalance:
        case GroupTabGroupActive:
        case GroupTabGroupFame:
            [[GroupService defaultService] getGroupsWithType:tabID
                                                      offset:tab.offset
                                                       limit:tab.limit
                                                    callback:^(NSArray *list, NSError *error) {
                if (error) {
                    [self failLoadDataForTabID:tabID];
                    [DrawError postError:error];
                }else{
                    PPDebug(@"loaded groups, tab = %d, list count = %d", tabID, [list count]);
                    [self finishLoadDataForTabID:tabID resultList:list];
                }
            }];
            break;
        case GroupTabGroup:
            [self finishLoadDataForTabID:tabID resultList:nil];
//            break;
        case GroupTabFollow:
            //TODO get follow topic
//            break;
        case GroupTabTopic:
            //TODO get new topic.
//            break;
        default:
            [self finishLoadDataForTabID:tabID resultList:nil];
            break;
    }
}

- (void)detailFooterView:(DetailFooterView *)footer
        didClickAtButton:(UIButton *)button
                    type:(FooterType)type
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [GroupCell getCellHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [GroupCell getCellIdentifier];
    GroupCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [GroupCell createCell:self];
    }
    PBGroup *group = [self.tabDataList objectAtIndex:indexPath.row];
    [cell setCellInfo:group];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PBGroup *group = [self.tabDataList objectAtIndex:indexPath.row];
    if (group) {        
        //TODO enter group detail controller.
    }

}

SET_CELL_BG_IN_CONTROLLER

- (void)dealloc {
    [_subTabsHolder release];
    [_footerView release];
    [_tabsHolderView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setFooterView:nil];
    [self setTabsHolderView:nil];
    [super viewDidUnload];
}
@end
