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

- (UIImage*)brushImage:(UIColor *)color
{
    UIImage* brushImage = [UIImage imageNamed:@"brush_dot7.png"];
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
    int disFactor = (distance1 + distance2) / 50 + 1;
    
    double sizeFactor = 72.0 / brushWidth;
    
    int interpolationLength = INTERPOLATION * disFactor * sizeFactor;
    
    PPDebug(@"<interpolationlength> %d",interpolationLength);
    return interpolationLength;
}

-(void)randomShakePointX:(float*)pointX
                  PointY:(float*)pointY
{
    float xRandomOffset = arc4random() % 4;
    float yRandomOffset = arc4random() % 4;
    
    NSInteger xShouldShake = arc4random() % 5;
    NSInteger yShouldShake = arc4random() % 5;
    
    if(xShouldShake == 0)
        *pointX+=xRandomOffset;
    else if(xShouldShake == 1)
        *pointX-=xRandomOffset;
    
    if(yShouldShake == 0)
        *pointY+=yRandomOffset;
    else if(yShouldShake == 1)
        *pointY-=yRandomOffset;

}

@end