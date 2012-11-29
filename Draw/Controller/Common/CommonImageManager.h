//
//  CommonImageManager.h
//  Draw
//
//  Created by Kira on 12-11-27.
//
//

#import <Foundation/Foundation.h>
@class PPResourceService;

@interface CommonImageManager : NSObject {
    PPResourceService*  _resService;
}

+(CommonImageManager*)defaultManager;

- (UIImage*)starryBackgroundImage;
- (UIImage*)planetImage;

- (UIImage*)starryDialogClickImage;
- (UIImage*)starryDialogCrossImage;
- (UIImage*)starryDialogButtonBackgroundImage;
- (UIImage*)starryDialogBackgroundImage;
- (UIImage*)starryDialogBackgroundSideImage;

@end
