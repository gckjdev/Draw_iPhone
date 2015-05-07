//
//  FeatherBrush.m
//  Draw
//
//  Created by 黄毅超 on 14-9-16.
//
//
#import "FeatherBrush.h"

static FeatherBrush* sharedFeatherBrush;
static dispatch_once_t sharedFeatherBrushOnceToken;


#define FeatherWIDTH 5 // TODO: find a suitable number as Feather
@implementation FeatherBrush

+ (FeatherBrush*)sharedBrush
{
    if (sharedFeatherBrush == nil){
        dispatch_once(&sharedFeatherBrushOnceToken, ^{
            sharedFeatherBrush = [[FeatherBrush alloc] init];
        });
    }
    
    return sharedFeatherBrush;
}

- (BOOL)canInterpolationOptimized
{
    return YES;
}

- (UIImage*)brushImage:(UIColor *)color width:(float)width
{
    //使用图片不需要管本来的颜色，只需要形状是所需要的即可，颜色由rt_tint方法搞定
    UIImage* brushImage = [UIImage imageNamed:@"brush_dot7"];
    brushImage = [brushImage imageByScalingAndCroppingForSize:CGSizeMake(FeatherWIDTH, FeatherWIDTH)];
    
    //使用rt_tint方法需要color属性，其中color属性的alpha通道应置为1.0，否则染色效果会受底图影响
    UIColor *colorWithRGBOnly = [UIColor colorWithRed:color.red green:color.green blue:color.blue alpha:1.0];
    
    //染色，把所需形状染成用户所需颜色，不透明
    UIImage *tinted = [brushImage rt_tintedImageWithColor:colorWithRGBOnly
                                                    level:1.0f];
    
    //考虑??TODO
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
    return FeatherWIDTH;
}

- (float)firstPointWidth:(float)defaultWidth
{
    return FeatherWIDTH;
}

- (int)interpolationLength:(float)brushWidth        // 当前笔刷大小
                 distance1:(float)distance1         // 当前BeginDot和ControlDot的距离
                 distance2:(float)distance2         // 当前EndDot和ControlDot的距离
{
    double speedFactor = (distance1) / FeatherWIDTH;
    double typeFactor = 2.0;// 针对各种笔刷的调节因子，经过实践所得(有些笔需要更密集的插值，如钢笔；有些则相反，如蜡笔)
    int interpolationLength = INTERPOLATION * speedFactor * typeFactor;
    
    return interpolationLength;
    
}

-(void)randomShakePointX:(float*)pointX
                  PointY:(float*)pointY
                  PointW:(float*)pointW
        WithDefaultWidth:(float)defaultWidth
{
    //empty method
}

@end
