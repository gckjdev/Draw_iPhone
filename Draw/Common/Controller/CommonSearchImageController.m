//
//  CommonSearchImageController.m
//  Draw
//
//  Created by Kira on 13-6-1.
//
//

#import "CommonSearchImageController.h"
#import "UIImageView+WebCache.h"
#import "ImageSearch.h"
#import "ImageSearchResult.h"
#import "GoogleCustomSearchNetworkConstants.h"
#import "CommonSearchImageFilterView.h"

@interface CommonSearchImageController () {
    ImageSearch* _imageSearcher;
    ImageSearchResult* _currentResult;
}

@property (retain, nonatomic) NSDictionary* filter;

@end

@implementation CommonSearchImageController

- (void)dealloc
{
    [_filter release];
    [_searchBar release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        _imageSearcher = [[ImageSearch alloc] init];
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

#define IMAGE_PER_LINE 3
#define IMAGE_HEIGHT  80
#define RESULT_IMAGE_TAG_OFFSET 20130601

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return IMAGE_HEIGHT;
}
#pragma mark tab controller delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
        for (int i = 0; i < IMAGE_PER_LINE; i ++) {
            SearchResultView* resultView = [[[SearchResultView alloc] initWithFrame:CGRectMake(i*self.dataTableView.frame.size.width/IMAGE_PER_LINE, 0, self.dataTableView.frame.size.width/IMAGE_PER_LINE, IMAGE_HEIGHT)] autorelease];
            resultView.tag = RESULT_IMAGE_TAG_OFFSET + i;
            resultView.delegate = self;
            
            [cell addSubview:resultView];
        }
    }
    for (int i = 0; i < IMAGE_PER_LINE; i ++) {
        NSArray* list = [self tabDataList];
        SearchResultView* resultView = (SearchResultView*)[cell viewWithTag:RESULT_IMAGE_TAG_OFFSET+i];
        if (list.count > IMAGE_PER_LINE*indexPath.row+i) {
            
            ImageSearchResult* result = (ImageSearchResult*)[list objectAtIndex:IMAGE_PER_LINE*indexPath.row+i];
            PPDebug(@"<ComomnSearchImageController>did search image %@",result.url);
            [resultView updateWithResult:result];
            
        }
        
    }
    
    return cell;
}

- (void)didClickResultImage:(id)sender
{
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self tabDataList] count]/IMAGE_PER_LINE +1;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [[GoogleCustomSearchService defaultService] searchImageBytext:searchBar.text imageSize:CGSizeMake(0, 0) imageType:nil startPage:0 paramDict:self.filter delegate:self];
//    self.dataList = [_imageSearcher searchImageBySize:CGSizeMake(0, 0) searchText:searchBar.text location:nil searchSite:nil startPage:0 maxResult:100];
    [self.dataTableView reloadData];
    [searchBar resignFirstResponder];
}

#pragma mark tab controller delegate

- (NSInteger)tabCount
{
    return 1;
}
- (NSInteger)currentTabIndex
{
    return _defaultTabIndex;
}
- (NSInteger)fetchDataLimitForTabIndex:(NSInteger)index
{
    return 8;
}
- (NSInteger)tabIDforIndex:(NSInteger)index
{
    return index;
}

- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    if (self.searchBar.text && self.searchBar.text.length > 0) {
        [[GoogleCustomSearchService defaultService] searchImageBytext:self.searchBar.text imageSize:CGSizeMake(0, 0) imageType:nil startPage:[[self currentTab] offset] paramDict:self.filter delegate:self];
    }

}

- (void)didSearchImageResultList:(NSMutableArray *)array resultCode:(NSInteger)resultCode
{
    if (resultCode == OLD_G_ERROR_SUCCESS) {
        [self finishLoadDataForTabID:[self currentTab].tabID resultList:array];
    } else {
        [self failLoadDataForTabID:[self currentTab].tabID];
    }
}

#pragma mark - mwPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return 1;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (_currentResult) {
        return [MWPhoto photoWithURL:[NSURL URLWithString:_currentResult.url]];
    }
    return nil;
    
}

#pragma mark - SearchResultView delegate
- (void)didClickSearchResult:(ImageSearchResult *)searchResult
{
    _currentResult = searchResult;
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    // Modal
    browser.canSave = NO;
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:nc animated:YES];
    [browser release];
    [nc release];
    
}

- (IBAction)clickFilter:(id)sender
{
    if (!_filter) {
        self.filter = [[[NSMutableDictionary alloc] init] autorelease];
    }
    CommonSearchImageFilterView* view = [CommonSearchImageFilterView createViewWithFilter:_filter delegate:self];
    [view showInView:self.view];
}

- (void)didConfirmFilter:(NSDictionary *)filter
{
    self.filter = filter;
    [self reloadTableViewDataSource];
}


@end