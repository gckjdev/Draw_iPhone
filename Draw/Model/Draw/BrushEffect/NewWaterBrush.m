//
//  NewWaterBrush.m
//  Draw
//
//  Created by HuangCharlie on 5/9/15.
//
//

#import "NewWaterBrush.h"

@implementation NewWaterBrush


static NewWaterBrush* sharedNewWaterBrush;
static dispatch_once_t sharedNewWaterBrushOnceToken;

+ (NewWaterBrush*)sharedBrush
{
    if (sharedNewWaterBrush == nil){
        dispatch_once(&sharedNewWaterBrushOnceToken, ^{
            sharedNewWaterBrush = [[NewWaterBrush alloc] init];
        });
    }
    return sharedNewWaterBrush;
}
- (BOOL)canInterpolationOptimized
{
    return YES;
}

- (UIImage*)brushImage:(UIColor *)color
                 width:(float)width
{
    //使用图片不需要管本来的颜色，只需要形状是所需要的即可，颜色由rt_tint方法搞定
    UIImage* brushImage = [UIImage imageNamed:@"brush_oil2.png"];
    //使用rt_tint方法需要color属性，其中color属性的alpha通道应置为1.0，否则染色效果会受底图影响
    UIColor *colorWithRGBOnly = [UIColor colorWithRed:color.red green:color.green blue:color.blue alpha:1.0];
    
    //染色，把所需形状染成用户所需颜色，不透明
    UIImage *tinted = [brushImage rt_tintedImageWithColor:colorWithRGBOnly
                                                    level:1.0f];
    
    //考虑到插值后笔刷不断叠加，故透明度应做适当变换
    float alpha = [color alpha] / 10;
    
    brushImage = [DrawUtils imageByApplyingAlpha:alpha  image: tinted];
    //    brushImage = tinted;
    
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
    double speedFactor =  ((distance1 + distance2)/2)/ brushWidth;
    double typeFactor = 2.0; // 针对各种笔刷的调节因子，经过实践所得(有些笔需要更密集的插值，如钢笔；有些则相反，如蜡笔)
    int interpolationLength = INTERPOLATION * speedFactor * typeFactor + 1;
    
    return interpolationLength;
}

-(void)shakePointWithRandomList:(NSArray*)randomList
                        atIndex:(NSInteger)index
                         PointX:(float*)pointX
                         PointY:(float*)pointY
                         PointW:(float*)pointW
               withDefaultWidth:(float)defaultWidth
{
    NSInteger randomFactor = defaultWidth / 2 + 2;
    
    NSInteger ranIndex = index;
    
    //生成 0 - randomFactor 范围内的随机数，作为振动幅度
    ranIndex=(ranIndex+0)%RANDOM_COUNT;
    float xRandomOffset = [[randomList objectAtIndex:ranIndex]intValue] % randomFactor;
    ranIndex=(ranIndex+1)%RANDOM_COUNT;
    float yRandomOffset = [[randomList objectAtIndex:ranIndex]intValue] % randomFactor;
    ranIndex=(ranIndex+2)%RANDOM_COUNT;
    float wRandomOffset = [[randomList objectAtIndex:ranIndex]intValue] % randomFactor;
    
    //生成 0 - 100 范围内的随机数， 作为振动概率
    ranIndex=(ranIndex+3)%RANDOM_COUNT;
    NSInteger xShouldShake = [[randomList objectAtIndex:ranIndex]intValue] % SHAKERANDOMRANGE;
    ranIndex=(ranIndex+4)%RANDOM_COUNT;
    NSInteger yShouldShake = [[randomList objectAtIndex:ranIndex]intValue] % SHAKERANDOMRANGE;
    ranIndex=(ranIndex+5)%RANDOM_COUNT;
    NSInteger wShouldShake = [[randomList objectAtIndex:ranIndex]intValue] % SHAKERANDOMRANGE;
    
    //符合概率要求的地方，实行振动（通过调节if条件里面的参数来控制概率，通过offset控制振幅）
    if(xShouldShake < 40)
        *pointX += xRandomOffset;
    else if(xShouldShake > 60 )
        *pointX -= xRandomOffset;
    
    if(yShouldShake < 40)
        *pointY += yRandomOffset;
    else if(yShouldShake >= 60)
        *pointY -= yRandomOffset;
    
    
    if(wShouldShake < 40)
        *pointW += wRandomOffset;
    else if (wShouldShake > 60)
        *pointW -=wRandomOffset;
}

@end