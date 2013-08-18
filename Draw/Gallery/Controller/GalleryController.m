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
#import "CommonMessageCenter.h"
#import "CommonDialog.h"
#import "SearchPhotoController.h"

@interface GalleryController () <SearchPhotoResultControllerDelegate>{
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
    [_titleLabel release];
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
    self.dataTableView.numColsPortrait = 2;
    [((UIButton*)self.noDataTipLabel) setTitle:NSLS(@"kNoPhoto") forState:UIControlStateNormal];
    [self reloadTableViewDataSource];
//    [self serviceLoadDataForTabID:[self currentTab].tabID];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self reloadTableViewDataSource];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PSCollectionViewCell *)collectionView:(PSCollectionView *)collectionView viewAtIndex:(NSInteger)index {
    UserPhotoView* cell = (UserPhotoView*)[self.dataTableView dequeueReusableView];
    if (cell == nil) {
        cell = [UserPhotoView createViewWithPhoto:nil delegate:nil];
    }
    PBUserPhoto* result = (PBUserPhoto*)[self.dataList objectAtIndex:index];
    [cell updateWithUserPhoto:result];
    return cell;
}

- (CGFloat)heightForViewAtIndex:(NSInteger)index {
    //    NSDictionary *item = [self.items objectAtIndex:index];
    PBUserPhoto* result = [self.dataList objectAtIndex:index];
    //    return 60;
    return [UserPhotoView heightForViewWithPhotoWidth:result.width height:result.height inColumnWidth:self.dataTableView.colWidth];
}

- (void)collectionView:(PSCollectionView *)collectionView didSelectView:(PSCollectionViewCell *)view atIndex:(NSInteger)index {
    //    NSDictionary *item = [self.items objectAtIndex:index];
    PBUserPhoto* result = [self.dataList objectAtIndex:index];
    [self didClickPhoto:result atIndex:index];
    // You can do something when the user taps on a collectionViewCell here
}


#pragma mark tab controller delegate

- (NSInteger)loadMoreLimit
{
    return 8;
}


- (void)loadTestData
{
    StorageManager* manage = [[StorageManager alloc] initWithStoreType:StorageTypeTemp directoryName:@"testPhoto"];
    NSData* data = [manage dataForKey:@"test2"];
    if (data) {
        PBUserPhotoList* list = [PBUserPhotoList parseFromData:data];
        
        [self didFinishLoadData:list.photoListList];
    } 
}

- (void)serviceLoadData
{
    [super serviceLoadData];
    [[GalleryService defaultService] getUserPhotoWithTagSet:self.tagSet usage:[GameApp photoUsage] offset:self.dataListOffset limit:[self loadMoreLimit] resultBlock:^(int resultCode, NSArray *resultArray) {
        [self didFinishLoadData:resultArray];
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
              atIndex:(int)photoIndex
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
                [cp editPhoto:photo atIndex:photoIndex];
            } break;
            case actionEditName: {
                [cp editName:photo atIndex:photoIndex];
            } break;
            case actionDelete: {
                [cp deletePhoto:photo atIndex:photoIndex];
            } break;
            default:
                break;
        }
    }];
    [actionSheet showInView:self.view];
    
}

- (void)editName:(PBUserPhoto*)photo atIndex:(int)photoIndex
{
    __block GalleryController* cp = self;
    
    CommonDialog *dialog = [CommonDialog createInputFieldDialogWith:NSLS(@"kEnterNewName")];
    
    [dialog setClickOkBlock:^(UITextField *tf) {
        [cp editPhoto:photo withName:tf.text atIndex:photoIndex];
    }];
   
    [dialog showInView:self.view];
}

- (void)editPhoto:(PBUserPhoto*)photo
         withName:(NSString*)name
          atIndex:(int)photoIndex
{
    [self showActivityWithText:NSLS(@"kUpdating")];
    [[GalleryService defaultService] updateUserPhoto:photo.userPhotoId photoUrl:photo.url name:name tagSet:[NSSet setWithArray:photo.tagsList] usage:[GameApp photoUsage] protoPhoto:photo resultBlock:^(int resultCode, PBUserPhoto* photo) {
        [self hideActivity];
        if (resultCode == 0) {
            PPDebug(@"<editPhoto> photo id = %@, name = %@, tags = <%@>", photo.userPhotoId, photo.name, [photo.tagsList description]);
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kEditPhotoSucc") delayTime:2];
//            [self reloadTableViewDataSource];
            if (photoIndex < self.dataList.count) {
                [self.dataList setObject:photo atIndexedSubscript:photoIndex];
                [self.dataTableView reloadData];
            }
        } else {
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kEditPhotoFail") delayTime:2];
            PPDebug(@"<editPhoto> err code = %d", resultCode);
        }
    }];
}

- (void)deletePhoto:(PBUserPhoto*)photo
            atIndex:(int)photoIndex
{
    __block GalleryController* cp = self;
    
    CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"kDelete")
                                                       message:NSLS(@"kAre_you_sure")
                                                         style:CommonDialogStyleDoubleButton];
    [dialog setClickOkBlock:^(UILabel *label){
      [self showActivityWithText:NSLS(@"kDeleting")];
      [[GalleryService defaultService] deleteUserPhoto:photo.userPhotoId
                                                 usage:[GameApp photoUsage]
                                           resultBlock:^(int resultCode) {
                                               [self hideActivity];
                                               if (resultCode == 0) {
                                                   [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kDeletePhotoSucc") delayTime:2];
                                                   if (photoIndex < cp.dataList.count) {
                                                       [cp.dataList removeObjectAtIndex:photoIndex];
                                                       [cp.dataTableView reloadData];
                                                   }
                                               } else {
                                                   [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kDeletePhotoFail") delayTime:2];
                                                   PPDebug(@"<deletePhoto> err code = %d", resultCode);
                                               }
                                               
                                           }];
    }];
    
    [dialog showInView:self.view];
}

- (void)editPhoto:(PBUserPhoto*)photo atIndex:(int)photoIndex
{
    PhotoEditView* view = [PhotoEditView createViewWithPhoto:photo
                                                       title:NSLS(@"kSetTag")
                                                confirmTitle:NSLS(@"kConfirm")
                                                 resultBlock:^(NSSet *tagSet) {
                                                     [self showActivityWithText:NSLS(@"kUpdating")];
                                                     [[GalleryService defaultService] updateUserPhoto:photo.userPhotoId photoUrl:photo.url
                                                                                                 name:photo.name
                                                                                               tagSet:tagSet
                                                                                                usage:[GameApp photoUsage]
                                                                                           protoPhoto:photo
                                                                                          resultBlock:^(int resultCode, PBUserPhoto* photo) {
                                                                                              [self hideActivity];
            if (resultCode == 0) {
                PPDebug(@"<editPhoto> photo id = %@, name = %@, tags = <%@>", photo.userPhotoId, photo.name, [tagSet description]);
                [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kEditPhotoSucc") delayTime:2];
//                [self reloadTableViewDataSource];
                if (photoIndex < self.dataList.count) {
                    [self.dataList setObject:photo atIndexedSubscript:photoIndex];
                    [self.dataTableView reloadData];
                }
            } else {
                [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kEditPhotoFail") delayTime:2];
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
    sc.delegate = self;
    [self.navigationController pushViewController:sc animated:YES];
}
//#pragma mark - PhotoEditView delegate
//- (void)didEditPictureInfo:(NSSet *)tagSet name:(NSString *)name imageUrl:(NSString *)url
//{
//    [[GalleryService defaultService] favorImage:url name:name tagSet:tagSet resultBlock:^(int resultCode) {
//        PPDebug(@"<didEditPictureInfo> favor image %@ with tag <%@>succ !", url, [tagSet description]);
//    }];
//}

- (void)didAddUserPhoto:(PBUserPhoto *)photo
{
    [self.dataList insertObject:photo atIndex:0];
    [self.noDataTipLabel setHidden:YES];
    [self.dataTableView reloadData];
}

- (void)viewDidUnload {
    [self setTitleLabel:nil];
    [super viewDidUnload];
}
@end
