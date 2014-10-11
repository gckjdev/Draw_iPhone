//
//  PhotoDrawSheet.m
//  Draw
//
//  Created by haodong on 13-5-6.
//
//

#import "PhotoDrawSheet.h"
#import "UIImage+fixOrientation.h"
#import "UIImageExt.h"
#import "OfflineDrawViewController.h"

@interface PhotoDrawSheet()
@property (retain, nonatomic) UIViewController *superViewController;
@property (retain, nonatomic) UIPopoverController *photoPopoverController;
@end


@implementation PhotoDrawSheet

- (void)dealloc
{
    PPRelease(_superViewController);
    PPRelease(_photoPopoverController);
    [super dealloc];
}

+ (id)createSheetWithSuperController:(UIViewController *)controller
{
    PhotoDrawSheet *sheet = [[[PhotoDrawSheet alloc] init] autorelease];
    sheet.superViewController = controller;
    return sheet;
}

- (void)useSelectedBgImage:(UIImage *)image
{
    if ([_delegate respondsToSelector:@selector(didSelectImage:)]) {
        [_delegate didSelectImage:image];
    }
}


- (void)takePhoto
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.allowsEditing = YES;
        picker.delegate = self;
        [_superViewController presentModalViewController:picker animated:YES];
        [picker release];
    }
    
}

- (void)selectPhoto
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] &&
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.allowsEditing = YES;
        picker.delegate = self;
        
        if (ISIOS8){
            
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
            
            picker.modalPresentationStyle = UIModalPresentationPopover;
            UIPopoverPresentationController* popVC = picker.popoverPresentationController;
            popVC.permittedArrowDirections = UIPopoverArrowDirectionUp;
            popVC.sourceView = _superViewController.view;
            float screenWidth = [UIScreen mainScreen].bounds.size.width;
            float width = 400;
            popVC.sourceRect = ISIPAD ? CGRectMake((screenWidth-width)/2, -140, width, width) : _superViewController.view.bounds;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [_superViewController presentViewController:picker
                                                   animated:NO
                                                 completion:nil];
                
            });

#endif
            
        }
        else{
            if ([DeviceDetection isIPAD]){
                UIPopoverController *controller = [[UIPopoverController alloc] initWithContentViewController:picker];
                self.photoPopoverController = controller;
                [controller release];
                CGRect popoverRect = CGRectMake((768-400)/2, -140, 400, 400);
                [_photoPopoverController presentPopoverFromRect:popoverRect
                                                         inView:_superViewController.view
                                       permittedArrowDirections:UIPopoverArrowDirectionUp
                                                       animated:YES];
            } else {
                [_superViewController presentModalViewController:picker animated:YES];
            }
        }
        [picker release];
    }
}


- (void)showSheet
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:NSLS(@"kCancel")
                                                   destructiveButtonTitle:nil otherButtonTitles:NSLS(@"kSelectFromAlbum"), NSLS(@"kTakePhoto"), NSLS(@"kBlank"), nil];

    [sheet showInView:self.superViewController.view];
    [sheet release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self selectPhoto];
            break;
        case 1:
            [self takePhoto];
            break;
        case 2:
            [self useSelectedBgImage:nil];
            break;
        default:
        {
            // clean to avoid memory leak
            PPRelease(_superViewController);
            PPRelease(_photoPopoverController);            
        }
            break;
    }
}

#pragma mark -- UIImagePickerControllerDelegate
#define MAX_LEN_CUSTOM 1024.0
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
//    NSString *infoKey = (picker.sourceType == UIImagePickerControllerSourceTypeCamera ? UIImagePickerControllerEditedImage : UIImagePickerControllerOriginalImage);
    NSString *infoKey = UIImagePickerControllerOriginalImage;
    UIImage *image = [info objectForKey:infoKey];
    
    
    if (_photoPopoverController != nil) {
        [_photoPopoverController dismissPopoverAnimated:YES];
    }else{
        [picker dismissModalViewControllerAnimated:NO];
    }
    
    if (image != nil){
//        image = [image fixOrientation];
//        
//        PPDebug(@"image width:%f height:%f", image.size.width, image.size.height);
//        
//        CGFloat maxLen = (image.size.width > image.size.height ? image.size.width : image.size.height);
//        if (maxLen > MAX_LEN_CUSTOM) {
//            CGFloat mul = MAX_LEN_CUSTOM / maxLen;
//            CGSize customSize;
//            if (maxLen == image.size.width) {
//                customSize = CGSizeMake(MAX_LEN_CUSTOM, image.size.height * mul);
//            }else {
//                customSize = CGSizeMake(image.size.width * mul, MAX_LEN_CUSTOM);
//            }
//            image = [UIImage createRoundedRectImage:image size:customSize];
//        }
//        
//        [self useSelectedBgImage:image];
        [NSThread detachNewThreadSelector:@selector(handleImage:) toTarget:self withObject:image];
    }
    else{
        // clean to avoid memory leak
        PPRelease(_superViewController);
        PPRelease(_photoPopoverController);
    }
    

    
}

- (void)handleImage:(UIImage *)image {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    CGFloat maxLen = (image.size.width > image.size.height ? image.size.width : image.size.height);
    
    CGSize newSize;
    if (maxLen > MAX_LEN_CUSTOM) {
        CGFloat mul = MAX_LEN_CUSTOM / maxLen;
        if (maxLen == image.size.width) {
            newSize = CGSizeMake(MAX_LEN_CUSTOM, image.size.height * mul);
        }else {
            newSize = CGSizeMake(image.size.width * mul, MAX_LEN_CUSTOM);
        }
    } else {
        newSize = image.size;
    }
    
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    // End the context
    UIGraphicsEndImageContext();
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self useSelectedBgImage:newImage];
        
        // clean to avoid memory leak
        PPRelease(_superViewController);
        PPRelease(_photoPopoverController);
    });
    
    [pool release];        
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (_photoPopoverController != nil) {
        [_photoPopoverController dismissPopoverAnimated:YES];
    }else{
        [picker dismissModalViewControllerAnimated:YES];
    }
    
    // clean to avoid memory leak    
    PPRelease(_superViewController);
    PPRelease(_photoPopoverController);
    
}

@end
