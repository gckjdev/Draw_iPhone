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

- (BOOL)canInterpolationOptimized
{
    return YES;
}

- (UIImage*)brushImage:(UIColor *)color
                 width:(float)width
{
    //在context上画出一个渐变园
    UIImage *brushImage;
//    UIGraphicsBeginImageContext(CGSizeMake(width, width));
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, width), NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext(CGSizeMake(width, width));

    CGContextRef ctx = UIGraphicsGetCurrentContext();//this is the context
    CGFloat wd = width / 2.0f;
    CGPoint pt = CGPointMake(wd, wd);//this is start center
    CGFloat fc = [color alpha];//this is hard degree, kind of change from alpha
    
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0,  1.0 };
    CGFloat* comp = (CGFloat *)CGColorGetComponents(color.CGColor);
    
    CGFloat colors[12] = { comp[0], comp[1], comp[2], fc,//star color with RGBA
            comp[0], comp[1], comp[2], 0.0 };//end color with RGBA
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, colors, locations, num_locations);
    CGContextDrawRadialGradient(ctx, gradient, pt, 0.0f, pt, wd, 0);
    CGContextFlush(ctx);
    brushImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CFRelease(gradient);
    CFRelease(colorspace);
    
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
    double speedFactor = (distance1 + distance2/2) / brushWidth;
    double typeFactor = 1.0; // 针对各种笔刷的调节因子，经过实践所得(有些笔需要更密集的插值，如钢笔；有些则相反，如蜡笔)
    int interpolationLength = INTERPOLATION * speedFactor * typeFactor + 1;

    return interpolationLength;
}


- (void)shakePointWithRandomList:(NSArray *)randomList atIndex:(NSInteger)index PointX:(float *)pointX PointY:(float *)pointY PointW:(float *)pointW withDefaultWidth:(float)defaultWidth
{
    //do nothing
}

@end