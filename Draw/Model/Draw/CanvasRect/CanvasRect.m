//
//  DrawFrame.m
//  Draw
//
//  Created by gamy on 13-3-16.
//
//

#define IPHONE_DEFAULT_RECT CGRectMake(0, 0, 300, 300)
#define IPAD_DEFAULT_RECT CGRectMake(0, 0, 700, 700)
#define IPAD_HORIZONTAL_RECT CGRectMake(0, 0, 700, 432)
#define IPAD_VERTICAL_RECT CGRectMake(0, 0, 432, 700)
#define IPAD_LARGE_RECT CGRectMake(0, 0, 1024, 1024)
#define IPAD_SCREEN_HORIZONTAL_RECT CGRectMake(0, 0, 1024, 768)
#define IPAD_SCREEN_VERTICAL_RECT CGRectMake(0, 0, 768, 1024)
#define IPHONE3_SCREEN_RECT CGRectMake(0, 0, 320, 480)
#define IPHONE4_SCREEN_RECT CGRectMake(0, 0, 640, 960)
#define IPHONE5_SCREEN_RECT CGRectMake(0, 0, 640, 1136)

#define IPHONE_DEPRECATED_RECT CGRectMake(0, 0, 304, 320)
#define IPAD_DEPRECATED_RECT CGRectMake(0, 0, 730, 698)


#import "CanvasRect.h"

@implementation CanvasRect

- (id)initWithCanvasStyle:(CanvasRectStype)style
{
    self = [super init];
    if (self) {
        self.rect = [CanvasRect rectForCanvasRectStype:style];
    }
    return self;
}

+ (CanvasRect *)canvasRectWithStyle:(CanvasRectStype)style;
{
    return [[[CanvasRect alloc] initWithCanvasStyle:style] autorelease];
}

+ (CGRect)rectForCanvasRectStype:(CanvasRectStype)style
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
        case iPhone3ScreenRect:
        {
            return IPHONE3_SCREEN_RECT;
        }
        case iPhone4ScreenRect:
        {
            return IPHONE4_SCREEN_RECT;
        }
        case iPhone5ScreenRect:
        {
            return IPHONE5_SCREEN_RECT;
        }
        case iPhoneDeprecatedRect:
        {
            return IPHONE_DEPRECATED_RECT;
        }
        case iPadDeprecatedRect:
        {
            return IPAD_DEPRECATED_RECT;
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

@end

static const CGRect* getRectList()
{
    if (ISIPAD) {
        static const CGRect list[] = {
            iPhoneDefaultRect,
            iPadDefaultRect,
            iPadHorizontalRect,
            iPadVerticalRect,
            iPadLargeRect,
            iPadScreenHorizontalRect,
            iPadScreenVerticalRect,
            iPhone3ScreenRect,
            iPhone4ScreenRect,
            iPhone5ScreenRect,
            CanvasRectEnd
        };
        return list;
    }else{
        static const CGRect list[] = {
            iPhoneDefaultRect,
            iPadDefaultRect,
            /*
            iPadHorizontalRect,
            iPadVerticalRect,
            iPadLargeRect,
            iPadScreenHorizontalRect,
            iPadScreenVerticalRect,
            */
            iPhone3ScreenRect,
            iPhone4ScreenRect,
            iPhone5ScreenRect,
            CanvasRectEnd
        };
        return list;
    }
    return NULL;
}