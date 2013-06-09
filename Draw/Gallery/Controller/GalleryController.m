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
#import "Photo.pb.h"
#import "StorageManager.h"
//#import "SearchResultView.h"
#import "CommonMessageCenter.h"

@interface GalleryController () {
    NSString* _currentImageUrl;
    
}

@property (retain, nonatomic) NSSet* tagSet;

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
    [self serviceLoadDataForTabID:[self currentTab].tabID];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define IMAGE_PER_LINE 3
#define IMAGE_HEIGHT  110
#define RESULT_IMAGE_TAG_OFFSET 9999
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
        for (int i = 0; i < IMAGE_PER_LINE; i ++) {
            UserPhotoView* photoView = [UserPhotoView createViewWithPhoto:nil delegate:self];
            
            photoView.tag = RESULT_IMAGE_TAG_OFFSET + i;
//            resultView.delegate = self;
            
            [cell addSubview:photoView];
            [photoView setFrame:CGRectMake(i*self.dataTableView.frame.size.width/IMAGE_PER_LINE, 0, self.dataTableView.frame.size.width/IMAGE_PER_LINE, cell.bounds.size.height)];
        }
    }
    for (int i = 0; i < IMAGE_PER_LINE; i ++) {
        NSArray* list = [self tabDataList];
        UserPhotoView* photoView = (UserPhotoView*)[cell viewWithTag:RESULT_IMAGE_TAG_OFFSET+i];
        if (list.count > IMAGE_PER_LINE*indexPath.row+i) {
            
            PBUserPhoto* result = (PBUserPhoto*)[list objectAtIndex:IMAGE_PER_LINE*indexPath.row+i];
            PPDebug(@"<ComomnSearchImageController>did search image %@",result.url);
            [photoView updateWithUserPhoto:result];
            photoView.hidden = NO;
        } else {
            photoView.hidden = YES;
        }
        
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return IMAGE_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ([[self tabDataList] count]+(IMAGE_PER_LINE-1))/IMAGE_PER_LINE ;
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
    StorageManager* manage = [[StorageManager alloc] initWithStoreType:StorageTypeTemp directoryName:@"testPhoto"];
    NSData* data = [manage dataForKey:@"test2"];
    if (data) {
        PBUserPhotoList* list = [PBUserPhotoList parseFromData:data];
        
        [self finishLoadDataForTabID:[self currentTab].tabID resultList:list.photoListList];
    } 
}

- (void)serviceLoadDataForTabID:(NSInteger)tabID
{
    
    [[GalleryService defaultService] getUserPhotoWithTagSet:self.tagSet usage:PBPhotoUsageForPs offset:[self currentTab].tabID limit:[self fetchDataLimitForTabIndex:[self currentTab].tabID] resultBlock:^(int resultCode, NSArray *resultArray) {
        [self finishLoadDataForTabID:[self currentTab].tabID resultList:resultArray];
//        [self loadTestData];
    }];
    
}

- (void)showPhoto:(PBUserPhoto*)photo
{
    _currentImageUrl = photo.url;
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    // Modal
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:nc animated:YES];
    [browser release];
    [nc release];
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
    actionEdit,
    actionDelete,
};
#pragma mark - UserPhotoView delegate
- (void)didClickPhoto:(PBUserPhoto *)photo
{
    MKBlockActionSheet* actionSheet = [[MKBlockActionSheet alloc] initWithTitle:NSLS(@"kShareAction") delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:NSLS(@"kShow"), NSLS(@"kEdit"), NSLS(@"kDelete"), nil];
    int index = [actionSheet addButtonWithTitle:NSLS(@"kCancel")];
    [actionSheet setCancelButtonIndex:index];
    __block GalleryController* cp = self;
    [actionSheet setActionBlock:^(NSInteger buttonIndex){
        if (buttonIndex == actionSheet.cancelButtonIndex) {
            return ;
        }
        switch (buttonIndex) {
            case actionShowResult: {
                [cp showPhoto:photo];
            } break;
            case actionEdit: {
                [cp editPhoto:photo];
            } break;
            case actionDelete: {
                [cp deletePhoto:photo];
            } break;
            default:
                break;
        }
    }];
    [actionSheet showInView:self.view];
    
}

- (void)deletePhoto:(PBUserPhoto*)photo
{
    [[GalleryService defaultService] deleteUserPhoto:photo.userPhotoId usage:PBPhotoUsageForPs resultBlock:^(int resultCode) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kDeletePhotoSucc") delayTime:2];
    }];
}

- (void)editPhoto:(PBUserPhoto*)photo
{
    PhotoEditView* view = [PhotoEditView createViewWithPhoto:photo editName:YES resultBlock:^(NSString *name, NSSet *tagSet) {
        [[GalleryService defaultService] updateUserPhoto:photo.userPhotoId photoUrl:photo.url name:name tagSet:tagSet resultBlock:^(int resultCode, PBUserPhoto* photo) {
            PPDebug(@"<editPhoto> photo id = %@, name = %@, tags = <%@>", photo.photoId, name, [tagSet description]);
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kEditPhotoSucc") delayTime:2];
        }];
    }];
    [view showInView:self.view];
}


- (IBAction)clickFilterUserPhoto:(id)sender
{
    PBUserPhoto* tempPhoto = nil;
    if (self.tagSet) {
        PBUserPhoto_Builder* builder = [PBUserPhoto builder];
        for (NSString* tag in self.tagSet) {
            [builder addTags:tag];
        }
        [builder setUserId:@""];
        [builder setPhotoId:@""];
        [builder setUserPhotoId:@""];
        tempPhoto = [builder build];
    }
    
    __block GalleryController* cp = self;
    PhotoEditView* view = [PhotoEditView createViewWithPhoto:tempPhoto editName:NO resultBlock:^(NSString *name, NSSet *tagSet) {
        cp.tagSet = tagSet;
        [cp reloadTableViewDataSource];
    }];
    [view showInView:self.view];
}

//#pragma mark - PhotoEditView delegate
//- (void)didEditPictureInfo:(NSSet *)tagSet name:(NSString *)name imageUrl:(NSString *)url
//{
//    [[GalleryService defaultService] favorImage:url name:name tagSet:tagSet resultBlock:^(int resultCode) {
//        PPDebug(@"<didEditPictureInfo> favor image %@ with tag <%@>succ !", url, [tagSet description]);
//    }];
//}


@end
