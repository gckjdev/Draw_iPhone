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
typedef void(^CallBackBlock)(NSInteger index);

@class PPViewController;

@interface ChangeAvatar : NSObject<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, retain) UIViewController *superViewController;
@property (nonatomic, assign) id<ChangeAvatarDelegate> delegate;
@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) BOOL autoRoundRect;
@property (assign, nonatomic) BOOL isCompressImage;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, copy) DidSelectedImageBlock selectImageBlock;
@property (nonatomic, copy) DidSetDefaultBlock setDefaultBlock;
@property (assign, nonatomic) BOOL userOriginalImage;

- (void)showSelectionView:(UIViewController<ChangeAvatarDelegate>*)superViewController;
- (void)showEditImageView:(UIImage*)image
             inController:(UIViewController<ChangeAvatarDelegate>*)superViewController;

- (void)showSelectionView:(UIViewController<ChangeAvatarDelegate>*)superViewController
       selectedImageBlock:(DidSelectedImageBlock)selectedImageBlock
       didSetDefaultBlock:(DidSetDefaultBlock)setDefaultBlock
                    title:(NSString*)title
          hasRemoveOption:(BOOL)hasRemoveOption;

- (void)showSelectionView:(UIViewController*)superViewController
                 delegate:(id<ChangeAvatarDelegate>)delegate
       selectedImageBlock:(DidSelectedImageBlock)selectedImageBlock
       didSetDefaultBlock:(DidSetDefaultBlock)setDefaultBlock
                    title:(NSString*)title
          hasRemoveOption:(BOOL)hasRemoveOption
             canTakePhoto:(BOOL)canTakePhoto
        userOriginalImage:(BOOL)userOriginalImage;


//index from 2
- (void)showSelectionView:(UIViewController*)superViewController
                    title:(NSString*)title
              otherTitles:(NSArray*)otherTitles
                  handler:(CallBackBlock)handler
       selectImageHanlder:(DidSelectedImageBlock)selectImageHanlder
             canTakePhoto:(BOOL)canTakePhoto
        userOriginalImage:(BOOL)userOriginalImage;


@end
