//
//  GalleryController.m
//  Draw
//
//  Created by Kira on 13-6-7.
//
//

#import "GalleryController.h"
#import "GalleryService.h"
#import "MKBlockActionSheet.h"
#import "Photo.pb.h"
#import "StorageManager.h"
#import "CommonMessageCenter.h"
#import "CommonDialog.h"
#import "SearchPhotoController.h"
#import "ImagePlayer.h"

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
    CommonTitleView *v = [CommonTitleView createTitleView:self.view];
    [self.view sendSubviewToBack:v];
    [v setTitle:NSLS(@"kGallery")];
    [v setTarget:self];
    [v setBackButtonSelector:@selector(clickBack:)];
    
    self.dataTableView.numColsPortrait = 2;
    [((UIButton*)self.noDataTipLabel) setTitle:NSLS(@"kNoPhoto") forState:UIControlStateNormal];
    [self reloadTableViewDataSource];
    
    
    self.view.backgroundColor = COLOR_WHITE;
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
    StorageManager* manage = [[[StorageManager alloc] initWithStoreType:StorageTypeTemp directoryName:@"testPhoto"] autorelease];
    NSData* data = [manage dataForKey:@"test2"];
    if (data) {
        PBUserPhotoList* list = [PBUserPhotoList parseFromData:data];
        
        [self didFinishLoadData:list.photoList];
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

    NSURL *url = [NSURL URLWithString:_currentImageUrl];
    [[ImagePlayer defaultPlayer] playWithUrl:url displayActionButton:YES onViewController:self];
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
    [[GalleryService defaultService] updateUserPhoto:photo.userPhotoId photoUrl:photo.url name:name tagSet:[NSSet setWithArray:photo.tags] usage:[GameApp photoUsage] protoPhoto:photo resultBlock:^(int resultCode, PBUserPhoto* photo) {
        [self hideActivity];
        if (resultCode == 0) {
            PPDebug(@"<editPhoto> photo id = %@, name = %@, tags = <%@>", photo.userPhotoId, photo.name, [photo.tags description]);
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
    PhotoEditView *v = [PhotoEditView createViewWithPhoto:photo];
    
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kSetTag") customView:v style:CommonDialogStyleDoubleButtonWithCross];
    [dialog setManualClose:YES];
    [dialog.cancelButton setTitle:NSLS(@"kReset") forState:UIControlStateNormal];
    
    [dialog setClickCancelBlock:^(PhotoEditView * infoView){
        [infoView reset];
    }];
    
    [dialog setClickOkBlock:^(PhotoEditView * infoView){
        [dialog disappear];
        [self showActivityWithText:NSLS(@"kUpdating")];
        [[GalleryService defaultService] updateUserPhoto:photo.userPhotoId photoUrl:photo.url
                                                    name:photo.name
                                                  tagSet:infoView.tagSet
                                                   usage:[GameApp photoUsage]
                                              protoPhoto:photo
                                             resultBlock:^(int resultCode, PBUserPhoto* photo) {
                                                 [self hideActivity];
                                                 if (resultCode == 0) {
                                                     PPDebug(@"<editPhoto> photo id = %@, name = %@, tags = <%@>", photo.userPhotoId, photo.name, [infoView.tagSet description]);
                                                     [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kEditPhotoSucc") delayTime:2];
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
    
    [dialog setClickCloseBlock:^(PhotoEditView* infoView){
        [dialog disappear];
    }];
    
    [dialog showInView:self.view];
}


- (IBAction)clickFilterUserPhoto:(id)sender
{
    PBUserPhoto* tempPhoto = nil;
    if (self.tagSet) {
        PBUserPhotoBuilder* builder = [PBUserPhoto builder];
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

    PhotoEditView *v = [PhotoEditView createViewWithPhoto:tempPhoto];
    
    CommonDialog *dialog =[CommonDialog createDialogWithTitle:NSLS(@"kFilter") customView:v style:CommonDialogStyleDoubleButtonWithCross];
    [dialog setManualClose:YES];
    [dialog.cancelButton setTitle:NSLS(@"kReset") forState:UIControlStateNormal];
    
    [dialog setClickCancelBlock:^(PhotoEditView * infoView){
        [infoView reset];
    }];
    
    [dialog setClickOkBlock:^(PhotoEditView* infoView){
        [dialog disappear];
        cp.tagSet = infoView.tagSet;
        [cp reloadTableViewDataSource];
    }];
    
    [dialog setClickCloseBlock:^(PhotoEditView* infoView){
        [dialog disappear];
    }];
    
    [dialog showInView:self.view];
}


- (IBAction)clickSearch:(id)sender
{
    SearchPhotoController* sc = [[[SearchPhotoController alloc] init] autorelease];
    sc.delegate = self;
    [self.navigationController pushViewController:sc animated:YES];
}


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
