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

#import "TriangleShape.h"
#import "BeelineShape.h"
#import "RectangleShape.h"
#import "EllipseShape.h"
#import "StarShape.h"
#import "ShareImageManager.h"
#import "RoundRectShape.h"

@interface ShapeInfo()
{
//    CGPoint _lastEndPoint;
    CGRect _redrawRect;
}

@end

@implementation ShapeInfo
@synthesize type = _type;


- (void)dealloc
{
    PPRelease(_color);
    [super dealloc];
}


+ (id)shapeWithType:(ShapeType)type
            penType:(ItemType)penType
              width:(CGFloat)with
              color:(DrawColor *)color
{
    ShapeInfo *shapeInfo = nil;
    switch (type) {
        case ShapeTypeBeeline:
        case ShapeTypeEmptyBeeline:
            shapeInfo = [[BeelineShape alloc] init];
            break;

        case ShapeTypeRectangle:
        case ShapeTypeEmptyRectangle:
            shapeInfo = [[RectangleShape alloc] init];
            break;

        case ShapeTypeEllipse:
        case ShapeTypeEmptyEllipse:
            shapeInfo = [[EllipseShape alloc] init];
            break;

        case ShapeTypeTriangle:
        case ShapeTypeEmptyTriangle:
            shapeInfo = [[TriangleShape alloc] init];
            break;

        case ShapeTypeStar:
        case ShapeTypeEmptyStar:
            shapeInfo = [[StarShape alloc] init];
            break;

        case ShapeTypeRoundRect:
        case ShapeTypeEmptyRoundRect:
            shapeInfo = [[RoundRectShape alloc] init];
            break;            
            
        default:
            break;
    }
    
    if (shapeInfo == nil && type > ShapeTypeImageStart) {
        shapeInfo = [[ImageShapeInfo alloc] init];
    }
    
    [shapeInfo setType:type];
    [shapeInfo setPenType:penType];
    [shapeInfo setWidth:with];
    [shapeInfo setColor:color];
    
    return [shapeInfo autorelease];
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
//    _lastEndPoint = _endPoint;
    _endPoint = endPoint;
}


#define MIN_DISTANCE (8)
- (BOOL)point1:(CGPoint)p1 equalToPoint:(CGPoint)p2
{
    BOOL flag =(ABS(p1.x - p2.x) <= MIN_DISTANCE) && (ABS(p1.y - p2.y) <= MIN_DISTANCE);
    return flag;
}



- (CGRect)rect
{
    CGRect rect= CGRectZero;
    if ([self point1:self.startPoint equalToPoint:self.endPoint]) {
        self.endPoint = self.startPoint;
        CGFloat x = self.startPoint.x;
        CGFloat y = self.startPoint.y;
        rect = CGRectMake(x - self.width / 2, y - self.width / 2, self.width, self.width);
    }else{
        if ([self isKindOfClass:[BeelineShape class]]) {
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
    
    _redrawRect.origin.x -= self.width;
    _redrawRect.origin.y -= self.width;
    _redrawRect.size.width += self.width*2;
    _redrawRect.size.height += self.width*2;

    
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
    CGPoint start = self.startPoint, end = self.endPoint;
    return [self rectComponentWithStartPoint:start endPoint:end];
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
    
//    [builder setBetterColor:[self.color toBetterCompressColor]];
//    [builder setPenType:self.penType];
//    [builder setShapeType:self.type];
//    [builder addAllRectComponent:self.rectComponent];
//    [builder setWidth:self.width];
}

+ (UIImage *)shapeImageForShapeType:(ShapeType)type
{
    ShareImageManager *manager = [ShareImageManager defaultManager];
    switch (type) {
        case ShapeTypeBeeline:
            return [manager shapeLine];
        case ShapeTypeEllipse:
            return [manager shapeEllipse];
        case ShapeTypeRectangle:
            return [manager shapeRectangle];
        case ShapeTypeStar:
            return [manager shapeStar];
        case ShapeTypeTriangle:
            return [manager shapeTriangle];
        default:
            return nil;
    }
}

@end



@implementation BasicShapeInfo

- (id)init
{
    self = [super init];
    if (self) {
        _stroke = NO;
    }
    return self;
}


- (void)setType:(ShapeType)type
{
    _type = type;
    if (type > ShapeTypeEmptyStart && type < ShapeTypeEmptyEnd) {
        _stroke = YES;
    }
//    _stroke = YES;
}

- (BOOL)isStroke
{
    return _stroke;
}

#define MIN_DISTANCE1 MAX(8,self.width+2)
- (BOOL)point1:(CGPoint)p1 equalToPoint:(CGPoint)p2
{
    if (_stroke) {
        BOOL flag =(ABS(p1.x - p2.x) <= MIN_DISTANCE1) && (ABS(p1.y - p2.y) <= MIN_DISTANCE1);
        return flag;
    }
    return [super point1:p1 equalToPoint:p2];
}


- (CGRect)rect
{
    CGRect r;
    if (_stroke) {
        CGRect rect = [super rect];
        if (self.type != ShapeTypeBeeline && ![self point1:self.startPoint equalToPoint:self.endPoint]) {
            rect.origin.x += self.width/2;
            rect.origin.y += self.width/2;
            rect.size.width -= self.width;
            rect.size.height -= self.width;            
        }
        r = rect;
    }else{
        r = [super rect];
    }
    r.size.width = MAX(4, r.size.width);
    r.size.height = MAX(4, r.size.height);
    return r;
    
}

@end

#import "PocketSVG.h"

@interface ImageShapeInfo()
{
    CGPathRef _path;
}
@end

@implementation ImageShapeInfo

#define SVG_SIZE CGSizeMake(100,100)

- (NSString *)nameForType:(ShapeType)type
{
    return [NSString stringWithFormat:@"%d",type];
}

- (void)createCGPath
{
    NSString *name = [self nameForType:self.type];
    if (name == NULL) {
        return;
    }
    PocketSVG *svg = [[PocketSVG alloc] initFromSVGFileNamed:name];
    if (_path != NULL) {
        CGPathRelease(_path); _path = NULL;
    }
    _path = svg.bezier.CGPath;
    CGPathRetain(_path);
    PPRelease(svg);
}

- (void)setType:(ShapeType)type
{
    if (_type != type) {
        _type = type;
        [self createCGPath];
    }
}

- (void)drawInContext:(CGContextRef)context
{
    CGContextSaveGState(context);
    
    if (_path != NULL) {
        //translate && scale the path according to the rect.
        
        CGRect rect = [self rect];
        CGSize pathSzie = SVG_SIZE;
        
        CGFloat xScale = CGRectGetWidth(rect) / pathSzie.width;
        CGFloat yScale = CGRectGetHeight(rect) / pathSzie.height;
        
        CGFloat tx = CGRectGetMidX(rect);
        CGFloat ty = CGRectGetMidY(rect);
        
        CGContextTranslateCTM(context, tx, ty);
        CGContextScaleCTM(context, xScale, yScale);

        
        //fill it with color!
        
        [self.color.color setFill];
        CGContextAddPath(context, _path);
        CGContextFillPath(context);
    }
    
    CGContextRestoreGState(context);
}

- (void)dealloc
{
    [super dealloc];
    CGPathRelease(_path);
}


@end