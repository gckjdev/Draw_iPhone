//
//  BBSViewManager.m
//  Draw
//
//  Created by gamy on 12-11-28.
//
//

#import "BBSViewManager.h"

@implementation BBSViewManager

+ (void)updateLable:(UILabel *)label
            bgColor:(UIColor *)bgColor
               font:(UIFont *)font
          textColor:(UIColor *)textColor
               text:(NSString *)text
{
    [label setBackgroundColor:bgColor];
    [label setFont:font];
    [label setTextColor:textColor];
    [label setText:text];
}

+ (void)updateButton:(UIButton *)button
             bgColor:(UIColor *)bgColor
             bgImage:(UIImage *)bgImage
               image:(UIImage *)image
                font:(UIFont *)font
          titleColor:(UIColor *)titleColor
               title:(NSString *)title
            forState:(UIControlState)state
{
    [button setBackgroundColor:bgColor];
    [button setBackgroundImage:bgImage forState:state];
    [button setImage:image forState:state];
    [button.titleLabel setFont:font];
    [button setTitleColor:titleColor forState:state];
    [button setTitle:title forState:state];
}

@end
