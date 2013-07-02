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

@interface CopyPaintCommand () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (retain, nonatomic) UIPopoverController* popoverController;
@end

@implementation CopyPaintCommand

- (void)dealloc
{
    PPRelease(_popoverController);
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
    
    
    MKBlockActionSheet* actionSheet = [[[MKBlockActionSheet alloc] initWithTitle:nil delegate:nil cancelButtonTitle:NSLS(@"kCancel") destructiveButtonTitle:nil otherButtonTitles:NSLS(@"kSelectFromAlbum"), NSLS(@"kSelectFromUserPhoto"), nil] autorelease];

    [actionSheet setActionBlock:^(NSInteger buttonIndex) {
        if (buttonIndex == actionSheet.cancelButtonIndex) {
            return ;
        }
        switch (buttonIndex) {
            case 0: {
                [self selectImageFromAlbum:[self.toolPanel theViewController]];
            } break;
            case 1: {
                GalleryController *fc = [[GalleryController alloc] initWithDelegate:self title:NSLS(@"kSelectPhoto")];
                [[[self.toolPanel theViewController] navigationController] pushViewController:fc animated:YES];
                [fc release];
            } break;
            default:
                break;
        }
    }];
    [actionSheet showInView:[self.toolPanel theViewController].view];
    
    return YES;
}

- (void)selectImageFromAlbum:(UIViewController*)superController
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] &&
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        picker.allowsEditing = YES;
        picker.delegate = self;
        
        if ([DeviceDetection isIPAD]){
            UIPopoverController *controller = [[UIPopoverController alloc] initWithContentViewController:picker];
            self.popoverController = controller;
            [controller release];
            CGRect popoverRect = CGRectMake((768-400)/2, -140, 400, 400);
            [_popoverController presentPopoverFromRect:popoverRect
                                                inView:superController.view
                              permittedArrowDirections:UIPopoverArrowDirectionUp
                                              animated:YES];
            
        }else {
            [superController presentModalViewController:picker animated:YES];
        }
        
        [picker release];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [self.toolHandler changeCopyPaint:image];
    if ([self.toolPanel isKindOfClass:[DrawToolUpPanel class]]) {
        [(DrawToolUpPanel*)self.toolPanel updateCopyPaint:image];
    }
    [picker.presentingViewController dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker.presentingViewController dismissModalViewControllerAnimated:YES];
}


@end
