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

@optional
- (void)didCropImageSelected:(UIImage*)image;

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
@property (nonatomic, copy) CallBackBlock otherHandlerBlock;
@property (nonatomic, copy) DidSetDefaultBlock setDefaultBlock;
@property (assign, nonatomic) BOOL userOriginalImage;
@property (assign, nonatomic) BOOL enableCrop;
@property (assign, nonatomic) float cropRatio;

// 使用该方法，可以弹出三个选项(拍照，相册，取消)，并且完成相应的功能，最后回调
// - (void)didImageSelected:(UIImage*)image;
// 如果你讲enableCrop设置成YES(同时设定相应的cropRatio)，则可在选择相片后对相片进行裁减和滤镜，最后回调
//- (void)didCropImageSelected:(UIImage*)image; 这种情况下就不会回调 - (void)didImageSelected:(UIImage*)image;这个方法了。
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
