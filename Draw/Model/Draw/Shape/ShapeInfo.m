//
//  ShapeInfo.m
//  Draw
//
//  Created by gamy on 13-2-26.
//
//

#import "ShapeInfo.h"
#import "Draw.pb.h"
#import "DrawUtils.h"

#import "ShareImageManager.h"
#import "ImageShapeManager.h"

@interface ShapeInfo()
{
//    CGPoint _lastEndPoint;

}

@end

#define STROKE_WIDTH 2

@implementation ShapeInfo
@synthesize type = _type;
@synthesize stroke = _stroke;

- (void)dealloc
{
    PPRelease(_color);
    PPCGPathRelease(_path);
    [super dealloc];
}

- (BOOL)isStroke
{
    return _stroke;
}


+ (id)shapeWithType:(ShapeType)type
            penType:(ItemType)penType
              width:(CGFloat)with
              color:(DrawColor *)color
{
    
    ShapeInfo *shapeInfo = [[[ImageShapeManager defaultManager] imageShapeWithType:type] retain];
    [shapeInfo setWidth:with];
    [shapeInfo setType:type];
    [shapeInfo setPenType:penType];
    [shapeInfo setColor:color];
    return [shapeInfo autorelease];
}

- (BOOL)isBasicShape
{
    if (_type >= ShapeTypeImageBasicStart && _type < ShapeTypeImageBasicEnd) {
        return YES;
    }
    return NO;
}

- (void)setPointsWithPointComponentC:(float*)floatList listCount:(int)listCount
{
    if (listCount < 4){
        PPDebug(@"ERROR <setPointsWithPointComponentC> but list count is NOT 4");
        return;
    }
    
    CGFloat startX = floatList[0];
    CGFloat startY = floatList[1];
    self.startPoint = CGPointMake(startX, startY);
    
    CGFloat endX = floatList[2];
    CGFloat endY = floatList[3];
    
    self.endPoint = CGPointMake(endX, endY);
    
    if (self.width > 0 && [ShapeInfo point1:self.startPoint equalToPoint:self.endPoint]) {
        CGPoint point = self.startPoint;
        self.startPoint = CGPointMake(point.x - self.width / 2, point.y - self.width / 2);
        self.endPoint = CGPointMake(point.x + self.width / 2, point.y + self.width / 2);
    }
}

- (void)setPointsWithPointComponent:(NSArray *)pointComponent
{
    CGFloat startX = [[pointComponent objectAtIndex:0] floatValue];
    CGFloat startY = [[pointComponent objectAtIndex:1] floatValue];
    self.startPoint = CGPointMake(startX, startY);
    
    CGFloat endX = [[pointComponent objectAtIndex:2] floatValue];
    CGFloat endY = [[pointComponent objectAtIndex:3] floatValue];
    self.endPoint = CGPointMake(endX, endY);    
}

- (void)setEndPoint:(CGPoint)endPoint
{
    _endPoint = endPoint;
}


#define MIN_DISTANCE (11)
+ (BOOL)point1:(CGPoint)p1 equalToPoint:(CGPoint)p2
{
    BOOL flag =(ABS(p1.x - p2.x) <= MIN_DISTANCE) && (ABS(p1.y - p2.y) <= MIN_DISTANCE);
    return flag;
}



- (CGRect)rect
{
    CGRect rect= CGRectZero;
    if ([ShapeInfo point1:self.startPoint equalToPoint:self.endPoint]) {
        self.endPoint = self.startPoint;
        CGFloat x = self.startPoint.x;
        CGFloat y = self.startPoint.y;
        rect = CGRectMake(x - self.width / 2, y - self.width / 2, self.width, self.width);
    }else{
        if (_type == ShapeTypeBeeline) {
            rect = CGRectWithPointsAndWidth(self.startPoint, self.endPoint, self.width);
        }else{
            rect = CGRectWithPoints(self.startPoint, self.endPoint);
            
        }
    }
    
    if(CGRectEqualToRect(CGRectZero, _redrawRect)){
        _redrawRect = rect;
    }else{
        _redrawRect = CGRectUnion(_redrawRect, rect);
    }
    
    CGRectEnlarge(&_redrawRect, self.width, self.width);
    
    return rect;
}


- (CGRect)redrawRect
{
    return _redrawRect;
}

- (void)drawInContext:(CGContextRef)context
{
    PPDebug(@"<drawInContext> warn: should not call super method!!!");
}

- (NSArray *)rectComponent
{
    return [self rectComponentWithStartPoint:self.startPoint endPoint:self.endPoint];
}

- (NSArray *)rectComponentWithStartPoint:(CGPoint)start endPoint:(CGPoint)end
{
    return [NSArray arrayWithObjects:@(start.x), @(start.y), @(end.x), @(end.y), nil];
}

- (void)updatePBDrawActionBuilder:(PBDrawAction_Builder *)builder
{
    [builder setBetterColor:[self.color toBetterCompressColor]];
    [builder setPenType:self.penType];
    [builder setShapeType:self.type];
    [builder setShapeStroke:_stroke];
    [builder addAllRectComponent:self.rectComponent];
    [builder setWidth:self.width];
}

- (void)updatePBDrawActionC:(Game__PBDrawAction*)pbDrawActionC
{
    pbDrawActionC->bettercolor = [self.color toBetterCompressColor];
    pbDrawActionC->has_bettercolor = 1;
    
    pbDrawActionC->pentype = self.penType;
    pbDrawActionC->has_pentype = 1;
    
    pbDrawActionC->shapetype = self.type;
    pbDrawActionC->has_shapetype = 1;
    if (_stroke) {
        pbDrawActionC->shapestroke = 1;
        pbDrawActionC->has_shapestroke = 1;        
    }
    
    const int LEN_RECT = 4;
    if ([self.rectComponent count] >= LEN_RECT){
        pbDrawActionC->rectcomponent = malloc(sizeof(float)*LEN_RECT); // 4 points in rect
        pbDrawActionC->n_rectcomponent = LEN_RECT;
        for (int i=0; i<LEN_RECT; i++){
            pbDrawActionC->rectcomponent[i] = [[self.rectComponent objectAtIndex:i] floatValue];
        }
    }
    
    pbDrawActionC->width = self.width;
    pbDrawActionC->has_width = 1;
    
}


- (CGPathRef)path
{
    return _path;
}

@end





@interface ImageShapeInfo()
{

}
@end


#define SVG_IMAGE_SIZE CGSizeMake(64, 64)



@implementation ImageShapeInfo



- (id)initWithCGPath:(CGPathRef)path
{
    self = [super init];
    if (self) {
        _path = CGPathRetain(path);
        self.color = [DrawColor blackColor];
    }
    return self;
}

- (void)updateRedrawRectWithWidth:(CGFloat)width
{
    if (CGRectEqualToRect(CGRectZero, _redrawRect)) {
        _redrawRect = self.rect;
    }else{
        _redrawRect = CGRectUnion(_redrawRect, [self rect]);
    }
    if (0 != width) {
        CGRectEnlarge(&_redrawRect, width, width);
    }
}

- (void)setStroke:(BOOL)stroke
{
    if (_type == ShapeTypeBeeline) {
        _stroke = YES;
    }else{
        _stroke = stroke;
    }
}


- (void)updateBasihShapePath
{
    PPCGPathRelease(_path);
    _path = [[ImageShapeManager defaultManager] pathWithBasicType:_type
                                                       startPoint:self.startPoint
                                                         endPoint:self.endPoint].CGPath;
    if (_path) {
        CGPathRetain(_path);
    }
}

- (void)updatePathWithContext:(CGContextRef)context
{
    
    if ([self isBasicShape]) {
        [self updateBasihShapePath];
        return;
    }
    CGRect rect = [self rect];
    
    CGFloat sx = CGRectGetWidth(rect) / SVG_IMAGE_SIZE.width;
    CGFloat sy = CGRectGetHeight(rect) / SVG_IMAGE_SIZE.height;
    
    CGFloat tx = CGRectGetMinX(rect) / sx;
    CGFloat ty = CGRectGetMinY(rect)/ sy;
    
    if (self.startPoint.x > self.endPoint.x) {
        sx = - sx;
    }
    
    if (self.startPoint.y > self.endPoint.y) {
        sy = - sy;
    }
    
    CGContextScaleCTM(context, sx, sy);
    if (sy < 0) {
        ty = -(ty + SVG_IMAGE_SIZE.height);
    }
    if (sx < 0) {
        tx = -(tx + SVG_IMAGE_SIZE.width);
    }
    CGContextTranslateCTM(context, tx, ty);
}

- (void)drawInContext:(CGContextRef)context
{
    CGContextSaveGState(context);
    
    if (_path != NULL) {
        //translate && scale the path according to the rect.
        

        [self updatePathWithContext:context];
        
        CGContextAddPath(context, _path);
        CGContextSetLineCap(context, kCGLineCapRound);
        
        if (_stroke) {
            CGFloat strokeWidth = [self width];
            CGContextSetLineWidth(context, strokeWidth);
            CGContextSetStrokeColorWithColor(context, self.color.CGColor);
            CGContextSetLineJoin(context, kCGLineJoinMiter);
            CGContextStrokePath(context);
            [self updateRedrawRectWithWidth:strokeWidth];
        }else{
            CGContextSetFillColorWithColor(context, self.color.CGColor);
            CGContextFillPath(context);
            [self updateRedrawRectWithWidth:0];
        }
    }
    
    CGContextRestoreGState(context);

}

- (void)dealloc
{
    [super dealloc];
}

- (CGPathRef)path
{
    return _path;
}

- (void)updatePBDrawActionC:(Game__PBDrawAction*)pbDrawActionC
{
    
    [super updatePBDrawActionC:pbDrawActionC];
    pbDrawActionC->width = [self width];
    pbDrawActionC->has_width = 1;
    if (_stroke) {
        pbDrawActionC->shapestroke = _stroke;
        pbDrawActionC->has_shapestroke = 1;        
    }
}



+ (CGSize)defaultImageShapeSize
{
    return SVG_IMAGE_SIZE;
}

@end