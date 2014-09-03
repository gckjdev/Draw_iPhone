//
//  OilBrush.m
//  Draw
//
//  Created by 黄毅超 on 14-9-3.
//
//

#import "OilBrush.h"

static OilBrush* sharedOilBrush;
static dispatch_once_t sharedOilBrushOnceToken;

@implementation OilBrush

+ (OilBrush*)sharedBrush
{
    if (sharedOilBrush == nil){
        dispatch_once(&sharedOilBrushOnceToken, ^{
            sharedOilBrush = [[OilBrush alloc] init];
        });
    }
    
    return sharedOilBrush;
}

- (UIImage*)brushImage:(UIColor *)color
{
    UIImage* brushImage = [UIImage imageNamed:@"brush_oil2.png"];
    UIImage *tinted = [brushImage rt_tintedImageWithColor:color
                                                    level:1.0f];
    brushImage = tinted;
    return brushImage;
}

- (BOOL)isWidthFixedSize
{
    return YES;
}

- (float)calculateWidth:(BrushDot*)beginDot
                 endDot:(BrushDot*)endDot
             controlDot:(BrushDot*)controlDot
              distance1:(float)distance1
              distance2:(float)distance2
           defaultWidth:(float)defaultWidth;
{
    return defaultWidth;
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