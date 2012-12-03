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

+ (void)updateDefaultTitleLabel:(UILabel *)titleLabel
                           text:(NSString *)text
{
    //update attribute
    [BBSViewManager updateLable:titleLabel
                        bgColor:[UIColor clearColor]
                           font:[[BBSFontManager defaultManager] bbsTitleFont]
                      textColor:[[BBSColorManager defaultManager] bbsTitleColor]
                           text:text];
   
    //update frame
    if ([DeviceDetection isIPAD]) {
        titleLabel.frame = CGRectMake(194,26,380,76);
    }else{
        titleLabel.frame = CGRectMake(85,12,150,35);
    }
}
+ (void)updateDefaultBackButton:(UIButton *)backButton
{
    //60 53
    //update button attribute
    [backButton setImage:[[BBSImageManager defaultManager] bbsBackImage]
                forState:UIControlStateNormal];
    
    //update button frame
    if ([DeviceDetection isIPAD]) {
        backButton.frame = CGRectMake(34,37,60,53);
    }else{
        backButton.frame = CGRectMake(14,16,30,27);
    }
}
+ (void)updateDefaultTableView:(UITableView *)tableView
{
    //update frame
    if ([DeviceDetection isIPAD]) {
        tableView.frame = CGRectMake(34,134,700,870);
    }else{
        tableView.frame = CGRectMake(10,60,300,400);
    }
}

@end
