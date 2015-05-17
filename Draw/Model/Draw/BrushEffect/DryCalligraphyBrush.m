//
//  DryCalligraphyBrush.m
//  Draw
//
//  Created by 黄毅超 on 14/10/21.
//
//

#import "DryCalligraphyBrush.h"

@implementation DryCalligraphyBrush

static DryCalligraphyBrush* sharedDryCalligraphyBrush;
static dispatch_once_t sharedDryCalligraphyBrushOnceToken;

+ (DryCalligraphyBrush*)sharedBrush
{
    if (sharedDryCalligraphyBrush == nil){
        dispatch_once(&sharedDryCalligraphyBrushOnceToken, ^{
            sharedDryCalligraphyBrush = [[DryCalligraphyBrush alloc] init];
        });
    }
    
    return sharedDryCalligraphyBrush;
}

- (UIImage*)brushImage:(UIColor *)color width:(float)width
{
    //使用图片不需要管本来的颜色，只需要形状是所需要的即可，颜色由rt_tint方法搞定
    UIImage* brushImage = [UIImage imageNamed:@"brush_ellipse5.png"];
    //使用rt_tint方法需要color属性，其中color属性的alpha通道应置为1.0，否则染色效果会受底图影响
    UIColor *colorWithRGBOnly = [UIColor colorWithRed:color.red green:color.green blue:color.blue alpha:1.0];
    
    //染色，把所需形状染成用户所需颜色，不透明
    UIImage *tinted = [brushImage rt_tintedImageWithColor:colorWithRGBOnly];
    
    CGFloat alpha = [color alpha] / 2;
    
    brushImage = [DrawUtils imageByApplyingAlpha:alpha image:tinted];
    
    return brushImage;
}


- (float)calculateWidthWithThreshold:(float)threshold
                           distance1:(float)distance1
                           distance2:(float)distance2
                        currentWidth:(float)currentWidth
{
    //TODO
    /*
     This is the mathematicla model of the Pen Brush
     which is not the suitable one for Calligraphy
     
     Anyhow, they are to some degree similar
     Therefore, i would have to make it different
     
     Attetion:
     maybe there are some copyright problem between here and my lab's result
     I could only use the thoughts that originated from my own
     */
    
    
    //Time measurements are not added here due to mobile calculation capability
    //Use distance instead of speed factor
    double tempWidth = currentWidth;
    
    double maxW = threshold;
    double minW = threshold / 4;
    double maxS = 50;
    double minS = 0;
    double R = (maxW - minW) / (maxS - minS);
    double s = (distance1+distance2) / 2;
    
    tempWidth = maxW - s * R;
    
    if (tempWidth < minW) {
        tempWidth = minW;
    }
    if (tempWidth > maxW) {
        tempWidth = maxW;
    }
    
    return tempWidth;
}



@end
