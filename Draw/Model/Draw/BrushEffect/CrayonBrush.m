//  CrayonBrush.m
//  Draw
//
//  Created by 黄毅超 on 14-9-3.
//
//

#import "CrayonBrush.h"

static CrayonBrush* sharedCrayonBrush;
static dispatch_once_t sharedCrayonBrushOnceToken;

@implementation CrayonBrush

+ (CrayonBrush*)sharedBrush
{
    if (sharedCrayonBrush == nil){
        dispatch_once(&sharedCrayonBrushOnceToken, ^{
            sharedCrayonBrush = [[CrayonBrush alloc] init];
        });
    }
    
    return sharedCrayonBrush;
}

- (UIImage*)brushImage:(UIColor *)color width:(float)width
{
    //使用图片不需要管本来的颜色，只需要形状是所需要的即可，颜色由rt_tint方法搞定
    UIImage* brushImage = [UIImage imageNamed:@"brush_dot6"];
    brushImage = [brushImage imageByScalingAndCroppingForSize:CGSizeMake(width, width)];

    //使用rt_tint方法需要color属性，其中color属性的alpha通道应置为1.0，否则染色效果会受底图影响
    UIColor *colorWithRGBOnly = [UIColor colorWithRed:color.red green:color.green blue:color.blue alpha:1.0];
    
    //染色，把所需形状染成用户所需颜色，不透明
    UIImage *tinted = [brushImage rt_tintedImageWithColor:colorWithRGBOnly
                                                    level:1.0f];
    
    //暂且当做蜡笔有透明度
    brushImage = [DrawUtils imageByApplyingAlpha:[color alpha]  image: tinted];
    
    
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
    return currentWidth;
}

- (float)firstPointWidth:(float)defaultWidth
{
    return defaultWidth;
}

- (int)interpolationLength:(float)brushWidth        // 当前笔刷大小
                 distance1:(float)distance1         // 当前BeginDot和ControlDot的距离
                 distance2:(float)distance2         // 当前EndDot和ControlDot的距离
{
    double speedFactor = (distance1) / brushWidth;
    double typeFactor = 2.0;
    int interpolationLength = INTERPOLATION * speedFactor * typeFactor + 1;
    
    return interpolationLength;

}

-(void)randomShakePointX:(float*)pointX
                  PointY:(float*)pointY
                  PointW:(float*)pointW
        WithDefaultWidth:(float)defaultWidth
{
    NSInteger randomFactor = defaultWidth / 8 + 2;
    
    float xRandomOffset = arc4random() % randomFactor;
    float yRandomOffset = arc4random() % randomFactor;
    float wRandomOffset = arc4random() % randomFactor;
    
    NSInteger xShouldShake = arc4random() % 3;
    NSInteger yShouldShake = arc4random() % 3;
    NSInteger wShouldShake = arc4random() % 3;
    
    if(xShouldShake == 0)
        *pointX += xRandomOffset;
    else if(xShouldShake == 1)
        *pointX -= xRandomOffset;
    
    if(yShouldShake == 0)
        *pointY += yRandomOffset;
    else if(yShouldShake == 1)
        *pointY -= yRandomOffset;
    

    if(wShouldShake == 0)
        *pointW += wRandomOffset;
    else if (wShouldShake == 1)
        *pointW -=wRandomOffset;

}

@end