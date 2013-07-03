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

#define DEFAULT_AVATAR_SIZE 320

@interface ChangeAvatar () {
    int _buttonIndexAlbum;
    int _buttonIndexCamera;
    int _buttonIndexReset;
}

@property (assign, nonatomic) BOOL hasRemoveOption;
@property (assign, nonatomic) BOOL canTakePhoto;
@property (assign, nonatomic) BOOL userOriginalImage;

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
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:NSLS(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLS(@"kSelectFromAlbum"), NSLS(@"kTakePhoto"), nil];
    [actionSheet showInView:[superViewController view]];
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


//- (void)setUserAvatar:(UIImage*)image
//{    
//    UserService* userService = GlobalGetUserService();
//    [userService updateUserAvatar:image];    
//    
//    // update GUI
//    [self updateImageView];
//}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
//    [picker dismissModalViewControllerAnimated:YES];
    UIImage *image = [info objectForKey:self.userOriginalImage?UIImagePickerControllerOriginalImage:UIImagePickerControllerEditedImage];

    PPDebug(@"select image size = %@", NSStringFromCGSize(image.size));
    if (image != nil){
        if (_superViewController)
            
            if (_autoRoundRect || (_imageSize.width > 0.0f && _imageSize.height > 0.0f)){
                if (_autoRoundRect){
                    image = [UIImage createRoundedRectImage:image size:_imageSize];
                }
                else{
                    if (self.isCompressImage){
                        image = [image imageByScalingAndCroppingForSize:_imageSize];
                    }
                }
            }
        if (_delegate && [_delegate respondsToSelector:@selector(didImageSelected:)]) {
            [_delegate didImageSelected:image];
        }
    }
    if (_selectImageBlock != NULL) {
        EXECUTE_BLOCK(_selectImageBlock, image);
        self.selectImageBlock = nil;
    }
    if (_popoverController != nil) {
        [_popoverController dismissPopoverAnimated:YES];
    }else{
        [picker dismissModalViewControllerAnimated:YES];
    }

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
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
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
