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
//    AnalyticsReport(DRAW_CLICK_CHANGE_DRAWTOUSER);
}


//- (void)changeTargetFriend:(MyFriend *)aFriend
//{
//    if (aFriend) {
//        [self.toolHandler changeDrawToFriend:aFriend];
//        [self.toolPanel updateDrawToUser:aFriend];
//    }
//}

- (void)changeCopyPaint:(UIImage*)photo
{
    if (photo) {
        [self.toolHandler changeCopyPaint:photo];
        if ([self.toolPanel isKindOfClass:[DrawToolUpPanel class]]) {
            [(DrawToolUpPanel*)self.toolPanel updateCopyPaint:photo];
        }
        
    }
    
    
}

//- (void)friendController:(FriendController *)controller
//         didSelectFriend:(MyFriend *)aFriend
//{
//    [self changeTargetFriend:aFriend];
//    [controller.navigationController popViewControllerAnimated:YES];
//}

- (void)didGalleryController:(GalleryController *)galleryController SelectedUserPhoto:(PBUserPhoto *)userPhoto
{
    __block CopyPaintCommand* cp = self;
    [[SDWebImageManager sharedManager] downloadWithURL:[NSURL URLWithString:userPhoto.url] delegate:self options:0 success:^(UIImage *image, BOOL cached) {
        [cp.toolHandler changeCopyPaint:image];
        if ([cp.toolPanel isKindOfClass:[DrawToolUpPanel class]]) {
            [(DrawToolUpPanel*)cp.toolPanel updateCopyPaint:image];
        }
    } failure:^(NSError *error) {
        
    }];
    [galleryController.navigationController popViewControllerAnimated:YES];
    
}

- (BOOL)execute
{
    //TODO enter MyFriendController and select the friend
    
    if ([self canUseItem:self.itemType]) {
        [self sendAnalyticsReport];
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
                [self selectImageFromAlbum:[self.toolPanel theViewController]];
            } break;
            case selectPhotoFromGallery: {
                GalleryController *fc = [[GalleryController alloc] initWithDelegate:self title:NSLS(@"kSelectPhoto")];
                [[[self.toolPanel theViewController] navigationController] pushViewController:fc animated:YES];
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
                         [cp.toolHandler changeCopyPaint:image];
                         if ([cp.toolPanel isKindOfClass:[DrawToolUpPanel class]]) {
                             [(DrawToolUpPanel*)cp.toolPanel updateCopyPaint:image];
                         }
                         
                     }
                     didSetDefaultBlock:^{
                         //
                     }
                                  title:nil
                        hasRemoveOption:NO
                           canTakePhoto:NO];
}
//
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
//{
//    [self.toolHandler changeCopyPaint:image];
//    if ([self.toolPanel isKindOfClass:[DrawToolUpPanel class]]) {
//        [(DrawToolUpPanel*)self.toolPanel updateCopyPaint:image];
//    }
//    if (_popoverController != nil) {
//        [_popoverController dismissPopoverAnimated:YES];
//    }else{
//        [picker dismissModalViewControllerAnimated:YES];
//    }
//}
//
//- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
//{
//    [picker.presentingViewController dismissModalViewControllerAnimated:YES];
//}


@end
