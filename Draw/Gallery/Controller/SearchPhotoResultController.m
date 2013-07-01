//
//  SearchPhotoResultController.m
//  Draw
//
//  Created by Kira on 13-6-17.
//
//

#import "SearchPhotoResultController.h"

#import "GoogleCustomSearchService.h"
#import "MWPhotoBrowser.h"
#import "SearchResultView.h"
#import "CommonSearchImageFilterView.h"
#import "PhotoEditView.h"

#import "UIImageView+WebCache.h"
#import "ImageSearchResult.h"
#import "GoogleCustomSearchNetworkConstants.h"
#import "MKBlockActionSheet.h"
#import "GalleryPicture.h"
#import "GalleryManager.h"
#import "CommonMessageCenter.h"
#import "GalleryService.h"
#import "GalleryController.h"
#import "Photo.pb.h"
#import "PPSmartUpdateData.h"
#import "PSCollectionViewCell.h"

#import "StorageManager.h"
#import "UserManager.h"

@interface SearchPhotoResultController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, GoogleCustomSearchServiceDelegate, MWPhotoBrowserDelegate, SearchResultViewDelegate> {

    ImageSearchResult* _currentResult;
}

@property (retain, nonatomic) NSDictionary* options;
@property (retain, nonatomic) NSString* searchText;
@property (retain, nonatomic) NSArray* initArray;

@end

@implementation SearchPhotoResultController

- (void)dealloc{
    [_options release];
    [_searchText release];
    [_initArray release];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataTableView.numColsPortrait = 2;
    [self didFinishLoadData:self.initArray];
//    [self finishLoadDataForTabID:[self currentTab].tabID resultList:self.initArray];
    // Do any additional setup after loading the view from its nib.
}

- (id)initWithKeyword:(NSString*)keyword
              options:(NSDictionary*)options
          resultArray:(NSArray *)array
{
    self = [super init];
    if (self) {
        self.searchText = keyword;
        self.options = options;
        self.initArray = array;
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)initTabList:(NSArray*)list
//{
//    TableTab * tab = [self currentTab];
//    if (tab.offset == 0) {
//        [tab.dataList removeAllObjects];
//    }
//    
//    if ([list count] == 0) {
//        tab.hasMoreData = NO;
//    }else{
//        tab.hasMoreData = YES;
//        [tab.dataList addObjectsFromArray:list];
//        tab.offset += tab.limit;//[tab.dataList count];
//    }
//    tab.status = TableTabStatusLoaded;
//    [self finishLoadDataForTabID:0 resultList:list];
//
//}

#define IMAGE_PER_LINE 2
#define IMAGE_HEIGHT  (ISIPAD?384:160)
#define RESULT_IMAGE_TAG_OFFSET 20130601

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return IMAGE_HEIGHT;
//}
//#pragma mark tab controller delegate
//
//- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell* cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell"];
//    if (cell == nil) {
//        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
//        for (int i = 0; i < IMAGE_PER_LINE; i ++) {
//            SearchResultView* resultView = [[[SearchResultView alloc] initWithFrame:CGRectMake(i*self.dataTableView.frame.size.width/IMAGE_PER_LINE, 0, self.dataTableView.frame.size.width/IMAGE_PER_LINE, IMAGE_HEIGHT)] autorelease];
//            resultView.tag = RESULT_IMAGE_TAG_OFFSET + i;
//            resultView.delegate = self;
//            
//            [cell.contentView addSubview:resultView];
//        }
//    }
//    for (int i = 0; i < IMAGE_PER_LINE; i ++) {
//        NSArray* list = [self tabDataList];
//        SearchResultView* resultView = (SearchResultView*)[cell viewWithTag:RESULT_IMAGE_TAG_OFFSET+i];
//        if (list.count > IMAGE_PER_LINE*indexPath.row+i) {
//            
//            ImageSearchResult* result = (ImageSearchResult*)[list objectAtIndex:IMAGE_PER_LINE*indexPath.row+i];
//            PPDebug(@"<ComomnSearchImageController>did search image %@",result.url);
//            [resultView updateWithResult:result];
//            resultView.hidden = NO;
//        } else {
//            resultView.hidden = YES;
//        }
//        
//    }
//    
//    return cell;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return ([[self tabDataList] count]+(IMAGE_PER_LINE-1))/IMAGE_PER_LINE ;
//}

//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
//{
//    [[GoogleCustomSearchService defaultService] searchImageBytext:searchBar.text imageSize:CGSizeMake(0, 0) imageType:nil startPage:0 paramDict:self.filter delegate:self];
//    //    self.dataList = [_imageSearcher searchImageBySize:CGSizeMake(0, 0) searchText:searchBar.text location:nil searchSite:nil startPage:0 maxResult:100];
//    [self.dataTableView reloadData];
//    [searchBar resignFirstResponder];
//}

- (NSInteger)numberOfViewsInCollectionView:(PSCollectionView *)collectionView
{
//    return 8;
    return self.dataList.count;
}

- (PSCollectionViewCell *)collectionView:(PSCollectionView *)collectionView viewAtIndex:(NSInteger)index {
    SearchResultView* cell = (SearchResultView*)[self.dataTableView dequeueReusableView];
    if (cell == nil) {
        cell = [[[SearchResultView alloc] init] autorelease];
    }
    ImageSearchResult* result = [self.dataList objectAtIndex:index];
    [cell updateWithResult:result];
    return cell;
}

- (CGFloat)heightForViewAtIndex:(NSInteger)index {
    //    NSDictionary *item = [self.items objectAtIndex:index];
    ImageSearchResult* result = [self.dataList objectAtIndex:index];
//    return 60;
    return [SearchResultView heightForViewWithPhotoWidth:result.width height:result.height inColumnWidth:self.dataTableView.colWidth];
}

- (void)collectionView:(PSCollectionView *)collectionView didSelectView:(PSCollectionViewCell *)view atIndex:(NSInteger)index {
    //    NSDictionary *item = [self.items objectAtIndex:index];
    ImageSearchResult* result = [self.dataList objectAtIndex:index];
    [self didClickSearchResult:result];
    // You can do something when the user taps on a collectionViewCell here
}

#pragma mark tab controller delegate

//- (NSInteger)tabCount
//{
//    return 1;
//}
//- (NSInteger)currentTabIndex
//{
//    return _defaultTabIndex;
//}
- (NSInteger)loadMoreLimit
{
    return 8;
}
- (int)maxDataCount
{
    return 56;
}

//- (NSInteger)tabIDforIndex:(NSInteger)index
//{
//    return index;
//}
- (void)serviceLoadServiceFromOffset:(int)offset
{
    [super serviceLoadServiceFromOffset:offset];
    if (self.searchText && self.searchText.length > 0) {
        [[GoogleCustomSearchService defaultService] searchImageBytext:self.searchText imageSize:CGSizeMake(0, 0) imageType:nil startPage:offset paramDict:self.options delegate:self];
    }
}

- (void)didSearchImageResultList:(NSMutableArray *)array resultCode:(NSInteger)resultCode
{
    if (resultCode == OLD_G_ERROR_SUCCESS) {
        [self didFinishLoadData:array];
    } else {
//        [self failLoadDataForTabID:[self currentTab].tabID];
        [self didFinishLoadDataError:resultCode];
    }
}


- (void)showSearhResult:(ImageSearchResult*)searchResult
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

- (void)saveSearchResult:(ImageSearchResult*)searchResult
{
    __block SearchPhotoResultController* cp = self;
    PhotoEditView* view = [PhotoEditView createViewWithPhoto:nil title:NSLS(@"kSetTag") confirmTitle:NSLS(@"kConfirm") resultBlock:^( NSSet *tagSet) {
        [cp didEditPictureInfo:tagSet
                          name:cp.searchText
                      imageUrl:searchResult.url
                         width:searchResult.width
                        height:searchResult.height];
    }];
    [view showInView:self.view];
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

enum {
    actionShowResult = 0,
    actionSaveResult,
};
#pragma mark - SearchResultView delegate
- (void)didClickSearchResult:(ImageSearchResult *)searchResult
{
    MKBlockActionSheet* actionSheet = [[MKBlockActionSheet alloc] initWithTitle:NSLS(@"kOperations") delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:NSLS(@"kShow"), NSLS(@"kFavorite"), nil];
    int index = [actionSheet addButtonWithTitle:NSLS(@"kCancel")];
    [actionSheet setCancelButtonIndex:index];
    __block SearchPhotoResultController* cp = self;
    [actionSheet setActionBlock:^(NSInteger buttonIndex){
        if (buttonIndex == actionSheet.cancelButtonIndex) {
            return ;
        }
        switch (buttonIndex) {
            case actionShowResult: {
                [cp showSearhResult:searchResult];
            } break;
            case actionSaveResult: {
                [cp saveSearchResult:searchResult];
            } break;
            default:
                break;
        }
    }];
    [actionSheet showInView:self.view];
    
}

//- (IBAction)clickFilter:(id)sender
//{
//    if (!_filter) {
//        self.filter = [[[NSMutableDictionary alloc] init] autorelease];
//    }
//    __block SearchPhotoResultController* cp = self;
//    SearchView* view = [SearchView createViewWithDefaultKeywords:self.keywords options:self.filter handler:^(NSString *searchText, NSDictionary *options) {
//        if (searchText && searchText.length > 0) {
//            cp.filter = options;
//            cp.searchText = searchText;
//            [cp reloadTableViewDataSource];
//        }
//    }];
//    [view showInView:self.view];
//}

//- (IBAction)clickGallery:(id)sender
//{
//    GalleryController* vc = [[[GalleryController alloc] init] autorelease];
//    [self.navigationController pushViewController:vc animated:YES];
//}

//- (void)didConfirmFilter:(NSDictionary *)filter
//{
//    self.filter = filter;
//    [self reloadTableViewDataSource];
//}

- (void)didEditPictureInfo:(NSSet *)tagSet
                      name:(NSString *)name
                  imageUrl:(NSString *)url
                     width:(float)width
                    height:(float)height
{
    [[GalleryService defaultService] addUserPhoto:url
                                             name:name
                                           tagSet:tagSet
                                            usage:[GameApp photoUsage]
                                            width:width
                                           heithg:height
                                      resultBlock:^(int resultCode, PBUserPhoto *photo) {
        if (resultCode == 0) {
            PPDebug(@"<didEditPictureInfo> favor image %@(%@) ,name = %@ with tag <%@>succ !", photo.url, photo.userPhotoId, photo.name,[photo.tagsList description]);
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kAddUserPhotoSucc") delayTime:1.5];
            
        } else {
            PPDebug(@"<didEditPictureInfo> err! code = %d", resultCode);
        }
        
    }];
    
    //for create test data
//    PBUserPhotoList_Builder* listBuilder;
//    StorageManager* manage = [[StorageManager alloc] initWithStoreType:StorageTypeTemp directoryName:@"testPhoto"];
//    NSData* data = [manage dataForKey:@"test2"];
//    if (data) {
//        PBUserPhotoList* list = [PBUserPhotoList parseFromData:data];
//        listBuilder = [PBUserPhotoList builderWithPrototype:list];
//    } else {
//        listBuilder = [PBUserPhotoList builder];
//    }
//    PBUserPhoto_Builder* builder = [PBUserPhoto builder];
//    [builder setUrl:url];
//    [builder setName:name];
//    for (NSString* str in [tagSet allObjects]) {
//        [builder addTags:str];
//    }
//    [builder setCreateDate:time(0)];
//    PBUserPhoto* photo = [builder build];
//    
//    [listBuilder addPhotoList:photo];
//    [listBuilder setUserId:[[UserManager defaultManager] userId]];
//    PBUserPhotoList* aList = [listBuilder build];
//    NSData* newData = [aList data];
//    [manage saveData:newData forKey:@"test2"];
//    PPDebug(@"<test> write image %@ succ!",url);
    
    //    PBUserPhoto_Builder* builder = [PBUserPhoto builder];
    
    
}

@end
