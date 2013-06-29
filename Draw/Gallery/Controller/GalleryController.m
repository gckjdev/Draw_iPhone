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
#import "CommonDialog.h"
#import "InputDialog.h"
#import "SearchPhotoController.h"

@interface GalleryController () {
    NSString* _currentImageUrl;
    
}

@property (assign, nonatomic) id<GalleryControllerDelegate> delegate;


@property (retain, nonatomic) NSSet* tagSet;

- (IBAction)clickSearch:(id)sender;

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

- (id)initWithDelegate:(id<GalleryControllerDelegate>)delegate
                 title:(NSString *)title
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.title = title;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.title && self.title.length > 0) {
        [self.titleLabel setText:self.title];
    }
//    [self serviceLoadDataForTabID:[self currentTab].tabID];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self reloadTableViewDataSource];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define IMAGE_PER_LINE 2
#define IMAGE_HEIGHT  (ISIPAD?384:160)
#define RESULT_IMAGE_TAG_OFFSET 9999
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"] autorelease];
        [cell setAutoresizingMask:UIViewAutoresizingNone];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        for (int i = 0; i < IMAGE_PER_LINE; i ++) {
            UserPhotoView* photoView = [UserPhotoView createViewWithPhoto:nil delegate:self];
            
            photoView.tag = RESULT_IMAGE_TAG_OFFSET + i;
//            resultView.delegate = self;
            
            [cell.contentView addSubview:photoView];
            [photoView setFrame:CGRectMake(i*self.dataTableView.frame.size.width/IMAGE_PER_LINE, 0, self.dataTableView.frame.size.width/IMAGE_PER_LINE, IMAGE_HEIGHT)];
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
    [super tableView:tableView numberOfRowsInSection:section];
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
    
    [[GalleryService defaultService] getUserPhotoWithTagSet:self.tagSet usage:[GameApp photoUsage] offset:[self currentTab].offset limit:[self fetchDataLimitForTabIndex:[self currentTab].tabID] resultBlock:^(int resultCode, NSArray *resultArray) {
        [self finishLoadDataForTabID:[self currentTab].tabID resultList:resultArray];
        [self currentTab].status = TableTabStatusLoaded;
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
    actionEditTag,
    actionEditName,
    actionDelete,
};
#pragma mark - UserPhotoView delegate
- (void)didClickPhoto:(PBUserPhoto *)photo
{
    if (_delegate && [_delegate respondsToSelector:@selector(didGalleryController:SelectedUserPhoto:)]) {
        [_delegate didGalleryController:self SelectedUserPhoto:photo];
        return;
    }
    
    MKBlockActionSheet* actionSheet = [[MKBlockActionSheet alloc] initWithTitle:NSLS(@"kOptions") delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:NSLS(@"kShow"), NSLS(@"kSetTag"), NSLS(@"kEditName"), NSLS(@"kDelete"), nil];
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
            case actionEditTag: {
                [cp editPhoto:photo];
            } break;
            case actionEditName: {
                [cp editName:photo];
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

- (void)editName:(PBUserPhoto*)photo
{
    __block GalleryController* cp = self;
    InputDialog* dialog = [InputDialog dialogWith:NSLS(@"kEnterNewName") clickOK:^(NSString *inputStr) {
        [cp editPhoto:photo withName:inputStr];
    } clickCancel:^(NSString *inputStr) {
        //
    }];
    [dialog showInView:self.view];
}

- (void)editPhoto:(PBUserPhoto*)photo
         withName:(NSString*)name
{
    [[GalleryService defaultService] updateUserPhoto:photo.userPhotoId photoUrl:photo.url name:name tagSet:[NSSet setWithArray:photo.tagsList] usage:[GameApp photoUsage] resultBlock:^(int resultCode, PBUserPhoto* photo) {
        if (resultCode == 0) {
            PPDebug(@"<editPhoto> photo id = %@, name = %@, tags = <%@>", photo.userPhotoId, photo.name, [photo.tagsList description]);
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kEditPhotoSucc") delayTime:2];
            [self reloadTableViewDataSource];
        } else {
            PPDebug(@"<deletePhoto> err code = %d", resultCode);
        }
    }];
}

- (void)deletePhoto:(PBUserPhoto*)photo
{
    __block GalleryController* cp = self;
    CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kDelete") message:NSLS(@"kAre_you_sure") style:CommonDialogStyleDoubleButton delegate:nil clickOkBlock:^{
        [[GalleryService defaultService] deleteUserPhoto:photo.userPhotoId
                                                   usage:[GameApp photoUsage]
                                             resultBlock:^(int resultCode) {
            if (resultCode == 0) {
                [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kDeletePhotoSucc") delayTime:2];
                [cp reloadTableViewDataSource];
            } else {
                PPDebug(@"<deletePhoto> err code = %d", resultCode);
            }
            
        }];
    } clickCancelBlock:^{
        //
    }];
    [dialog showInView:self.view];
}

- (void)editPhoto:(PBUserPhoto*)photo
{
    PhotoEditView* view = [PhotoEditView createViewWithPhoto:photo
                                                       title:NSLS(@"kSetTag")
                                                confirmTitle:NSLS(@"kConfirm")
                                                 resultBlock:^(NSSet *tagSet) {
        [[GalleryService defaultService] updateUserPhoto:photo.userPhotoId photoUrl:photo.url name:photo.name tagSet:tagSet usage:[GameApp photoUsage] resultBlock:^(int resultCode, PBUserPhoto* photo) {
            if (resultCode == 0) {
                PPDebug(@"<editPhoto> photo id = %@, name = %@, tags = <%@>", photo.userPhotoId, photo.name, [tagSet description]);
                [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kEditPhotoSucc") delayTime:2];
                [self reloadTableViewDataSource];
            } else {
                PPDebug(@"<deletePhoto> err code = %d", resultCode);
            }
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
        [builder setUserId:@"tempId"];
        [builder setPhotoId:@"tempId"];
        [builder setUserPhotoId:@"tempId"];
        [builder setUrl:@""];
        tempPhoto = [builder build];
    }
    
    __block GalleryController* cp = self;
    PhotoEditView* view = [PhotoEditView createViewWithPhoto:tempPhoto
                                                       title:NSLS(@"kFilter")
                                                confirmTitle:NSLS(@"kConfirm")
                                                 resultBlock:^(NSSet *tagSet) {
        cp.tagSet = tagSet;
        [cp reloadTableViewDataSource];
    }];
    [view showInView:self.view];
}


- (IBAction)clickSearch:(id)sender
{
    SearchPhotoController* sc = [[[SearchPhotoController alloc] init] autorelease];
    [self.navigationController pushViewController:sc animated:YES];
}
//#pragma mark - PhotoEditView delegate
//- (void)didEditPictureInfo:(NSSet *)tagSet name:(NSString *)name imageUrl:(NSString *)url
//{
//    [[GalleryService defaultService] favorImage:url name:name tagSet:tagSet resultBlock:^(int resultCode) {
//        PPDebug(@"<didEditPictureInfo> favor image %@ with tag <%@>succ !", url, [tagSet description]);
//    }];
//}


@end
