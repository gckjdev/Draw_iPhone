//
//  DrawFrame.h
//  Draw
//
//  Created by gamy on 13-3-16.
//
//

#import <Foundation/Foundation.h>
#import "DrawUtils.h"
#import "ItemType.h"

typedef enum{
    CanvasRectEnd = -1,
    CanvasRectNo = 0,
    iPhoneDefaultRect = 1,
    iPadDefaultRect,
    
    iPadHorizontalRect,
    iPadVerticalRect,
    iPadLargeRect,
    iPadScreenHorizontalRect,
    iPadScreenVerticalRect,

    iPhone5HorizontalRect,
    iPhone5VerticalRect,
    CanvasRectStyleCount,
    iPhoneDeprecatedRect = 10000,
    iPadDeprecatedRect = 10001,
}CanvasRectStyle;

@interface CanvasRect : NSObject

@property(nonatomic, assign)CGRect rect;
@property(nonatomic, assign)CanvasRectStyle style;


+ (CanvasRect *)canvasRectWithRect:(CGRect)rect;
+ (CanvasRect *)canvasRectWithStyle:(CanvasRectStyle)style;
+ (CGRect)rectForCanvasRectStype:(CanvasRectStyle)style;
+ (CGRect)deprecatedRect;
+ (CGRect)defaultRect;
+ (CanvasRectStyle)defaultCanvasRectStyle;
+ (CGRect)deprecatedIPhoneRect;
+ (CGRect)randRect;
+ (CanvasRectStyle *)getRectStyleList;
+ (CanvasRectStyle)canvasRectStyleFromItemType:(ItemType)itemType;
+ (ItemType)itemTypeFromCanvasRectStyle:(CanvasRectStyle)canvasRectStyle;

@end




