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

- (BOOL)isGroupTab:(NSInteger)tab
{
    if (tab == GroupTabFollow || tab == GroupTabTopic) {
        return NO;
    }
    return YES;
}

- (void)clickTabButton:(id)sender
{
    [currentTabButton setSelected:NO];
    UIButton *button = (UIButton *)sender;
    [button setSelected:YES];
    currentTabButton = button;
    if ([self isGroupTab:button.tag]) {
        //don't load data. just show the sub tab buttons.
        self.subTabsHolder.hidden = NO;
        [self.dataTableView updateOriginY:CGRectGetMaxY(self.subTabsHolder.frame)];
        [self.dataTableView updateHeight:(CGRectGetMinY(self.footerView.frame) - CGRectGetMaxY(self.subTabsHolder.frame))];
    }else{
        self.subTabsHolder.hidden = YES;
        [self.dataTableView updateOriginY:CGRectGetMinY(self.subTabsHolder.frame)];
        [self.dataTableView updateHeight:(CGRectGetMinY(self.footerView.frame) -CGRectGetMinY(self.subTabsHolder.frame))];
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

    PPDebug(@"click tab id = %d, title = %@", tab.tabID, tab.title);
    [self finishLoadDataForTabID:tabID resultList:nil];
    return;
    
    switch (tabID) {
        case GroupTabGroupFollow:
        case GroupTabGroupNew:
        case GroupTabGroupBalance:
        case GroupTabGroupActive:
        case GroupTabGroupFame:
            [[GroupService defaultService] getGroupsWithType:tabID offset:tab.offset limit:tab.limit callback:^(NSArray *list, NSError *error) {
                if (error) {
                    [self failLoadDataForTabID:tabID];
                    [DrawError postError:error];
                }else{
                    [self finishLoadDataForTabID:tabID resultList:list];
                }
            }];
            break;
        case GroupTabGroup:
            [self finishLoadDataForTabID:tabID resultList:nil];
            break;
        
        default:
            break;
    }
}

- (void)dealloc {
    [_subTabsHolder release];
    [_footerView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setFooterView:nil];
    [super viewDidUnload];
}
@end
