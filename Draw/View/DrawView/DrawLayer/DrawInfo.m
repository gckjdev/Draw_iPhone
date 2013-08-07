//
//  DrawInfo.m
//  Draw
//
//  Created by gamy on 13-7-26.
//
//

#import "DrawInfo.h"
#import "ConfigManager.h"
#import "ShareImageManager.h"

@implementation DrawInfo

- (void)dealloc
{
    PPDebug(@"%@ dealloc", self);
    PPRelease(_shadow);
    PPRelease(_penColor);
    PPRelease(_bgColor);
    PPRelease(_gradient);
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.alpha = 1;
        self.penWidth = [ConfigManager defaultPenWidth];
        self.penType = Pencil;
        self.lastPenType = Pencil;
        self.shapeType = ShapeTypeNone;
        self.touchType = TouchActionTypeDraw;
        self.penColor = [DrawColor blackColor];
        self.bgColor = [DrawColor whiteColor];
        self.shadow = nil;
        self.gradient = nil;
    }
    return self;
}

+ (id)defaultDrawInfo
{
    DrawInfo *info = [[[DrawInfo alloc] init] autorelease];
    return info;
}

- (void)setAlpha:(CGFloat)alpha
{
    _alpha = alpha;
    self.penColor = [DrawColor colorWithColor:self.penColor];
    [self.penColor setAlpha:alpha];
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
    if (_penType == Eraser) {
        _penType = self.lastPenType;
    }
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

@end
