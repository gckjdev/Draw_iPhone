//
//  ChangeAvatar.m
//  Draw
//
//  Created by  on 12-3-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ChangeAvatar.h"
#import "LocaleUtils.h"
//#import "PPViewController.h"
#import "UIImageExt.h"
#import "DeviceDetection.h"
#import "MKBlockActionSheet.h"
#import "CropAndFilterViewController.h"

#define DEFAULT_AVATAR_SIZE 320

@interface ChangeAvatar () {
    int _buttonIndexAlbum;
    int _buttonIndexCamera;
    int _buttonIndexReset;
}

@property (assign, nonatomic) BOOL hasRemoveOption;
@property (assign, nonatomic) BOOL canTakePhoto;

@end

@implementation ChangeAvatar

@synthesize superViewController = _superViewController;
@synthesize autoRoundRect = _autoRoundRect;
@synthesize imageSize = _imageSize;
@synthesize popoverController = _popoverController;

- (id)init
{
    self = [super init];
    self.imageSize = CGSizeMake(DEFAULT_AVATAR_SIZE, DEFAULT_AVATAR_SIZE);
    self.autoRoundRect = YES;
    self.isCompressImage = NO;
    return self;
}

- (void)dealloc
{
    PPRelease(_superViewController);
    PPRelease(_popoverController);
    self.selectImageBlock = nil;
    self.setDefaultBlock = nil;    
    [super dealloc];
}

- (void)showSelectionView:(UIViewController<ChangeAvatarDelegate>*)superViewController
{
    self.superViewController = superViewController;
    self.delegate = superViewController;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:NSLS(@"kSelectFromAlbum"), nil];
    _buttonIndexAlbum = 0;
    _buttonIndexCamera = [actionSheet addButtonWithTitle:NSLS(@"kTakePhoto")];
    int index = [actionSheet addButtonWithTitle:NSLS(@"kCancel")];
    [actionSheet setCancelButtonIndex:index];
    [actionSheet showInView:[superViewController view]];
//    [actionSheet showFromTabBar:superViewController.tabBarController.tabBar];
    [actionSheet release];
}

- (void)showSelectionView:(UIViewController<ChangeAvatarDelegate>*)superViewController
       selectedImageBlock:(DidSelectedImageBlock)selectedImageBlock
       didSetDefaultBlock:(DidSetDefaultBlock)setDefaultBlock
                    title:(NSString*)title
          hasRemoveOption:(BOOL)hasRemoveOption
{
    [self showSelectionView:superViewController
                   delegate:superViewController
         selectedImageBlock:selectedImageBlock
         didSetDefaultBlock:setDefaultBlock
                      title:title
            hasRemoveOption:hasRemoveOption
               canTakePhoto:YES
          userOriginalImage:NO];
}

- (void)showSelectionView:(UIViewController*)superViewController
                 delegate:(id<ChangeAvatarDelegate>)delegate
       selectedImageBlock:(DidSelectedImageBlock)selectedImageBlock
       didSetDefaultBlock:(DidSetDefaultBlock)setDefaultBlock
                    title:(NSString*)title
          hasRemoveOption:(BOOL)hasRemoveOption
             canTakePhoto:(BOOL)canTakePhoto
        userOriginalImage:(BOOL)userOriginalImage
{
    _buttonIndexAlbum = -1;
    _buttonIndexCamera = -1;
    _buttonIndexReset = -1;
    
    self.selectImageBlock = selectedImageBlock;
    self.superViewController = superViewController;
    self.delegate = delegate;
    self.hasRemoveOption = hasRemoveOption;
    self.canTakePhoto = canTakePhoto;
    self.setDefaultBlock = setDefaultBlock;
    self.userOriginalImage = userOriginalImage;
    
    if (!hasRemoveOption && !canTakePhoto) {
        [self selectPhoto];
        return;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:NSLS(@"kSelectFromAlbum"), nil];
    _buttonIndexAlbum = 0;
    if (canTakePhoto) {
        _buttonIndexCamera = [actionSheet addButtonWithTitle:NSLS(@"kTakePhoto")];
    }
    if (hasRemoveOption) {
        _buttonIndexReset = [actionSheet addButtonWithTitle:NSLS(@"kResetDefault")];
    }
    int index = [actionSheet addButtonWithTitle:NSLS(@"kCancel")];
    [actionSheet setCancelButtonIndex:index];
    [actionSheet showInView:[superViewController view]];
    [actionSheet release];
}


- (void)showSelectionView:(UIViewController*)superViewController
                    title:(NSString*)title
              otherTitles:(NSArray*)otherTitles
                  handler:(CallBackBlock)handler
       selectImageHanlder:(DidSelectedImageBlock)selectImageHanlder
             canTakePhoto:(BOOL)canTakePhoto
        userOriginalImage:(BOOL)userOriginalImage
{
    _buttonIndexAlbum = -1;
    _buttonIndexCamera = -1;
    _buttonIndexReset = -1;
    
    self.superViewController = superViewController;
    self.canTakePhoto = canTakePhoto;
    self.userOriginalImage = userOriginalImage;
    self.selectImageBlock = selectImageHanlder;
    

    MKBlockActionSheet *sheet = [[MKBlockActionSheet alloc] initWithTitle:title
                                                                 delegate:nil
                                                        cancelButtonTitle:nil
                                                   destructiveButtonTitle:NSLS(@"kSelectFromAlbum")
                                                        otherButtonTitles:nil];
    
    _buttonIndexAlbum = 0;
    if (canTakePhoto) {
        _buttonIndexCamera = [sheet addButtonWithTitle:NSLS(@"kTakePhoto")];
    }
    for (NSString *t in otherTitles) {
        [sheet addButtonWithTitle:t];
    }

    int index = [sheet addButtonWithTitle:NSLS(@"kCancel")];
    [sheet setCancelButtonIndex:index];
    
    [sheet setActionBlock:^(NSInteger buttonIndex)
    {
        if (buttonIndex == _buttonIndexAlbum) {
            [self selectPhoto];
        }
        else if (buttonIndex == _buttonIndexCamera) {
            [self takePhoto];
        }else{
            EXECUTE_BLOCK(handler,buttonIndex);
        }
        PPDebug(@"<showSelectionView> click at index = %d", buttonIndex);
        
    }];
    [sheet showInView:[superViewController view]];
    [sheet release];
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:self.userOriginalImage?UIImagePickerControllerOriginalImage:UIImagePickerControllerEditedImage];

    PPDebug(@"select original image size = %@", NSStringFromCGSize(image.size));
    if (image != nil){
        if (_superViewController){
            CGSize size = image.size;
            if (_imageSize.width > 0 && _imageSize.height > 0) {
                size = _imageSize;
            }
        
            if (_autoRoundRect){
                image = [UIImage createRoundedRectImage:image size:size];
            }
            else if (self.isCompressImage){
                image = [image imageByScalingAndCroppingForSize:size];
                PPDebug(@"compress image size = %@", NSStringFromCGSize(image.size));
            }
        }        
    }

    if (_popoverController != nil) {
        [_popoverController dismissPopoverAnimated:NO];
    }else{
//        [picker dismissModalViewControllerAnimated:NO];
        [picker dismissViewControllerAnimated:NO completion:nil];
    }
    
    id delegate = self.enableCrop ? (id)self : _delegate;
    
    if (image && delegate && [delegate respondsToSelector:@selector(didImageSelected:)]) {
        [delegate didImageSelected:image];
    }
    
    if (_selectImageBlock != NULL) {
        EXECUTE_BLOCK(_selectImageBlock, image);
        self.selectImageBlock = nil;
    }
}

- (void)didImageSelected:(UIImage*)image{
    
    [self showImageEditor:image];
}

- (void)showImageEditor:(UIImage *)image{
    
    CropAndFilterViewController *vc = [[CropAndFilterViewController alloc] init];
    vc.delegate = self;
    vc.image = image;
    [vc setCropAspectRatio:_cropRatio];
    
    [_superViewController presentViewController:vc animated:YES completion:NULL];
    [vc release];
}

- (void)cropViewController:(CropAndFilterViewController *)controller didFinishCroppingImage:(UIImage *)image{
    
    [controller dismissViewControllerAnimated:YES completion:NULL];
    PPDebug(@"image selected, image size = %@", NSStringFromCGSize(image.size));

    if ([self.delegate respondsToSelector:@selector(didCropImageSelected:)]) {
        [self.delegate didCropImageSelected:image];
    }
}

- (void)cropViewControllerDidCancel:(CropAndFilterViewController *)controller{
    [controller dismissViewControllerAnimated:YES completion:NULL];
}

- (void)showEditImageView:(UIImage*)image
             inController:(UIViewController<ChangeAvatarDelegate>*)superViewController
{
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (_popoverController != nil) {
        [_popoverController dismissPopoverAnimated:YES];
    }else{
        [picker dismissModalViewControllerAnimated:YES];
    }
}


- (void)selectPhoto
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] &&
        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        picker.allowsEditing = !self.userOriginalImage;
        picker.delegate = self;
        
        if ([DeviceDetection isIPAD]){
            UIPopoverController *controller = [[UIPopoverController alloc] initWithContentViewController:picker];
            self.popoverController = controller;
            [controller release];
            CGRect popoverRect = CGRectMake((768-400)/2, -140, 400, 400);
            [_popoverController presentPopoverFromRect:popoverRect 
                                               inView:_superViewController.view
                             permittedArrowDirections:UIPopoverArrowDirectionUp
                                             animated:YES];
            
        }else {
            [_superViewController presentModalViewController:picker animated:YES];
        }
        
        [picker release];
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

- (void)executeDefault
{
    EXECUTE_BLOCK(_setDefaultBlock);
    self.setDefaultBlock = nil;
}

- (void)handleSelectAvatar:(int)buttonIndex
{
    if (buttonIndex == _buttonIndexAlbum) {
        [self selectPhoto];
    }
    if (buttonIndex == _buttonIndexCamera) {
        [self takePhoto];
    }
    if (buttonIndex == _buttonIndexReset) {
        [self executeDefault];
    }
    
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self handleSelectAvatar:buttonIndex];
}


@end
