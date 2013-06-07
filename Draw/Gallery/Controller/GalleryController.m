//
//  GalleryController.m
//  Draw
//
//  Created by Kira on 13-6-7.
//
//

#import "GalleryController.h"
#import "GalleryService.h"
#import "MWPhotoBrowser.h"
#import "MKBlockActionSheet.h"

@interface GalleryController () {
    NSString* _currentImageUrl;
    
}

@property (retain, nonatomic) NSMutableSet* tagSet;

@end

@implementation GalleryController

- (void)dealloc
{
    [_tagSet release];
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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define IMAGE_PER_LINE 3
#define IMAGE_HEIGHT  80

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell"];
//    if (cell == nil) {
//        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
//        for (int i = 0; i < IMAGE_PER_LINE; i ++) {
//            SearchResultView* resultView = [[[SearchResultView alloc] initWithFrame:CGRectMake(i*self.dataTableView.frame.size.width/IMAGE_PER_LINE, 0, self.dataTableView.frame.size.width/IMAGE_PER_LINE, IMAGE_HEIGHT)] autorelease];
//            resultView.tag = RESULT_IMAGE_TAG_OFFSET + i;
//            resultView.delegate = self;
//            
//            [cell addSubview:resultView];
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
//            
//        }
//        
//    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return IMAGE_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self tabDataList] count]/IMAGE_PER_LINE +1;
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

- (void)loadTestData
{
    
}

- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    [self loadTestData];
    [[GalleryService defaultService] getUserPhotoWithTagSet:nil offset:[self currentTab].offset limit:15 resultBlock:^(int resultCode, NSArray *resultArray) {
        //
    }];
    
}


#pragma mark - mwPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return 1;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (_currentImageUrl) {
        return [MWPhoto photoWithURL:[NSURL URLWithString:_currentImageUrl]];
    }
    return nil;
    
}

enum {
    actionShowResult = 0,
    actionSaveResult,
};
//#pragma mark - SearchResultView delegate
//- (void)didClickSearchResult:(ImageSearchResult *)searchResult
//{
//    MKBlockActionSheet* actionSheet = [[MKBlockActionSheet alloc] initWithTitle:NSLS(@"kShareAction") delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:NSLS(@"kShow"), NSLS(@"kSave"), nil];
//    int index = [actionSheet addButtonWithTitle:NSLS(@"kCancel")];
//    [actionSheet setCancelButtonIndex:index];
//    __block GalleryController* cp = self;
//    [actionSheet setActionBlock:^(NSInteger buttonIndex){
//        if (buttonIndex == actionSheet.cancelButtonIndex) {
//            return ;
//        }
//        switch (buttonIndex) {
//            case actionShowResult: {
//            } break;
//            case actionSaveResult: {
//            } break;
//            default:
//                break;
//        }
//    }];
//    [actionSheet showInView:self.view];
//    
//}


//#pragma mark - GalleryPictureInfoEditView delegate
//- (void)didEditPictureInfo:(NSSet *)tagSet name:(NSString *)name imageUrl:(NSString *)url
//{
//    [[GalleryService defaultService] favorImage:url name:name tagSet:tagSet resultBlock:^(int resultCode) {
//        PPDebug(@"<didEditPictureInfo> favor image %@ with tag <%@>succ !", url, [tagSet description]);
//    }];
//}


@end
