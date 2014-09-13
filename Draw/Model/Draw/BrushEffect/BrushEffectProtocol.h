//
//  BrushEffectProtocol.h
//  Draw
//
//  Created by 黄毅超 on 14-9-3.
//
//

#import <Foundation/Foundation.h>
#import "UIImage+RTTint.h"
#import "UIImageExt.h"
#import "DrawUtils.h"
#import "UIColor+RGBValues.h"

@class BrushStroke;
@class BrushDot;

@protocol BrushEffectProtocol <NSObject>

#define FIXED_PEN_SIZE 24
#define INTERPOLATION 10

- (UIImage*)brushImage:(UIColor*)color width:(float)width;

// 笔刷宽度是否每一点可变
- (BOOL)isWidthFixedSize;

// 返回某一个新增点(EndDot)的宽度
- (float)calculateWidthWithThreshold:(float)threshold
                           distance1:(float)distance1
                           distance2:(float)distance2
                        currentWidth:(float)defaultWidth;

// 返回第一点的宽度
- (float)firstPointWidth:(float)defaultWidth;

// 返回插值的长度
- (int)interpolationLength:(float)brushWidth        // 当前笔刷大小
                 distance1:(float)distance1         // 当前BeginDot和ControlDot的距离
                 distance2:(float)distance2;        // 当前EndDot和ControlDot的距离

//对于某些笔刷例如蜡笔，需要对点进行随机抖动
-(void)randomShakePointX:(float*)pointX
                  PointY:(float*)pointY;

@end
