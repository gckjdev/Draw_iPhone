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

#define FIXED_PEN_SIZE 20
#define INTERPOLATION 10


@protocol BrushEffectProtocol <NSObject>


@required
- (UIImage*)brushImage:(UIColor*)color width:(float)width;

//该种笔刷是否可以通过插值优化
- (BOOL)canInterpolationOptimized;

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

#define RANDOM_COUNT 99
#define SHAKERANDOMRANGE 100
//version 9: 为了优化性能，从version 9开始，利用一段固定的伪随机数列作为随机数(暂定50个数字)
-(void)shakePointWithRandomList:(NSArray*)randomList
                        atIndex:(NSInteger)index
                         PointX:(float*)pointX
                         PointY:(float*)pointY
                         PointW:(float*)pointW
               withDefaultWidth:(float)defaultWidth;

@end
