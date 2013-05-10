//
//  LittleGeeImageManager.h
//  Draw
//
//  Created by Kira on 13-5-10.
//
//

#import <Foundation/Foundation.h>

@interface LittleGeeImageManager : NSObject

- (UIImage*)drawToBtnBackgroundImage;
- (UIImage*)draftBtnBackgroundImage;
- (UIImage*)beginBtnBackgroundImage;
- (UIImage*)contestBtnBackgroundImage;

+ (LittleGeeImageManager*)defaultManager;

@end
