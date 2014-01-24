//
//  SingleTabController.m
//  Draw
//
//  Created by Gamy on 14-1-21.
//
//

#import "SingleTabController.h"
#import "UIImageView+WebCache.h"

@interface SingleTabController ()

@end

@implementation SingleTabController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#define TAB_ID 20140121

- (void)initTitleViewAndTableView
{
    [self.titleView removeFromSuperview];
    [self.dataTableView removeFromSuperview];
    
    self.titleView = [CommonTitleView createTitleView:self.view];
    [self.titleView setRightButtonAsRefresh];
    [self.titleView setRightButtonSelector:@selector(clickRefreshButton:)];
    
    self.dataTableView = [[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain] autorelease];
    self.dataTableView.dataSource = self;
    self.dataTableView.delegate = self;
    self.dataTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.dataTableView.backgroundColor = [UIColor clearColor];
    
    [self.dataTableView setAutoresizingMask:((0x1 << 6) - 1)];
    [self.dataTableView updateOriginY:CGRectGetMaxY(self.titleView.frame)];
    CGFloat height = CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.titleView.bounds);
    [self.dataTableView updateHeight:height];
    [self.view addSubview:self.dataTableView];

}

- (void)viewDidLoad
{
    [self initTitleViewAndTableView];
    [super viewDidLoad];    
    [self clickTab:TAB_ID];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (NSInteger)tabIDforIndex:(NSInteger)index
{
    return TAB_ID;
}
- (NSString *)tabTitleforIndex:(NSInteger)index
{
    return @"";
}

- (void)serviceLoadDataWithOffset:(NSInteger)offset
                            limit:(NSInteger)limit
                         callback:(void (^)(NSInteger code, NSArray *list))callback
{
    
}

- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    TableTab *tab = [_tabManager tabForID:tabID];
    [self serviceLoadDataWithOffset:tab.offset
                              limit:tab.limit
                           callback:^(NSInteger code, NSArray *list) {
        if (code == 0) {
            [self finishLoadDataForTabID:tabID resultList:list];
        }else{
            [self failLoadDataForTabID:tabID];
        }
    }];
}

- (NSString *)noDataTips
{
    return NSLS(@"kNoData");
}
- (NSString *)tabNoDataTipsforIndex:(NSInteger)index
{
    return [self noDataTips];
}


@end
