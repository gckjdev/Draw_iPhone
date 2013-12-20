//
//  UIViewController+BGImage.h
//  Draw
//
//  Created by Gamy on 13-12-20.
//
//

#import <UIKit/UIKit.h>

@interface UIViewController(BGImage)

- (UIImageView *)bgImageView;
- (void)setBGImage:(UIImage *)image;
- (void)setBGImageURL:(NSURL *)imageURL;
- (void)setBGImageURL:(NSURL *)imageURL placeholder:(UIImage *)image;
- (void)setDefaultBGImage;
@end
