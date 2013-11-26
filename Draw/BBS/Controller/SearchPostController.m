//
//  SearchPostController.m
//  Draw
//
//  Created by Gamy on 13-10-23.
//
//

#import "SearchPostController.h"
#import "BBSViewManager.h"
#import "BBSPostDetailController.h"
#import "BBSPostCell.h"

@interface SearchPostController ()

@end


@implementation SearchPostController

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

- (void)dealloc {
    [super dealloc];
}
- (void)viewDidUnload {
    [super viewDidUnload];
}

- (BBSService *)bbsService
{
    return [BBSService defaultService];
}

- (void)loadDataWithKey:(NSString *)key tabID:(NSInteger)tabID
{
    [self showActivityWithText:NSLS(@"kSearching")];
    TableTab *tab = [_tabManager tabForID:tabID];
    [[self bbsService] searchPostListByKeyWord:key
                                        offset:tab.offset
                                         limit:tab.limit
                                       hanlder:^(NSInteger resultCode, NSArray *postList, NSInteger tag) {
        [self hideActivity];
        if (resultCode == 0) {
            [self finishLoadDataForTabID:tabID resultList:postList];
        }else{
            [self failLoadDataForTabID:tabID];
        }
    }];

}


- (CGFloat)heightForData:(id)data
{
    PBBBSPost *post = data;
	return [BBSPostCell getCellHeightWithBBSPost:post];

}
- (void)didSelectedCellWithData:(id)data
{
    PBBBSPost *post = data;
    [BBSPostDetailController enterPostDetailControllerWithPost:post
                                                fromController:self
                                                      animated:YES];

}
- (UITableViewCell *)cellForData:(id)data
{
    NSString *CellIdentifier = [BBSPostCell getCellIdentifier];
	BBSPostCell *cell = [self.dataTableView
                         dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [BBSPostCell createCell:self];
	}
    PBBBSPost *post = data;
    [cell updateCellWithBBSPost:post];
    cell.backgroundColor = [UIColor clearColor];
	return cell;
}

- (NSString *)headerTitle
{
    return NSLS(@"kSearch");
}
- (NSString *)searchTips
{
    return NSLS(@"kBBSSearchPlaceholder");
}
- (NSString *)historyStoreKey
{
    return @"BBSSearchHistory";
}


@end
