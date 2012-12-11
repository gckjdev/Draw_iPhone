//
//  MessageView.h
//  Draw
//
//  Created by 王 小涛 on 12-11-12.
//
//

#import <UIKit/UIKit.h>
#import "ZJHConstance.h"

@interface MessageView : UIView

+ actionMessageViewWithMessage:(NSString *)message
                    font:(UIFont *)font
               textColor:(UIColor *)textColor
           textAlignment:(UITextAlignment)textAlignment
                 bgImage:(UIImage*)bgImage;

+ chatMessageViewWithMessage:(NSString *)message
                        font:(UIFont *)font
                   textColor:(UIColor *)textColor
               textAlignment:(UITextAlignment)textAlignment
                     bgImage:(UIImage*)bgImage
                         pos:(UserPosition)pos;

@end
