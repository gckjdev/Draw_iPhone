//
//  SingImageManager.h
//  Draw
//
//  Created by 王 小涛 on 13-5-28.
//
//

#import <Foundation/Foundation.h>

@interface SingImageManager : NSObject

+ (id)defaultManager;

- (UIImage*)inputDialogBgImage;
- (UIImage*)inputDialogInputBgImage;
- (UIImage*)inputDialogLeftBtnImage;
- (UIImage*)inputDialogRightBtnImage;

- (UIImage*)badgeImage;

@end
