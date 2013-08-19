//
//  DrawToCommand.m
//  Draw
//
//  Created by gamy on 13-3-25.
//
//

#import "CopyPaintCommand.h"
#import "MyFriend.h"
#import "UIImageUtil.h"
#import "DrawToolUpPanel.h"
#import "MKBlockActionSheet.h"
#import "ChangeAvatar.h"
#import "SDWebImageManager.h"
#import "OfflineDrawViewController.h"

@interface CopyPaintCommand ()
@property (retain, nonatomic) UIPopoverController* popoverController;
@property (retain, nonatomic) ChangeAvatar* imagePicker;
@end

@implementation CopyPaintCommand

- (void)dealloc
{
    PPRelease(_popoverController);
    PPRelease(_imagePicker);
    [super dealloc];
}

-(void)sendAnalyticsReport{
    
}


- (void)changeCopyPaint:(UIImage*)photo
{
    if (photo) {
        OfflineDrawViewController *oc = (OfflineDrawViewController *)[self controller];
        [oc setCopyPaintImage:photo];
        if ([self.toolPanel isKindOfClass:[DrawToolUpPanel class]]) {
            [(DrawToolUpPanel*)self.toolPanel updateCopyPaint:photo];
        }
        
    }
    
    
}

- (void)didGalleryController:(GalleryController *)galleryController SelectedUserPhoto:(PBUserPhoto *)userPhoto
{
    __block CopyPaintCommand* cp = self;
    [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:userPhoto.url] delegate:self options:0 success:^(UIImage *image, BOOL cached) {
        OfflineDrawViewController *oc = (OfflineDrawViewController *)[self controller];
        [oc setCopyPaintImage:image];
        if ([cp.toolPanel isKindOfClass:[DrawToolUpPanel class]]) {
            [(DrawToolUpPanel*)cp.toolPanel updateCopyPaint:image];
        }
    } failure:^(NSError *error) {
        
    }];
    [galleryController.navigationController popViewControllerAnimated:YES];
    
}

- (BOOL)execute
{
    if ([self canUseItem:self.itemType]) {
        [self showSelection];
        return YES;
    }
    return NO;
}

enum {
    selectPhotoFromAlbum = 0,
    selectPhotoFromGallery,
};

- (void)showSelection
{
    MKBlockActionSheet* actionSheet = [[[MKBlockActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:NSLS(@"kCancel") destructiveButtonTitle:nil otherButtonTitles:NSLS(@"kSelectFromAlbum"), NSLS(@"kSelectFromUserPhoto"), nil] autorelease];
    
    [actionSheet setActionBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == actionSheet.cancelButtonIndex) {
            return ;
        }
        switch (buttonIndex) {
            case selectPhotoFromAlbum: {
                [self selectImageFromAlbum:[self controller]];
            } break;
            case selectPhotoFromGallery: {
                GalleryController *fc = [[GalleryController alloc] initWithDelegate:self title:NSLS(@"kSelectPhoto")];
                [[[self controller] navigationController] pushViewController:fc animated:YES];
                [fc release];
            } break;
            default:
                break;
        }
    }];
    [actionSheet showInView:[self.toolPanel theViewController].view];
}

- (void)selectImageFromAlbum:(UIViewController*)superController
{
    __block CopyPaintCommand* cp = self;
    self.imagePicker = [[[ChangeAvatar alloc] init] autorelease];
    [self.imagePicker setAutoRoundRect:NO];
    [self.imagePicker setImageSize:CGSizeMake(0, 0)];
    [self.imagePicker setIsCompressImage:NO];
    [self.imagePicker showSelectionView:superController
                               delegate:nil
                     selectedImageBlock:^(UIImage *image) {
                         OfflineDrawViewController *oc = (OfflineDrawViewController *)[self controller];
                         [oc setCopyPaintImage:image];
                         if ([cp.toolPanel isKindOfClass:[DrawToolUpPanel class]]) {
                             [(DrawToolUpPanel*)cp.toolPanel updateCopyPaint:image];
                         }
                         
                     }
                     didSetDefaultBlock:^{
                         //
                     }
                                  title:nil
                        hasRemoveOption:NO
                           canTakePhoto:NO
                      userOriginalImage:YES];
}

@end
