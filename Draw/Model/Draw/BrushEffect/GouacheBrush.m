//
//  GouacheBrush.m
//  Draw
//
//  Created by 黄毅超 on 14-9-3.
//
//

#import "GouacheBrush.h"

static GouacheBrush* sharedGouacheBrush;
static dispatch_once_t sharedGouacheBrushOnceToken;

@implementation GouacheBrush

+ (GouacheBrush*)sharedBrush
{
    if (sharedGouacheBrush == nil){
        dispatch_once(&sharedGouacheBrushOnceToken, ^{
            sharedGouacheBrush = [[GouacheBrush alloc] init];
        });
    }
    
    return sharedGouacheBrush;
}

- (UIImage*)brushImage:(UIColor *)color
{
    UIImage* brushImage = [UIImage imageNamed:@"brush_ellipse1.png"];
    UIImage *tinted = [brushImage rt_tintedImageWithColor:color
                                                    level:1.0f];
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
    int disFactor = (distance1 + distance2) / 10 + 1;
    
    double sizeFactor = 1;
    
    int interpolationLength = INTERPOLATION * disFactor * sizeFactor;
    
    return interpolationLength;
}

-(void)randomShakePointX:(float*)pointX
                  PointY:(float*)pointY
{
    //do nothing
}

@end
