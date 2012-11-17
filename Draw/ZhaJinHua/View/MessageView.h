//
//  MessageView.h
//  Draw
//
//  Created by 王 小涛 on 12-11-12.
//
//

#import <UIKit/UIKit.h>

@interface MessageView : UIView

+ messageViewWithMessage:(NSString *)message
                    font:(UIFont *)font
               textColor:(UIColor *)textColor
           textAlignment:(UITextAlignment)textAlignment
                 bgImage:(UIImage*)bgImage;

@end
