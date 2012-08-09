//
//  MessageView.h
//  Draw
//
//  Created by 小涛 王 on 12-8-4.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FontLabel.h"
#import "CMPopTipView.h"

@interface MessageView:FontLabel

- (id)initWithFrame:(CGRect)frame
            message:(NSString *)message
           fontName:(NSString *)fontName 
          pointSize:(CGFloat)pointSize;

- (id)initWithFrame:(CGRect)frame
            message:(NSString *)message
           fontName:(NSString *)fontName 
          pointSize:(CGFloat)pointSize  
      textAlignment:(UITextAlignment)textAlignment;

- (void)popupAtView:(UIView *)view
             inView:(UIView *)inView
           duration:(int)duration
    backgroundColor:(UIColor *)backgroundColor
           animated:(BOOL)animated
     pointDirection:(PointDirection)pointDirection;

- (void)popupAtView:(UIView *)view
             inView:(UIView *)inView
    backgroundColor:(UIColor *)backgroundColor
           animated:(BOOL)animated
     pointDirection:(PointDirection)pointDirection;

- (void)dismissAnimated:(BOOL)animated;

@end
