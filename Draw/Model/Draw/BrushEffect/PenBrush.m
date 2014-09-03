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

#define FIXED_PEN_SIZE 16
- (float)calculateWidth:(BrushDot*)beginDot
                 endDot:(BrushDot*)endDot
             controlDot:(BrushDot*)controlDot
              distance1:(float)distance1
              distance2:(float)distance2
           defaultWidth:(float)defaultWidth;
{
    double tempWidth;
    double accelerate = distance2 - distance1;
    if( accelerate / FIXED_PEN_SIZE > 0.15)
        tempWidth  -= (FIXED_PEN_SIZE / 16);
    else if (accelerate / FIXED_PEN_SIZE < - 0.15)
        tempWidth += (FIXED_PEN_SIZE / 16);

    if(tempWidth > FIXED_PEN_SIZE) tempWidth = FIXED_PEN_SIZE;
    else if (tempWidth <= FIXED_PEN_SIZE / 4) tempWidth = FIXED_PEN_SIZE / 4;
    
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
