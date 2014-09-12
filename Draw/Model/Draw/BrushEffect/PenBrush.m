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
    UIImage* brushImage = [UIImage imageNamed:@"brush_ellipse"];
    
    brushImage = [brushImage imageByScalingAndCroppingForSize:CGSizeMake(width, width)];
    
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
    double tempWidth = currentWidth;
    
    if(tempWidth < threshold/4) tempWidth +=threshold / 16;
    else if(tempWidth > threshold) tempWidth = threshold;
    else
    {
        double accelerate = distance2 - distance1;
        if( accelerate / threshold > 0.1)
            tempWidth += (threshold / 8);
        else if (accelerate / threshold < 0.0)
            tempWidth -= (threshold / 8);
        
        if(tempWidth < threshold / 4)
            tempWidth = threshold / 4;
    }
    
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
//    int disFactor = 1;
//    
//    double sizeFactor = 1;
    
    int interpolationLength = INTERPOLATION * 20;
    
    return interpolationLength;
}

-(void)randomShakePointX:(float*)pointX
                  PointY:(float*)pointY
{
    //do nothing

}

@end
