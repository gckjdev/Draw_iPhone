//
//  PenCalligraphyBrush.m
//  Draw
//
//  Created by 黄毅超 on 14-9-3.
//
//

#import "PenCalligraphyBrush.h"

static PenCalligraphyBrush* sharedPenCalligraphyBrush;
static dispatch_once_t sharedPenCalligraphyBrushOnceToken;

@implementation PenCalligraphyBrush

+ (PenCalligraphyBrush*)sharedBrush
{
    if (sharedPenCalligraphyBrush == nil){
        dispatch_once(&sharedPenCalligraphyBrushOnceToken, ^{
            sharedPenCalligraphyBrush = [[PenCalligraphyBrush alloc] init];
        });
    }
    
    return sharedPenCalligraphyBrush;
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

@end