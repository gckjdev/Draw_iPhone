//
//  DrawInfo.m
//  Draw
//
//  Created by gamy on 13-7-26.
//
//

#import "DrawInfo.h"
#import "PPConfigManager.h"
#import "ShareImageManager.h"

@implementation ShareDrawInfo

- (void)dealloc
{
    PPDebug(@"%@ dealloc", self);
    PPRelease(_penColor);
    PPRelease(_eraserColor);
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.alpha = 1;
        self.penWidth = [PPConfigManager defaultPenWidth];
        self.penType = Pencil;
        self.lastPenType = Pencil;
//        self.shapeType = ShapeTypeNone;
//        self.touchType = TouchActionTypeDraw;
        self.penColor = [DrawColor blackColor];
//        self.bgColor = [DrawColor whiteColor];
//        self.shadow = nil;
//        self.gradient = nil;
        
        self.eraserAlpha = 1.0f;
        self.eraserWidth = [PPConfigManager defaultPenWidth];
        self.eraserColor = [DrawColor whiteColor];
    }
    return self;
}

+ (id)defaultShareDrawInfo
{
    ShareDrawInfo *info = [[[ShareDrawInfo alloc] init] autorelease];
    return info;
}

- (void)setAlpha:(CGFloat)alpha
{
    _alpha = alpha;
    self.penColor = [DrawColor colorWithColor:self.penColor];
    [self.penColor setAlpha:alpha];
}

- (void)setEraserAlpha:(CGFloat)alpha
{
    _eraserAlpha = alpha;
    self.eraserColor = [DrawColor colorWithColor:[DrawColor whiteColorWithAlpha:alpha]];
}

- (void)setPenColor:(DrawColor *)penColor
{
    if (penColor != _penColor) {
        [_penColor release];
        _penColor = [[DrawColor colorWithColor:penColor] retain];
        [_penColor setAlpha:_alpha];
    }
}


- (void)setPenType:(ItemType)penType
{
    if (_penType != Eraser) {
        self.lastPenType = _penType;
    }
    _penType = penType;
}

- (DrawColor*)itemColor
{
    if (self.penType == Eraser){
        return self.eraserColor;
    }
    else{
        return self.penColor;
    }
}

- (float)itemWidth
{
    if (self.penType == Eraser){
        return _eraserWidth;
    }
    else{
        return _penWidth;
    }
}

- (void)setItemWidth:(float)value
{
    if (self.penType == Eraser){
        self.eraserWidth = value;
    }
    else{
        [self setPenWidth:value];
    }
    
}

- (float)itemAlpha
{
    if (self.penType == Eraser){
        return _eraserAlpha;
    }
    else{
        return _alpha;
    }
}

- (void)setItemAlpha:(float)value
{
    if (self.penType == Eraser){
        [self setEraserAlpha:value];
    }
    else{
        [self setAlpha:value];
    }
    
}

- (void)backToLastDrawMode
{
    if (_penType == Eraser) {
        _penType = _lastPenType;
    }
}

@end

@implementation DrawInfo

- (void)dealloc
{
    PPDebug(@"%@ dealloc", self);
    PPRelease(_shadow);
//    PPRelease(_penColor);
//    PPRelease(_eraserColor);
    PPRelease(_bgColor);
    PPRelease(_gradient);
//    PPRelease(_shareDrawInfo);
    [super dealloc];
}

- (id)init //WithShareDrawInfo:(ShareDrawInfo*)shareDrawInfo
{
    self = [super init];
    if (self) {
//        self.alpha = 1;
//        self.penWidth = [PPConfigManager defaultPenWidth];
//        self.penType = Pencil;
//        self.lastPenType = Pencil;
        self.shapeType = ShapeTypeNone;
        self.touchType = TouchActionTypeDraw;
//        self.penColor = [DrawColor blackColor];
        self.bgColor = [DrawColor whiteColor];
        self.shadow = nil;
        self.gradient = nil;
//        self.shareDrawInfo = shareDrawInfo;
        
//        self.eraserAlpha = 1.0f;
//        self.eraserWidth = [PPConfigManager defaultPenWidth];
//        self.eraserColor = [DrawColor whiteColor];
    }
    return self;
}

+ (id)defaultDrawInfo //:(ShareDrawInfo*)shareDrawInfo
{
    DrawInfo *info = [[[DrawInfo alloc] init /*WithShareDrawInfo:shareDrawInfo*/] autorelease];
    return info;
}


- (void)setTouchType:(TouchActionType)touchType
{
    if (touchType == TouchActionTypeDraw || touchType == TouchActionTypeShape) {
        self.lastDrawType = touchType;
    }
    _touchType = touchType;
}

- (void)backToLastDrawMode
{
    _touchType = self.lastDrawType;
//    if (_shareDrawInfo.penType == Eraser) {
//        _shareDrawInfo.penType = _shareDrawInfo.lastPenType;
//    }
}

- (BOOL)isSelectorMode
{
    NSSet *set = [NSSet setWithObjects:@(TouchActionTypeClipEllipse),
                  @(TouchActionTypeClipPolygon),
                  @(TouchActionTypeClipPath),
                  @(TouchActionTypeClipRectangle),
                  nil];
    return [set containsObject:@(self.touchType)];
}

+ (UIImage *)imageForClipActionType:(TouchActionType)type
{
    switch (type) {
        case TouchActionTypeClipEllipse:
            return [[ShareImageManager defaultManager] ellipseSelectorImage];
        case TouchActionTypeClipPolygon:
            return [[ShareImageManager defaultManager] polygonSelectorImage];
        case TouchActionTypeClipRectangle:
            return [[ShareImageManager defaultManager] rectangeSelectorImage];
        case TouchActionTypeClipPath:
        default:
            return [[ShareImageManager defaultManager] pathSelectorImage];
    }
}

// 根据当前是橡皮擦还是画笔，自动返回对应的宽度、透明度、颜色
//- (float)itemWidth
//{
//    return [_shareDrawInfo itemWidth];
//}
//
//- (void)setItemWidth:(float)value
//{
//    [_shareDrawInfo setItemWidth:value];
//}
//
//- (float)itemAlpha
//{
//    return [_shareDrawInfo itemAlpha];
//}
//
//- (void)setItemAlpha:(float)value
//{
//    [_shareDrawInfo setItemAlpha:value];
//}
//
//- (DrawColor*)itemColor
//{
//    return [_shareDrawInfo itemColor];
//}
//
//- (float)alpha
//{
//    return [_shareDrawInfo alpha];
//}
//
//- (void)setAlpha:(float)value
//{
//    [_shareDrawInfo setAlpha:value];
//}
//
//- (float)penWidth
//{
//    return [_shareDrawInfo penWidth];
//}
//
//- (void)setPenWidth:(float)value
//{
//    [_shareDrawInfo setPenWidth:value];
//}
//
//- (ItemType)lastPenType
//{
//    return [_shareDrawInfo lastPenType];
//}
//
//- (void)setLastPenType:(ItemType)value
//{
//    [_shareDrawInfo setLastPenType:value];
//}
//
//- (ItemType)penType
//{
//    return [_shareDrawInfo penType];
//}
//
//- (void)setPenType:(ItemType)value
//{
//    [_shareDrawInfo setPenType:value];
//}
//
//- (int)gridLineNumber
//{
//    return [_shareDrawInfo gridLineNumber];
//}
//
//- (void)setGridLineNumber:(int)value
//{
//    [_shareDrawInfo setGridLineNumber:value];
//}
//
//- (DrawColor*)penColor
//{
//    return [_shareDrawInfo penColor];
//}
//
//- (void)setPenColor:(DrawColor*)penColor
//{
//    [_shareDrawInfo setPenColor:penColor];
//}

@end
