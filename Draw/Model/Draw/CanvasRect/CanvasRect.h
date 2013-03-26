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
//    iPhone3ScreenRect,
    iPhone5HorizontalRect,
    iPhone5VerticalRect,
    
    iPhoneDeprecatedRect = 10000,
    iPadDeprecatedRect = 10001,
}CanvasRectStyle;

@interface CanvasRect : NSObject

@property(nonatomic, assign)CGRect rect;

+ (CanvasRect *)canvasRectWithStyle:(CanvasRectStyle)style;
+ (CGRect)rectForCanvasRectStype:(CanvasRectStyle)style;
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

