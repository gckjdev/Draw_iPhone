//
//  PhotoDrawSheet.h
//  Draw
//
//  Created by haodong on 13-5-6.
//
//

#import <Foundation/Foundation.h>

@interface PhotoDrawSheet : NSObject <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate>

+ (id)createSheetWithSuperController:(UIViewController *)controller;

- (void)showSheet;

@end
