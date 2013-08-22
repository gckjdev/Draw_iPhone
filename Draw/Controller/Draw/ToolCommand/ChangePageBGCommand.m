//
//  ChangePageBGCommand.m
//  Draw
//
//  Created by gamy on 13-8-21.
//
//

#import "ChangePageBGCommand.h"
#import "UserManager.h"
#import "CommonMessageCenter.h"
#import  "OfflineDrawViewController.h"
#import "ChangeAvatar.h"
#import "UIImageUtil.h"

@interface ChangePageBGCommand (){
    ChangeAvatar *imageUploader;
}


@end

@implementation ChangePageBGCommand

- (ChangeAvatar*)backgroundPicker
{
    if (imageUploader == nil) {
        imageUploader = [[ChangeAvatar alloc] init];
        imageUploader.autoRoundRect = NO;
        imageUploader.isCompressImage = NO;
        imageUploader.imageSize = CGSizeZero;
    }
    return imageUploader;
}

- (void)dealloc
{
    PPRelease(imageUploader);
    [super dealloc];
}

- (BOOL)execute
{
    OfflineDrawViewController<ChangeAvatarDelegate> *odc = (id)self.controller;
    
    [[self backgroundPicker] showSelectionView:odc selectedImageBlock:^(UIImage *image) {
        if ([[UserManager defaultManager] setDrawBackground:image]) {
            [odc setPageBGImage:[[UserManager defaultManager] drawBackground]];
        }
    } didSetDefaultBlock:^{
        if ([[UserManager defaultManager] resetDrawBackground]) {
            [odc setPageBGImage:nil];
        }
    } title:NSLS(@"kChangePageBG") hasRemoveOption:YES];
    
    return YES;
}

@end
