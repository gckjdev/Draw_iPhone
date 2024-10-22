//
//  SuperCalligraphyBrush.m
//  Draw
//
//  Created by 黄毅超 on 14/10/21.
//
//

#import "SuperCalligraphyBrush.h"

@implementation SuperCalligraphyBrush

- (UIImage *)brushImage:(UIColor *)color width:(float)width
{
    //To be overrided in exact calligraphy type
    return nil;
}

- (BOOL)canInterpolationOptimized
{
    return YES;
}

- (float)calculateWidthWithThreshold:(float)threshold
                           distance1:(float)distance1
                           distance2:(float)distance2
                        currentWidth:(float)defaultWidth
{
    //To be overrided in exact calligraphy type
    return 0;
}

- (BOOL)isWidthFixedSize
{
    return NO;
}

- (float)firstPointWidth:(float)defaultWidth
{
    return 0;
}

- (int)interpolationLength:(float)brushWidth        // 当前笔刷大小
                 distance1:(float)distance1         // 当前BeginDot和ControlDot的距离
                 distance2:(float)distance2         // 当前EndDot和ControlDot的距离
{
    if (brushWidth <= 0.0f){
        return 1;
    }
    
    double speedFactor = ((distance1+distance2)/2)/FIXED_PEN_SIZE;
    double typeFactor = 1;  // 针对各种笔刷的调节因子，经过实践所得(有些笔需要更密集的插值，如钢笔；有些则相反，如蜡笔)
    int interpolationLength = INTERPOLATION * typeFactor*speedFactor+1;
    
    return interpolationLength;
    
}

- (void)shakePointWithRandomList:(NSArray *)randomList atIndex:(NSInteger)index PointX:(float *)pointX PointY:(float *)pointY PointW:(float *)pointW withDefaultWidth:(float)defaultWidth
{
    //do nothing
}

@end
