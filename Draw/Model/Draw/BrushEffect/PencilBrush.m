//
//  PencilBrush.m
//  Draw
//
//  Created by 黄毅超 on 14-9-16.
//
//
#import "PencilBrush.h"

static PencilBrush* sharedPencilBrush;
static dispatch_once_t sharedPencilBrushOnceToken;


#define PENCILWIDTH 4 // TODO: find a suitable number as pencil
@implementation PencilBrush

+ (PencilBrush*)sharedBrush
{
    if (sharedPencilBrush == nil){
        dispatch_once(&sharedPencilBrushOnceToken, ^{
            sharedPencilBrush = [[PencilBrush alloc] init];
        });
    }
    
    return sharedPencilBrush;
}

- (BOOL)canInterpolationOptimized
{
    return NO;
}

- (UIImage*)brushImage:(UIColor *)color width:(float)width
{
    //使用图片不需要管本来的颜色，只需要形状是所需要的即可，颜色由rt_tint方法搞定
    UIImage* brushImage = [UIImage imageNamed:@"brush_dot2"];
    brushImage = [brushImage imageByScalingAndCroppingForSize:CGSizeMake(PENCILWIDTH, PENCILWIDTH)];
    
    //使用rt_tint方法需要color属性，其中color属性的alpha通道应置为1.0，否则染色效果会受底图影响
    UIColor *colorWithRGBOnly = [UIColor colorWithRed:color.red green:color.green blue:color.blue alpha:1.0];
    
    //染色，把所需形状染成用户所需颜色，不透明
    UIImage *tinted = [brushImage rt_tintedImageWithColor:colorWithRGBOnly
                                                    level:1.0f];
    
    CGFloat alpha = [color alpha];
    brushImage = [DrawUtils imageByApplyingAlpha:alpha image:tinted];
    //考虑
    brushImage = tinted;
    
    return brushImage;
}

- (BOOL)isWidthFixedSize
{
    return YES;
}

- (float)calculateWidthWithThreshold:(float)threshold
                           distance1:(float)distance1
                           distance2:(float)distance2
                        currentWidth:(float)currentWidth
{
    return PENCILWIDTH;
}

- (float)firstPointWidth:(float)defaultWidth
{
    return PENCILWIDTH;
}

- (int)interpolationLength:(float)brushWidth        // 当前笔刷大小
                 distance1:(float)distance1         // 当前BeginDot和ControlDot的距离
                 distance2:(float)distance2         // 当前EndDot和ControlDot的距离
{
    double speedFactor =  ((distance1 + distance2)/2)/ PENCILWIDTH;
    double typeFactor = 1.0;// 针对各种笔刷的调节因子，经过实践所得(有些笔需要更密集的插值，如钢笔；有些则相反，如蜡笔)
    int interpolationLength = INTERPOLATION * speedFactor * typeFactor;
    
    return interpolationLength;
    
}

- (void)shakePointWithRandomList:(NSArray *)randomList atIndex:(NSInteger)index PointX:(float *)pointX PointY:(float *)pointY PointW:(float *)pointW withDefaultWidth:(float)defaultWidth
{
    //do nothing
}


@end
