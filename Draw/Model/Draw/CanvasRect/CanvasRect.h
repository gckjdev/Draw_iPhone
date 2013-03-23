//
//  DrawFrame.h
//  Draw
//
//  Created by gamy on 13-3-16.
//
//

#import <Foundation/Foundation.h>
#import "DrawUtils.h"

typedef enum{
    CanvasRectEnd = -1,
    iPhoneDefaultRect = 1,
    iPadDefaultRect,
    iPadHorizontalRect,
    iPadVerticalRect,
    iPadLargeRect,
    iPadScreenHorizontalRect,
    iPadScreenVerticalRect,
    iPhone3ScreenRect,
    iPhone4ScreenRect,
    iPhone5ScreenRect,
    
    iPhoneDeprecatedRect = 10000,
    iPadDeprecatedRect = 10001,
}CanvasRectStype;

@interface CanvasRect : NSObject

@property(nonatomic, assign)CGRect rect;

+ (CanvasRect *)canvasRectWithStyle:(CanvasRectStype)style;
+ (CGRect)rectForCanvasRectStype:(CanvasRectStype)style;
+ (CGRect)deprecatedRect;
+ (CGRect)defaultRect;
+ (CGRect)deprecatedIPhoneRect;
+ (CGRect)randRect;

@end


static const CGRect* getRectList();
//static CGRect* getIPhoneRectList;

@interface CanvasRectView : UIControl
{
    
}

- (id)initWithCanvasRect:(CGRect)rect;

@end







