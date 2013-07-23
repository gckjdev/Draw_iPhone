//
//  CommonTitleView.h
//  Draw
//
//  Created by 王 小涛 on 13-7-22.
//
//

#import <UIKit/UIKit.h>

@interface CommonTitleView : UIView

+ (CommonTitleView *)createWithTitle:(NSString *)title
                            delegate:(id)delegate;

@end
