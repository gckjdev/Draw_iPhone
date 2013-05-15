//
//  PhotoDrawSheet.h
//  Draw
//
//  Created by haodong on 13-5-6.
//
//

#import <Foundation/Foundation.h>

@protocol PhotoDrawSheetDelegate <NSObject>

@optional
- (void)didSelectImage:(UIImage *)image;

@end

@interface PhotoDrawSheet : NSObject <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>
@property (assign, nonatomic) id<PhotoDrawSheetDelegate> delegate;

+ (id)createSheetWithSuperController:(UIViewController *)controller;

- (void)showSheet;

@end
