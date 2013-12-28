//
//  SearchGroupController.m
//  Draw
//
//  Created by Gamy on 13-11-28.
//
//

#import "SearchGroupController.h"
#import "GroupService.h"
#import "GroupCell.h"
#import "GroupTopicController.h"

@interface SearchGroupController ()

@end

@implementation SearchGroupController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadDataWithKey:(NSString *)key tabID:(NSInteger)tabID
{
    TableTab *tab = [_tabManager tabForID:tabID];
    
    [self showActivityWithText:NSLS(@"kSearching")];
    [[GroupService defaultService] searchGroupsByKeyword:key offset:tab.offset limit:tab.limit callback:^(NSArray *list, NSError *error) {
        [self hideActivity];
        if (!error) {
            [self finishLoadDataForTabID:tabID resultList:list];
        }else{
            [self failLoadDataForTabID:tabID];
        }
    }];
}

- (UITableViewCell *)cellForData:(id)data
{
    NSString *identifier = [GroupCell getCellIdentifier];
    GroupCell *cell = [self.dataTableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [GroupCell createCell:nil];
        [cell setCellInfo:data];
    }
    return cell;
}
- (CGFloat)heightForData:(id)data
{
    return [GroupCell getCellHeight];
}
- (void)didSelectedCellWithData:(id)data
{
    [GroupTopicController enterWithGroup:data fromController:self];
}
- (NSString *)headerTitle
{
    return NSLS(@"kSearchGroup");
}
- (NSString *)searchTips
{
    return NSLS(@"kSearchGroupTips");
}
- (NSString *)historyStoreKey
{
    return @"GroupSearchHistory";
}


@end
