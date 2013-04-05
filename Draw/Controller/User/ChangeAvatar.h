//
//  ChangeAvatar.h
//  Draw
//
//  Created by  on 12-3-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ChangeAvatarDelegate <NSObject>

- (void)didImageSelected:(UIImage*)image;

@end

typedef void(^DidSelectedImageBlock)(UIImage* image);
typedef void(^DidSetDefaultBlock)(void);

@class PPViewController;

@interface ChangeAvatar : NSObject<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, retain) PPViewController<ChangeAvatarDelegate> *superViewController;
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) BOOL autoRoundRect;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, copy) DidSelectedImageBlock selectImageBlock;
@property (nonatomic, copy) DidSetDefaultBlock setDefaultBlock;

- (void)showSelectionView:(PPViewController<ChangeAvatarDelegate>*)superViewController;
- (void)showEditImageView:(UIImage*)image
             inController:(PPViewController<ChangeAvatarDelegate>*)superViewController;
- (void)showSelectionView:(PPViewController<ChangeAvatarDelegate>*)superViewController
       selectedImageBlock:(DidSelectedImageBlock)selectedImageBlock
       didSetDefaultBlock:(DidSetDefaultBlock)setDefaultBlock
                    title:(NSString*)title
          hasRemoveOption:(BOOL)hasRemoveOption;

@end
