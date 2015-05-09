//
//  NewCrayonBrush.m
//  Draw
//
//  Created by HuangCharlie on 5/9/15.
//
//

#import "NewCrayonBrush.h"

@implementation NewCrayonBrush

static NewCrayonBrush* sharedNewCrayonBrush;
static dispatch_once_t sharedNewCrayonBrushOnceToken;

+ (NewCrayonBrush*)sharedBrush
{
    if (sharedNewCrayonBrush == nil){
        dispatch_once(&sharedNewCrayonBrushOnceToken, ^{
            sharedNewCrayonBrush = [[NewCrayonBrush alloc] init];
        });
    }
    return sharedNewCrayonBrush;
}

- (BOOL)canInterpolationOptimized
{
    return YES;
}

- (UIImage*)brushImage:(UIColor *)color width:(float)width
{
    //使用图片不需要管本来的颜色，只需要形状是所需要的即可，颜色由rt_tint方法搞定
    UIImage* brushImage = [UIImage imageNamed:@"brush_dot8"];
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
    double typeFactor = 0.5;// 针对各种笔刷的调节因子，经过实践所得(有些笔需要更密集的插值，如钢笔；有些则相反，如蜡笔)
    int interpolationLength = INTERPOLATION * speedFactor * typeFactor + 1;
    
    return interpolationLength;
    
}

-(NSArray*)randomNumberList
{
    NSArray* array = [NSArray arrayWithObjects:
                @(1588378487),
                @(1772215198),
                @(987914269),
                @(3971455568),
                @(384465356),
                @(34139862),
                @(438996405),
                @(4058246780),
                @(1869106333),
                @(808551257),
//                718728903,
//                4005641480,
//                469048123,
//                3186885006,
//                2739422078,
//                423328318,
//                3573519335,
//                2453651805,
//                1445043410,
//                1745640219,
//                2123644696,
//                4175411392,
//                1372167685,
//                1977050621,
//                1998079260,
//                4276582290,
//                2697175725,
//                2576241280,
//                3585897675,
//                4165970056,
//                62105798,
//                3296063767,
//                1938448109,
//                2979579161,
//                1776255649,
//                353288533,
//                412893068,
//                4140810182,
//                221708571,
//                2719388154,
//                1306814619,
//                2415507135,
//                1046411349,
//                3579452263,
//                3058110341,
//                2584921463,
//                2525485424,
//                3610886636,
//                1972999307,
//                2714057043,
//                2686284776,
//                2183939048,
//                1991858240,
//                242306508,
//                3009179851,
//                198681006,
//                2302964946,
//                4294081540,
//                2334889278,
//                1577688823,
//                2325703313,
//                2095521830,
//                3563292614,
//                2495429203,
//                2767451042,
//                1519954454,
//                2322414033,
//                705999783,
//                1939881099,
//                2179468732,
//                934024288,
//                414050267,
//                1656825682,
//                1846315775,
//                289739438,
//                866260931,
//                1439781678,
//                1849644467,
//                3607454409,
//                1265883309,
//                4109437829,
//                1802246890,
//                2590479792,
//                444393461,
//                1047260895,
//                4011995700,
//                3114245995,
//                4004175361,
//                2287601661,
//                3732908522,
//                88296662,
//                1620036106,
//                103357717,
//                3540618397,
//                1483449341,
//                194696025,
//                2236768761,
//                660207190,
//                2057646954,
                      nil];
    return array;
}

-(void)shakePointWithRandomList:(NSArray*)randomList
                        atIndex:(NSInteger)index
                         PointX:(float*)pointX
                         PointY:(float*)pointY
                         PointW:(float*)pointW
               withDefaultWidth:(float)defaultWidth
{
    NSInteger randomFactor = defaultWidth / 8 + 2;

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