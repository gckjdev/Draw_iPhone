//
//  PenBrush.m
//  Draw
//
//  Created by 黄毅超 on 14-9-3.
//
//

#import "PenBrush.h"

static PenBrush* sharedPenBrush;
static dispatch_once_t sharedPenBrushOnceToken;

@implementation PenBrush

+ (PenBrush*)sharedBrush
{
    if (sharedPenBrush == nil){
        dispatch_once(&sharedPenBrushOnceToken, ^{
            sharedPenBrush = [[PenBrush alloc] init];
        });
    }
    
    return sharedPenBrush;
}

- (UIImage*)brushImage:(UIColor *)color width:(float)width
{
    //使用图片不需要管本来的颜色，只需要形状是所需要的即可，颜色由rt_tint方法搞定
    UIImage* brushImage = [UIImage imageNamed:@"brush_ellipse1.png"];
    //使用rt_tint方法需要color属性，其中color属性的alpha通道应置为1.0，否则染色效果会受底图影响
    UIColor *colorWithRGBOnly = [UIColor colorWithRed:color.red green:color.green blue:color.blue alpha:1.0];
    
    //染色，把所需形状染成用户所需颜色，不透明
    UIImage *tinted = [brushImage rt_tintedImageWithColor:colorWithRGBOnly];

    CGFloat alpha = [color alpha] / 5;
    
    brushImage = [DrawUtils imageByApplyingAlpha:alpha image:tinted];
    
    return brushImage;
}

- (BOOL)isWidthFixedSize
{
    return NO;
}


- (float)calculateWidthWithThreshold:(float)threshold
                           distance1:(float)distance1
                           distance2:(float)distance2
                        currentWidth:(float)currentWidth
{
    double tempWidth = currentWidth;
    
    double maxW = threshold;
    double minW = threshold / 5;
    double maxS = 50;
    double minS = 0;
    double R = (maxW - minW) / (maxS - minS);
    double s = (distance1+distance2) / 2;
    
    tempWidth = minW + s * R;

    if (tempWidth < minW) {
        tempWidth = minW;
    }
    if (tempWidth > maxW) {
        tempWidth = maxW;
    }

//    PPDebug(@"speed:%f ; width: %f", (distance1+distance2)/2, tempWidth);
    
    return tempWidth;
}


- (float)firstPointWidth:(float)defaultWidth
{
    return 0;
}

- (int)interpolationLength:(float)brushWidth        // 当前笔刷大小
                 distance1:(float)distance1         // 当前BeginDot和ControlDot的距离
                 distance2:(float)distance2         // 当前EndDot和ControlDot的距离
{
   double typeFactor = 8;  // 针对各种笔刷的调节因子，经过实践所得(有些笔需要更密集的插值，如钢笔；有些则相反，如蜡笔)
    int interpolationLength = INTERPOLATION * typeFactor;
    
    return interpolationLength;
    
}

-(void)randomShakePointX:(float*)pointX
                  PointY:(float*)pointY
                  PointW:(float*)pointW
        WithDefaultWidth:(float)defaultWidth
{
    //do nothing

}

@end
