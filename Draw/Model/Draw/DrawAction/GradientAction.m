//
//  GradientAction.m
//  Draw
//
//  Created by gamy on 13-7-1.
//
//

#import "GradientAction.h"
#import "DrawColor.h"
#import "ClipAction.h"

@implementation Gradient

- (void)dealloc
{
    PPRelease(_startColor);
    PPRelease(_endColor);
    [super dealloc];
}



#define COLOR_COUNT 2
#define POINT_COUNT 4

- (id)initWithPBGradientC:(Game__PBGradient *)gradient
{
    self = [super init];
    if (self) {
        self.division = gradient->division;
        if (gradient->n_color >= COLOR_COUNT) {
            self.startColor = [DrawColor colorWithBetterCompressColor:gradient->color[0]];
            self.endColor = [DrawColor colorWithBetterCompressColor:gradient->color[1]];
        }
        if (gradient->n_point >= POINT_COUNT) {
            CGFloat x = gradient->point[0];
            CGFloat y = gradient->point[1];
            self.startPoint = CGPointMake(x, y);
            
            x = gradient->point[2];
            y = gradient->point[3];
            self.endPoint = CGPointMake(x, y);

        }
        
    }
    return self;
}
- (void)updatePBGradientC:(Game__PBGradient *)gradient
{
//    gradient->n_color = 1;
//    gradient->has_point = 1;
//    gradient->has_division = 1;

    gradient->division = _division;
    gradient->n_point = POINT_COUNT;
    gradient->n_color = COLOR_COUNT;
    
    gradient->color = malloc(sizeof(int32_t) * COLOR_COUNT);
    gradient->point = malloc(sizeof(float) * POINT_COUNT);
    
    gradient->color[0] = [self.startColor toBetterCompressColor];
    gradient->color[1] = [self.endColor toBetterCompressColor];
    
    gradient->point[0] = self.startPoint.x;
    gradient->point[1] = self.startPoint.y;
    gradient->point[2] = self.endPoint.x;
    gradient->point[3] = self.endPoint.y;
}


//- (id)initWithStartPoint:(CGPoint)sp
//                endPoint:(CGPoint)ep
//              startColor:(DrawColor *)sc
//                endColor:(DrawColor *)ec
//                division:(CGFloat)division
//{
//    self = [super init];
//    if (self) {
//        self.division = division;
//        self.startColor = sc;
//        self.endColor = ec;
//        self.startPoint = sp;
//        self.endPoint = ep;
//    }
//    return self;
//}


- (void)updatePointsWithDegreeAndDivision
{
    CGFloat radio = _degree * M_PI / 180;
    
    CGFloat R = CGPointDistance(CGPointZero, CGRectGetCenter(_rect));
    
    _startPoint.x = cosf(radio) * R;
    _startPoint.y = sinf(radio) * R;
    
    _endPoint.x = -_startPoint.x;
    _endPoint.y = -_startPoint.y;
    
    
    translateFromCartesianCoordinates(&_startPoint, _rect);
    translateFromCartesianCoordinates(&_endPoint, _rect);
    
    CGFloat division = _division;
    CGPoint vector = CGPointVector(_startPoint, _endPoint);
    
    
    
    if (division > 0.5) {
        _endPoint.x += vector.x * (division - 0.5);
        _endPoint.y += vector.y * (division - 0.5);
    }else{
        _startPoint.x += vector.x * (division - 0.5);
        _startPoint.y += vector.y * (division - 0.5);
    }
    PPDebug(@"<updatePointsWithDegreeAndDivision> startPoint = %@, endPoint = %@", NSStringFromCGPoint(_startPoint),NSStringFromCGPoint(_endPoint));
}

- (CGRect)rect
{
    return _rect;
}

- (id)initWithGradient:(Gradient *)gradient
{
    return [self initWithDegree:gradient.degree
                     startColor:gradient.startColor
                       endColor:gradient.endColor
                       division:gradient.division
                         inRect:gradient.rect];
}

- (id)initWithDegree:(CGFloat)degree
          startColor:(DrawColor *)sc
            endColor:(DrawColor *)ec
            division:(CGFloat)division
              inRect:(CGRect)rect
{
    self = [super init];
    if (self) {
        _degree = degree;
        _rect = rect;
        self.startColor = sc;
        self.endColor = ec;
        self.division = division;
        [self updatePointsWithDegreeAndDivision];
    }
    return self;
}

//new
- (void)setDegree:(CGFloat)degree
{
    _degree = degree;
    [self updatePointsWithDegreeAndDivision];
}

- (void)setDivision:(CGFloat)division
{
    _division = division;
    [self updatePointsWithDegreeAndDivision];
}

- (CGFloat)degree
{
    
    return _degree;
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
//    CGContextSaveGState(context);
    CGGradientRef gradient = [self createGradientRef];
    CGContextDrawLinearGradient(context, gradient, self.startPoint, self.endPoint, 0);
    CGGradientRelease(gradient);
//    CGContextRestoreGState(context);
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
    if (self.clipAction) {
        pbDrawActionC->has_cliptag = 1;
        pbDrawActionC->cliptag = self.clipAction.clipTag;
    }
}

- (void)addPoint:(CGPoint)point inRect:(CGRect)rect
{
    
}

- (CGRect)drawInContext:(CGContextRef)context inRect:(CGRect)rect
{
    CGContextSaveGState(context);
    [self.clipAction clipContext:context];
    [self.gradient drawInContext:context];
    CGContextRestoreGState(context);
    return rect;
}

- (CGRect)redrawRectInRect:(CGRect)rect
{
    return rect;
}


@end
