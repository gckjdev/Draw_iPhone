//
//  ArrowView.h
//  Draw
//
//  Created by 王 小涛 on 12-12-3.
//
//

#import <UIKit/UIKit.h>


#define ARROW_BUTTON_WIDTH [DeviceDetection isIPAD] ? 54 : 27
#define ARROW_BUTTON_HEIGHT [DeviceDetection isIPAD] ? 64 : 32

@interface ArrowView : UIView

+ (UIButton *)arrowWithCenter:(CGPoint)center;

@end
