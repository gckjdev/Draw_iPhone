//
//  DrawFrame.m
//  Draw
//
//  Created by gamy on 13-3-16.
//
//

#define IPHONE_DEFAULT_RECT CGRectMake(0.0f, 0.0f, 300.0f, 300.0f)
#define IPAD_DEFAULT_RECT CGRectMake(0.0f, 0.0f, 700.0f, 700.0f)

#define IPAD_HORIZONTAL_RECT CGRectMake(0.0f, 0.0f, 700.0f, 432.0f)
#define IPAD_VERTICAL_RECT CGRectMake(0.0f, 0.0f, 432.0f, 700.0f)

#define IPAD_LARGE_RECT CGRectMake(0.0f, 0.0f, 1024.0f, 1024.0f)
#define IPAD_SCREEN_HORIZONTAL_RECT CGRectMake(0.0f, 0.0f, 1024.0f, 768.0f)

#define IPAD_SCREEN_VERTICAL_RECT CGRectMake(0.0f, 0.0f, 768.0f, 1024.0f)


#define IPHONE5_HORIZONTAL_RECT CGRectMake(0.0f, 0.0f, 1136.0f, 640.0f)
#define IPHONE5_VERTICAL_RECT CGRectMake(0.0f, 0.0f, 640.0f, 1136.0f)


#define ANDROID_HORIZONTAL_RECT CGRectMake(0.0f, 0.0f, 800.0f, 480.0f)
#define ANDROID_VERTICAL_RECT CGRectMake(0.0f, 0.0f, 480.0f, 800.0f)


#define IPHONE_DEPRECATED_RECT CGRectMake(0.0f, 0.0f, 304.0f, 320.0f)
#define IPAD_DEPRECATED_RECT CGRectMake(0.0f, 0.0f, 730.0f, 698.0f)

#define CONTEST_BILLBOARD_RECT CGRectMake(0.0f, 0.0f, 700.0f, 268.0f)


#define MAX_WIDTH 1024.0f

#import "CanvasRect.h"
#import <QuartzCore/QuartzCore.h>



@implementation CanvasRect

- (id)initWithCanvasStyle:(CanvasRectStyle)style
{
    self = [super init];
    if (self) {
        self.rect = [CanvasRect rectForCanvasRectStype:style];
        self.style = style;
    }
    return self;
}

+ (CanvasRect *)canvasRectWithStyle:(CanvasRectStyle)style;
{
    return [[[CanvasRect alloc] initWithCanvasStyle:style] autorelease];
}

+ (CanvasRect *)canvasRectWithRect:(CGRect)rect
{
    for (CanvasRectStyle style = CanvasRectNo + 1; style < CanvasRectStyleCount; ++ style) {
        CGRect r = [CanvasRect rectForCanvasRectStype:style];
        if (CGRectEqualToRect(rect, r)) {
            return [CanvasRect canvasRectWithStyle:style];
        }
    }
    if (CGRectEqualToRect(rect, [CanvasRect deprecatedIPadRect])) {
        return [CanvasRect canvasRectWithStyle:iPadDeprecatedRect];
    }
    if (CGRectEqualToRect(rect, [CanvasRect deprecatedIPhoneRect])) {
        return [CanvasRect canvasRectWithStyle:iPhoneDeprecatedRect];
    }
    
    return nil;
}

+ (CGRect)rectForCanvasRectStype:(CanvasRectStyle)style
{
    switch (style) {
        case iPhoneDefaultRect:
        {
            return IPHONE_DEFAULT_RECT;
        }
        case iPadDefaultRect:
        {
            return IPAD_DEFAULT_RECT;
        }
        case iPadHorizontalRect:
        {
            return IPAD_HORIZONTAL_RECT;
        }
        case iPadVerticalRect:
        {
            return IPAD_VERTICAL_RECT;
        }
        case iPadLargeRect:
        {
            return IPAD_LARGE_RECT;
        }
        case iPadScreenHorizontalRect:
        {
            return IPAD_SCREEN_HORIZONTAL_RECT;
        }
        case iPadScreenVerticalRect:
        {
            return IPAD_SCREEN_VERTICAL_RECT;
        }
        case iPhone5HorizontalRect:
        {
            return IPHONE5_HORIZONTAL_RECT;
        }
        case iPhone5VerticalRect:
        {
            return IPHONE5_VERTICAL_RECT;
        }
        case iPhoneDeprecatedRect:
        {
            return IPHONE_DEPRECATED_RECT;
        }
        case iPadDeprecatedRect:
        {
            return IPAD_DEPRECATED_RECT;
        }
        case ContestBillboardRect:
        {
            return CONTEST_BILLBOARD_RECT;
        }
        case AndroidHorizontalRect:
        {
            return ANDROID_HORIZONTAL_RECT;
        }
        case AndroidVerticalRect:
        {
            return ANDROID_VERTICAL_RECT;
        }
            
        default:
            return [CanvasRect defaultRect];
    }
}

+ (CGRect)deprecatedRect
{
    if (ISIPAD) {
        return IPAD_DEPRECATED_RECT;
    }
    return IPHONE_DEPRECATED_RECT;
}

+ (CGRect)deprecatedIPhoneRect
{
    return IPHONE_DEPRECATED_RECT;
}

+ (CGRect)deprecatedIPadRect
{
    return IPAD_DEPRECATED_RECT;
}


+ (CanvasRectStyle)defaultCanvasRectStyle
{
    if (ISIPAD) {
        return iPadDefaultRect;
    }
    return iPhoneDefaultRect;

}

+ (CGRect)defaultRect
{
    if (ISIPAD) {
        return IPAD_DEFAULT_RECT;
    }
    return IPHONE_DEFAULT_RECT;
}

+ (CGRect)randRect
{
    NSInteger rand = random()%10 + 1;
    return [CanvasRect rectForCanvasRectStype:rand];
}

+ (CanvasRectStyle *)getRectStyleList
{
    //    if (ISIPAD) {
    static CanvasRectStyle list[] = {
        iPhoneDefaultRect,
        iPadDefaultRect,
        iPadLargeRect,
        
        iPadHorizontalRect,
        iPadScreenHorizontalRect,
        iPhone5HorizontalRect,
        
        iPadVerticalRect,
        iPadScreenVerticalRect,
        iPhone5VerticalRect,
        ContestBillboardRect,
        AndroidVerticalRect,
        AndroidHorizontalRect,
        CanvasRectEnd
    };
    return list;
}



+ (CanvasRectStyle)canvasRectStyleFromItemType:(ItemType)itemType
{
    return itemType - CanvasRectStart;
}
+ (ItemType)itemTypeFromCanvasRectStyle:(CanvasRectStyle)canvasRectStyle
{
    return CanvasRectStart + canvasRectStyle;
}


@end



