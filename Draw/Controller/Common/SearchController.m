//
//  SearchController.m
//  Draw
//
//  Created by Gamy on 13-10-23.
//
//

#import "SearchController.h"
#import "SearchHistoryManager.h"

typedef enum{
    ShowResult = 0,
    ShowHistory = 1,
}SearchStatus;

@interface SearchController ()
{
    CGFloat originWidth;
}
@property (retain, nonatomic) IBOutlet UITextField *searchTextField;
@property (nonatomic, assign) SearchStatus status;
@property (nonatomic, retain) NSMutableArray *history;

- (IBAction)clickSearchButton:(id)sender;
- (IBAction)didKeyWordChanged:(id)sender;

@end

#define TAB_ID 100

@implementation SearchController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"SearchController" bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}


- (void)loadHistory
{
    self.history = [SearchHistoryManager getHistoryText:[self historyStoreKey]];
    if (self.history == nil) {
        self.history = [NSMutableArray array];
    }
    PPDebug(@"get history for key: %@, size = %d",[self historyStoreKey], [self.history count]);    
}

- (void)viewDidLoad
{
    [self setPullRefreshType:PullRefreshTypeFooter];
    [super viewDidLoad];
    [self loadHistory];
    if (self.titleView == nil) {
        self.titleView = [CommonTitleView createTitleView:self.view];
    }
    [self.titleView setTitle:[self headerTitle]];
    [self.titleView setTransparentStyle];
    originWidth = CGRectGetWidth(self.dataTableView.bounds);
    SET_INPUT_VIEW_STYLE(self.searchTextField);
    [self.searchTextField becomeFirstResponder];
    self.searchTextField.text = nil;
    [self.searchTextField setPlaceholder:[self searchTips]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [SearchHistoryManager resetHistory:self.history forKey:[self historyStoreKey]];
    [_searchTextField release];
    PPRelease(_history);
    [super dealloc];
}

#define TABLE_HEIGHT_HISTORY (ISIPAD? 450 : 130)
#define TABLE_HEIGHT_RESULT (CGRectGetHeight(self.view.bounds)-CGRectGetMinY(self.dataTableView.bounds))


- (void)reloadView
{
    [self.dataTableView reloadData];
    if (self.status == ShowHistory) {
        [self.dataTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        self.noMoreData = YES;
        [self.dataTableView updateWidth:CGRectGetWidth(self.searchTextField.bounds)];
        [self.dataTableView updateHeight:TABLE_HEIGHT_HISTORY];
    }else{
        [self.dataTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        self.noMoreData = ![self currentTab].hasMoreData;
        [self.dataTableView updateWidth:originWidth];
        [self.dataTableView updateHeight:TABLE_HEIGHT_RESULT];
    }
    [self.dataTableView updateCenterX:CGRectGetMidX(self.view.bounds)];
}

- (void)viewDidUnload {
    [self setSearchTextField:nil];
    [super viewDidUnload];
}
- (IBAction)clickSearchButton:(id)sender {
    NSString *text = self.searchTextField.text;
    if ([text length] != 0) {
        if ([self.history containsObject:text]) {
            [self.history removeObject:text];
        }
        [self.history insertObject:text atIndex:0];
        [self setStatus:ShowResult];
        [self.tabDataList removeAllObjects];
        [self reloadView];
        [self reloadTableViewDataSource];
    }
}

- (IBAction)didKeyWordChanged:(id)sender {
    PPDebug(@"<didKeyWordChanged>, text = %@", self.searchTextField.text);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self clickSearchButton:nil];
    return YES;
}


- (void)textFieldDidBeginEditing:(UITextField *)textFiel
{
    [self setStatus:ShowHistory];
    [self reloadView];
}


#pragma mark - table view delegate
- (id)dataForIndexPath:(NSIndexPath *)indexPath
{
    NSArray *dList = self.tabDataList;
    if (indexPath.row >= [dList count]) {
        return nil;
    }
    id data = [self.tabDataList objectAtIndex:indexPath.row];
    return data;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.status == ShowResult) {
        return [super tableView:tableView numberOfRowsInSection:section];
    }else{
        PPDebug(@"history count = %d", [self.history count]);
        return [self.history count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.status == ShowResult) {
        return [self heightForData:[self dataForIndexPath:indexPath]];
    }
    return (ISIPAD ? 60 :35);
}



- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (ShowResult == self.status) {
        return [self cellForData:[self dataForIndexPath:indexPath]];
    }else{
        NSString *identifier = @"history";
        UITableViewCell *cell = [theTableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
            cell.textLabel.font = CELL_NICK_FONT;
            cell.textLabel.textColor = COLOR_BROWN;
        }
        
        NSString *text = @"unknow";
        if ([self.history count] > indexPath.row) {
            text = self.history[indexPath.row];
        }
        [cell.textLabel setText:text];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.status == ShowResult) {
        [self didSelectedCellWithData:[self dataForIndexPath:indexPath]];
    }else{
        NSString *text = self.history[indexPath.row];
        [self setStatus:ShowResult];
        [self.searchTextField setText:text];
        [self clickSearchButton:nil];
    }
}

//delete history.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.status == ShowHistory;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLS(@"kDelete");
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.history removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}


- (NSInteger)tabCount
{
    return 1;
}
- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index
{
    return 15;
}
- (NSInteger)tabIDforIndex:(NSInteger)index
{
    return TAB_ID;
}
- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    [self.searchTextField resignFirstResponder];
    NSString *text = self.searchTextField.text;
    [self loadDataWithKey:text tabID:tabID];
}

//should be override.

- (void)loadDataWithKey:(NSString *)key tabID:(NSInteger)tabID
{
    
}
- (UITableViewCell *)cellForData:(id)data
{
    return nil;
}
- (CGFloat)heightForData:(id)data
{
    return 44;
}
- (void)didSelectedCellWithData:(id)data
{
    
}
- (NSString *)headerTitle
{
    return NSLS(@"kSearch");
}
- (NSString *)searchTips
{
    return nil;
}
- (NSString *)historyStoreKey
{
    return NSStringFromClass([self class]);
}


@end
