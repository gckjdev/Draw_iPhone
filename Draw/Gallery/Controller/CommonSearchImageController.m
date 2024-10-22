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
#import "SearchView.h"
#import "MKBlockActionSheet.h"
#import "GalleryPicture.h"
#import "GalleryManager.h"
#import "CommonMessageCenter.h"
#import "GalleryService.h"
#import "GalleryController.h"
#import "Photo.pb.h"
#import "PPSmartUpdateData.h"

#import "StorageManager.h"
#import "UserManager.h"

@interface CommonSearchImageController () {
    ImageSearch* _imageSearcher;
    ImageSearchResult* _currentResult;
}

@property (retain, nonatomic) NSDictionary* filter;
@property (retain, nonatomic) NSArray* keywords;
@property (retain, nonatomic) NSString* searchText;
@property (retain, nonatomic) PPSmartUpdateData* smartData;

@end

@implementation CommonSearchImageController

- (void)dealloc
{
    [_filter release];
//    [_searchBar release];
    [_keywords release];
    [_searchText release];
    [_smartData release];
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
    [self updateKeywords];
    // Do any additional setup after loading the view from its nib.
}

#define KEYWORD_FILE  ([LocaleUtils isChinese]?@"keywords.txt":@"keywords_en.txt")
#define BUNDLE_FILE     ([LocaleUtils isChinese]?@"keywords.txt":@"keywords_en.txt")
#define INIT_VER    @"1.0"
- (void)updateKeywords
{
    
    self.smartData = [[[PPSmartUpdateData alloc] initWithName:KEYWORD_FILE type:SMART_UPDATE_DATA_TYPE_TXT bundlePath:BUNDLE_FILE initDataVersion:INIT_VER] autorelease];
    
    [_smartData checkUpdateAndDownload:^(BOOL isAlreadyExisted, NSString *dataFilePath) {
        PPDebug(@"checkUpdateAndDownload successfully");
        [self loadKeywords];
    } failureBlock:^(NSError *error) {
        PPDebug(@"checkUpdateAndDownload failure error=%@", [error description]);
        [self loadKeywords];
    }];
}

- (void)loadKeywords
{
    NSError* err;
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8);
    NSString* fileStr = [NSString stringWithContentsOfFile:_smartData.dataFilePath encoding:enc error:&err];
    self.keywords = [fileStr componentsSeparatedByString:@"$"];
    [self clickFilter:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define IMAGE_PER_LINE 2
#define IMAGE_HEIGHT  (ISIPAD?384:160)
#define RESULT_IMAGE_TAG_OFFSET 20130601

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return IMAGE_HEIGHT;
}
#pragma mark tab controller delegate

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
        for (int i = 0; i < IMAGE_PER_LINE; i ++) {
            SearchResultView* resultView = [[[SearchResultView alloc] initWithFrame:CGRectMake(i*self.dataTableView.frame.size.width/IMAGE_PER_LINE, 0, self.dataTableView.frame.size.width/IMAGE_PER_LINE, IMAGE_HEIGHT)] autorelease];
            resultView.tag = RESULT_IMAGE_TAG_OFFSET + i;
            resultView.delegate = self;
            
            [cell.contentView addSubview:resultView];
        }
    }
    for (int i = 0; i < IMAGE_PER_LINE; i ++) {
        NSArray* list = [self tabDataList];
        SearchResultView* resultView = (SearchResultView*)[cell viewWithTag:RESULT_IMAGE_TAG_OFFSET+i];
        if (list.count > IMAGE_PER_LINE*indexPath.row+i) {
            
            ImageSearchResult* result = (ImageSearchResult*)[list objectAtIndex:IMAGE_PER_LINE*indexPath.row+i];
            PPDebug(@"<ComomnSearchImageController>did search image %@",result.url);
            [resultView updateWithResult:result];
            resultView.hidden = NO;
        } else {
            resultView.hidden = YES;
        }
        
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ([[self tabDataList] count]+(IMAGE_PER_LINE-1))/IMAGE_PER_LINE ;
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
    if (self.searchText && self.searchText.length > 0) {
        [[GoogleCustomSearchService defaultService] searchImageBytext:self.searchText imageSize:CGSizeMake(0, 0) imageType:nil startPage:[[self currentTab] offset] paramDict:self.filter delegate:self];
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
    __block CommonSearchImageController *cp = self;
    PhotoEditView* view = [PhotoEditView createViewWithPhoto:nil editName:YES resultBlock:^( NSSet *tagSet) {
        [self didEditPictureInfo:tagSet name:cp.searchText imageUrl:searchResult.url];
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
    MKBlockActionSheet* actionSheet = [[MKBlockActionSheet alloc] initWithTitle:NSLS(@"kOperations") delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:NSLS(@"kShow"), NSLS(@"kSave"), nil];
    int index = [actionSheet addButtonWithTitle:NSLS(@"kCancel")];
    [actionSheet setCancelButtonIndex:index];
    __block CommonSearchImageController* cp = self;
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

- (IBAction)clickFilter:(id)sender
{
    if (!_filter) {
        self.filter = [[[NSMutableDictionary alloc] init] autorelease];
    }
    __block CommonSearchImageController* cp = self;
    SearchView* view = [SearchView createViewWithDefaultKeywords:self.keywords options:self.filter handler:^(NSString *searchText, NSDictionary *options) {
        if (searchText && searchText.length > 0) {
            cp.filter = options;
            cp.searchText = searchText;
            [cp reloadTableViewDataSource];
        }
    }];
    [view showInView:self.view];
}

- (IBAction)clickGallery:(id)sender
{
    GalleryController* vc = [[[GalleryController alloc] init] autorelease];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didConfirmFilter:(NSDictionary *)filter
{
    self.filter = filter;
    [self reloadTableViewDataSource];
}

- (void)didEditPictureInfo:(NSSet *)tagSet name:(NSString *)name imageUrl:(NSString *)url
{
    [[GalleryService defaultService] addUserPhoto:url name:name tagSet:tagSet usage:PBPhotoUsageForPs resultBlock:^(int resultCode, PBUserPhoto *photo) {
        if (resultCode == 0) {
            PPDebug(@"<didEditPictureInfo> favor image %@(%@) ,name = %@ with tag <%@>succ !", photo.url, photo.userPhotoId, photo.name,[photo.tagsList description]);
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kAddUserPhotoSucc") delayTime:1.5];
            
        } else {
            PPDebug(@"<didEditPictureInfo> err! code = %d", resultCode);
        }
        
    }];
    
    //for create test data
    PBUserPhotoList_Builder* listBuilder;
    StorageManager* manage = [[StorageManager alloc] initWithStoreType:StorageTypeTemp directoryName:@"testPhoto"];
    NSData* data = [manage dataForKey:@"test2"];
    if (data) {
        PBUserPhotoList* list = [PBUserPhotoList parseFromData:data];
        listBuilder = [PBUserPhotoList builderWithPrototype:list];
    } else {
        listBuilder = [PBUserPhotoList builder];
    }
    PBUserPhoto_Builder* builder = [PBUserPhoto builder];
    [builder setUrl:url];
    [builder setName:name];
    for (NSString* str in [tagSet allObjects]) {
        [builder addTags:str];
    }
    [builder setCreateDate:time(0)];
    PBUserPhoto* photo = [builder build];
    
    [listBuilder addPhotoList:photo];
    [listBuilder setUserId:[[UserManager defaultManager] userId]];
    PBUserPhotoList* aList = [listBuilder build];
    NSData* newData = [aList data];
    [manage saveData:newData forKey:@"test2"];
    PPDebug(@"<test> write image %@ succ!",url);
    
//    PBUserPhoto_Builder* builder = [PBUserPhoto builder];


}


@end
