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
    
    [[self backgroundPicker] showSelectionView:odc title:NSLS(@"kChangePageBG") otherTitles:@[NSLS(@"kResetDefault"),NSLS(@"kOldDrawBG")] handler:^(NSInteger index) {
        if (index == 2) {
            if ([[UserManager defaultManager] resetDrawBackground]) {
                [odc setPageBGImage:nil];
            }
        }else if(index == 3){
            if ([[UserManager defaultManager] setDrawBackground:[[ShareImageManager defaultManager] oldDrawBGImage]]) {
                [odc setPageBGImage:[[UserManager defaultManager] drawBackground]];
            }
        }
    } selectImageHanlder:^(UIImage *image) {
        if ([[UserManager defaultManager] setDrawBackground:image]) {
            [odc setPageBGImage:[[UserManager defaultManager] drawBackground]];
        }
    } canTakePhoto:YES userOriginalImage:YES];
    return YES;
}

@end
