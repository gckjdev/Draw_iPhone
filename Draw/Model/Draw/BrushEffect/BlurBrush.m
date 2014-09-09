//
//  BlurBrush.m
//  Draw
//
//  Created by 黄毅超 on 14-9-3.
//
//

#import "BlurBrush.h"

static BlurBrush* sharedBlurBrush;
static dispatch_once_t sharedBlurBrushOnceToken;

@implementation BlurBrush

+ (BlurBrush*)sharedBrush
{
    if (sharedBlurBrush == nil){
        dispatch_once(&sharedBlurBrushOnceToken, ^{
            sharedBlurBrush = [[BlurBrush alloc] init];
        });
    }
    
    return sharedBlurBrush;
}

- (UIImage*)brushImage:(UIColor *)color
{
//size暂时用20，考虑传入参数 TODO
    
    //在context上画出一个渐变园
    UIImage *brushImage;
    UIGraphicsBeginImageContext(CGSizeMake(20, 20));
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGFloat wd = 20 / 2.0f;
	CGPoint pt = CGPointMake(wd, wd);
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	size_t num_locations = 2;
	CGFloat locations[2] = { 1.0, 0.0 };
	CGFloat* comp = (CGFloat *)CGColorGetComponents(color.CGColor);
	CGFloat fc = sinf(((0.6/*这个参数是硬度，暂时固定*/ / 5.0f) * M_PI ) / 2.0f);
	CGFloat colors[8] = { comp[0], comp[1], comp[2], 0.0f, comp[0], comp[1], comp[2], fc };
	CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, colors, locations, num_locations);
	CGContextDrawRadialGradient(ctx, gradient, pt, 0.0f, pt, wd, 0);
	CGContextFlush(ctx);
	brushImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	CFRelease(gradient);
	CFRelease(colorspace);
    
    //以该渐变园作为brushImage
    
    brushImage = [DrawUtils imageByApplyingAlpha:[color alpha] image:brushImage];
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
    if(distance1 == 0 || distance2 == 0)
        return 0;
    
    else{
        int disFactor = (distance1 + distance2) / 10 + 1;
        double sizeFactor = 1;
        
        int interpolationLength= INTERPOLATION * disFactor * sizeFactor;
        
        return interpolationLength;
    }

}

-(void)randomShakePointX:(float*)pointX
                  PointY:(float*)pointY
{
    //do nothing
}


@end