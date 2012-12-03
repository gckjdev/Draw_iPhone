//
//  BBSViewManager.h
//  Draw
//
//  Created by gamy on 12-11-28.
//
//

#import <Foundation/Foundation.h>
#import "BBSImageManager.h"
#import "BBSColorManager.h"
#import "BBSFontManager.h"

@interface BBSViewManager : NSObject

+ (void)updateLable:(UILabel *)label
            bgColor:(UIColor *)bgColor
               font:(UIFont *)font
          textColor:(UIColor *)textColor
               text:(NSString *)text;

+ (void)updateButton:(UIButton *)button
             bgColor:(UIColor *)bgColor
             bgImage:(UIImage *)bgImage
               image:(UIImage *)image
                font:(UIFont *)font
          titleColor:(UIColor *)titleColor
               title:(NSString *)title
            forState:(UIControlState)state;

@end
