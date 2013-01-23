//
//  ChangeAvatar.m
//  Draw
//
//  Created by  on 12-3-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ChangeAvatar.h"
#import "LocaleUtils.h"
#import "PPViewController.h"
#import "UIImageExt.h"
#import "DeviceDetection.h"

#define DEFAULT_AVATAR_SIZE 320

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
    return self;
}

- (void)dealloc
{
    [_superViewController release];
    [_popoverController release];
    [super dealloc];
}

- (void)showSelectionView:(PPViewController<ChangeAvatarDelegate>*)superViewController
{
    self.superViewController = superViewController;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:NSLS(@"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLS(@"kSelectFromAlbum"), NSLS(@"kTakePhoto"), nil];
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
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (image != nil){
        if ([_superViewController respondsToSelector:@selector(didImageSelected:)])
            
            if (_autoRoundRect || (_imageSize.width > 0.0f && _imageSize.height > 0.0f)){
                if (_autoRoundRect){
                    image = [UIImage createRoundedRectImage:image size:_imageSize];
                }
                else{
                    image = [image imageByScalingAndCroppingForSize:_imageSize];
                }
            }
            
            [_superViewController didImageSelected:image];
            
    }
    if (_popoverController != nil) {
        [_popoverController dismissPopoverAnimated:YES];
    }else{
        [picker dismissModalViewControllerAnimated:YES];
    }

}

- (void)showEditImageView:(UIImage*)image
             inController:(PPViewController<ChangeAvatarDelegate>*)superViewController
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
        picker.allowsEditing = YES;
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

- (void)handleSelectAvatar:(int)buttonIndex
{
    enum{
        BUTTON_SELECT_ALBUM,
        BUTTON_TAKE_PHOTO,
        BUTTON_CANCEL
    };
    
    switch (buttonIndex) {
        case BUTTON_SELECT_ALBUM:
            [self selectPhoto];
            break;
            
        case BUTTON_TAKE_PHOTO:
            [self takePhoto];
            break;
            
        default:
            break;
    }
    
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self handleSelectAvatar:buttonIndex];
}


@end
