//
//  GradientAction.m
//  Draw
//
//  Created by gamy on 13-7-1.
//
//

#import "GradientAction.h"
#import "DrawColor.h"

@implementation Gradient

- (void)dealloc
{
    PPRelease(_startColor);
    PPRelease(_endColor);
    [super dealloc];
}

#define COLOR_COUNT 2
#define POINT_COUNT 4
- (id)initWithStartPoint:(CGPoint)sp
                endPoint:(CGPoint)ep
              startColor:(DrawColor *)sc
                endColor:(DrawColor *)ec
                division:(CGFloat)division
{
    self = [super init];
    if (self) {
        self.division = division;
        self.startColor = sc;
        self.endColor = ec;
        self.startPoint = sp;
        self.endPoint = ep;
    }
    return self;
}


- (void)updatePBGradientC:(Game__PBGradient *)gradient
{
    gradient->division = self.division;
    gradient->division = 1;


    gradient->n_point = POINT_COUNT;
    gradient->point = malloc(sizeof(int32_t) * POINT_COUNT);
    gradient->point[0] = self.startPoint.x;
    gradient->point[1] = self.startPoint.y;
    gradient->point[2] = self.endPoint.x;
    gradient->point[3] = self.endPoint.y;

    
    if (self.startColor && self.endColor) {
        gradient->n_color = COLOR_COUNT;
        gradient->color = malloc(sizeof(int32_t) * COLOR_COUNT);
        gradient->color[0] = [self.startColor toBetterCompressColor];
        gradient->color[1] = [self.endColor toBetterCompressColor];
        
    }else{
        gradient->n_color = 0;
    }

}

- (id)initWithPBGradientC:(Game__PBGradient *)gradient
{
    self = [super init];
    if (self) {
        self.division = gradient->division;
        NSInteger count = gradient->n_color;
        if (count >= COLOR_COUNT) {
            self.startColor = [DrawColor colorWithBetterCompressColor:gradient->color[0]];
            self.endColor = [DrawColor colorWithBetterCompressColor:gradient->color[1]];
        }
        
        count = gradient->n_point;
        if (count >= POINT_COUNT) {
            _startPoint.x = gradient->point[0];
            _startPoint.y = gradient->point[1];
            _endPoint.x = gradient->point[2];
            _endPoint.y = gradient->point[3];
        }
    }
    return self;
}

- (CGFloat)degree
{
    
    return 0;
}

- (CGGradientRef)createGradientRef
{
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    
    CGFloat component[4 * COLOR_COUNT] = {};
    const CGFloat *c1 = CGColorGetComponents(self.startColor.CGColor);
    const CGFloat *c2 = CGColorGetComponents(self.endColor.CGColor);
    memcpy(component, c1, sizeof(CGFloat) * 4);
    memcpy(component+4, c2, sizeof(CGFloat) * 4);

    CGGradientRef gradient = CGGradientCreateWithColorComponents(space, component, NULL, COLOR_COUNT);
    CGColorSpaceRelease(space);
    return gradient;
}

- (void)drawInContext:(CGContextRef)context
{
    CGGradientRef gradient = [self createGradientRef];
    CGContextDrawLinearGradient(context, gradient, self.startPoint, self.endPoint, 0);
    CGGradientRelease(gradient);
}

@end

@implementation GradientAction

- (id)initWithGradient:(Gradient *)gradient
{
    self = [super init];
    if (self) {
        self.gradient = gradient;
        self.type = DrawActionTypeGradient;
    }
    return self;
}


- (id)initWithPBDrawActionC:(Game__PBDrawAction *)action
{
    self = [super initWithPBDrawActionC:action];
    if (self) {
        self.gradient = [[Gradient alloc] initWithPBGradientC:action->gradient];
        self.type = DrawActionTypeGradient;
    }
    return self;
}


- (void)toPBDrawActionC:(Game__PBDrawAction*)pbDrawActionC
{
    [super toPBDrawActionC:pbDrawActionC];
    pbDrawActionC->type = DrawActionTypeGradient;
    pbDrawActionC->gradient = malloc(sizeof(Game__PBGradient));
    game__pbgradient__init(pbDrawActionC->gradient);
    [self.gradient updatePBGradientC:pbDrawActionC->gradient];
}

- (void)addPoint:(CGPoint)point inRect:(CGRect)rect
{
    
}

- (CGRect)drawInContext:(CGContextRef)context inRect:(CGRect)rect
{
    [self.gradient drawInContext:context];
    return rect;
}

- (CGRect)redrawRectInRect:(CGRect)rect
{
    return rect;
}


@end
