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

//<<<<<<< HEAD
//- (UIImage*)brushImage:(UIColor *)color width:(float)width
//{
//    //在context上画出一个渐变园
//    UIImage *brushImage;
////    UIGraphicsBeginImageContext(CGSizeMake(width, width));
//
//    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
//        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, width), NO, [UIScreen mainScreen].scale);
//    else
//        UIGraphicsBeginImageContext(CGSizeMake(width, width));
//    
//	CGContextRef ctx = UIGraphicsGetCurrentContext();
//	CGFloat wd = width / 2.0f;
//	CGPoint pt = CGPointMake(wd, wd);
//	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
//	size_t num_locations = 2;
//	CGFloat locations[2] = { 1.0, 0.0 };
//	CGFloat* comp = (CGFloat *)CGColorGetComponents(color.CGColor);
//	CGFloat fc = sinf(((0.6/*这个参数是硬度，暂时固定*/ / 5.0f) * M_PI ) / 2.0f);
//	CGFloat colors[8] = { comp[0], comp[1], comp[2], 0.0f, comp[0], comp[1], comp[2], fc };
//	CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, colors, locations, num_locations);
//	CGContextDrawRadialGradient(ctx, gradient, pt, 0.0f, pt, wd, 0);
//	CGContextFlush(ctx);
//	brushImage = UIGraphicsGetImageFromCurrentImageContext();
//	UIGraphicsEndImageContext();
//	CFRelease(gradient);
//	CFRelease(colorspace);
//=======

- (UIImage*)brushImage:(UIColor *)color
                 width:(float)width
{
    //在context上画出一个渐变园
    UIImage *brushImage;
    UIGraphicsBeginImageContext(CGSizeMake(width, width));
    CGContextRef ctx = UIGraphicsGetCurrentContext();//this is the context
    CGFloat wd = width / 2.0f;
    CGPoint pt = CGPointMake(wd, wd);//this is start center
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0,  1.0 };
    CGFloat* comp = (CGFloat *)CGColorGetComponents(color.CGColor);
    
    CGFloat colors[12] = { comp[0], comp[1], comp[2], 1.0f,//star color with RGBA
 //           comp[0], comp[1], comp[2], 0.5,
            comp[0], comp[1], comp[2], 0.0 };//end color with RGBA
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorspace, colors, locations, num_locations);
    CGContextDrawRadialGradient(ctx, gradient, pt, 0.0f, pt, wd, 0);
    CGContextFlush(ctx);
    brushImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CFRelease(gradient);
    CFRelease(colorspace);
    
    //以该渐变园作为brushImage
    float alpha = [color alpha] ;
    brushImage = [DrawUtils imageByApplyingAlpha: alpha image:brushImage];
//*****************************************************************************************
//    UIImage *brushImage = [UIImage imageNamed:@"brush_gradient1@2x.png"];
//    //使用rt_tint方法需要color属性，其中color属性的alpha通道应置为1.0，否则染色效果会受底图影响
//    UIColor *colorWithRGBOnly = [UIColor colorWithRed:color.red green:color.green blue:color.blue alpha:1.0];
//    //染色，把所需形状染成用户所需颜色，不透明
//    UIImage *tinted = [brushImage rt_tintedImageWithColor:colorWithRGBOnly
//                                                    level:1.0f];
//    
//    float alpha = [color alpha];
//    brushImage = [DrawUtils imageByApplyingAlpha:alpha  image: tinted];

//    NSString *path=[NSString stringWithFormat:@"/Users/Linruin/Desktop/test.png"];
//    [brushImage saveImageToFile:path];
    
    return brushImage;

    
    
//<<<<<<< HEAD
////    brushImage = [DrawUtils imageByApplyingAlpha:[color alpha] image:brushImage];
//=======
//>>>>>>> f47cf69522bd4107a9228eb31adf58e8df085f48
//    return brushImage;
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
    double speedFactor = (distance1) / brushWidth;
    double typeFactor = 1; // 针对各种笔刷的调节因子，经过实践所得
    int interpolationLength = INTERPOLATION * speedFactor * typeFactor;

    return interpolationLength;
}

-(void)randomShakePointX:(float*)pointX
                  PointY:(float*)pointY
{
    //do nothing
}


@end