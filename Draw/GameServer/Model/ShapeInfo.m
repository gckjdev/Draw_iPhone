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

@implementation ShapeInfo

- (void)dealloc
{
    PPRelease(_color);
    [super dealloc];
}

- (CGPoint)toIPadPoint:(CGPoint)point
{
    point.x *= IPAD_WIDTH_SCALE;
    point.y *= IPAD_HEIGHT_SCALE;
    return point;
}
- (CGPoint)toIPhonePoint:(CGPoint)point
{
    point.x /= IPAD_WIDTH_SCALE;
    point.y /= IPAD_HEIGHT_SCALE;
    return point;
}

+ (id)shapeWithType:(ShapeType)type
            penType:(ItemType)penType
              width:(CGFloat)with
              color:(DrawColor *)color
{
    ShapeInfo *shapeInfo = nil;
    switch (type) {
        case ShapeTypeBeeline:
            shapeInfo = [[BeelineShape alloc] init];
            break;

        case ShapeTypeRectangle:
            shapeInfo = [[RectangleShape alloc] init];
            break;

        case ShapeTypeEllipse:
            shapeInfo = [[EllipseShape alloc] init];
            break;

        case ShapeTypeTriangle:
            shapeInfo = [[TriangleShape alloc] init];
            break;

        case ShapeTypeStar:
            shapeInfo = [[StarShape alloc] init];
            break;

        default:
            break;
    }
    [shapeInfo setType:type];
    [shapeInfo setPenType:penType];
    [shapeInfo setWidth:with];
    [shapeInfo setColor:color];
    return [shapeInfo autorelease];
}


- (void)setPointsWithPointComponent:(NSArray *)pointComponent
{
    CGFloat startX = [[pointComponent objectAtIndex:0] floatValue];
    CGFloat startY = [[pointComponent objectAtIndex:1] floatValue];
    self.startPoint = CGPointMake(startX, startY);
    
    CGFloat endX = [[pointComponent objectAtIndex:2] floatValue];
    CGFloat endY = [[pointComponent objectAtIndex:3] floatValue];
    self.endPoint = CGPointMake(endX, endY);
    if (ISIPAD) {
        self.startPoint = [self toIPadPoint:self.startPoint];
        self.endPoint = [self toIPadPoint:self.endPoint];
    }
    
}

- (void)setEndPoint:(CGPoint)endPoint
{
    _endPoint = endPoint;
}


#define MIN_DISTANCE (ISIPAD ? 8 : 8/2.)
- (BOOL)point1:(CGPoint)p1 equalToPoint:(CGPoint)p2
{
    BOOL flag =(ABS(p1.x - p2.x) <= MIN_DISTANCE) && (ABS(p1.y - p2.y) <= MIN_DISTANCE);
    return flag;
}

- (CGRect)rect
{
    if ([self point1:self.startPoint equalToPoint:self.endPoint]) {
        self.endPoint = self.startPoint;
        CGFloat x = self.startPoint.x;
        CGFloat y = self.startPoint.y;
        return CGRectMake(x - self.width / 2, y - self.width / 2, self.width, self.width);
    }else{
        CGFloat x = MIN(self.startPoint.x, self.endPoint.x);
        CGFloat y = MIN(self.startPoint.y, self.endPoint.y);
        CGFloat width = ABS(self.startPoint.x - self.endPoint.x);
        CGFloat height = ABS(self.startPoint.y - self.endPoint.y);
        return CGRectMake(x, y, width, height);        
    }
}


- (void)drawInContext:(CGContextRef)context
{
    PPDebug(@"<drawInContext> warn: should not call super method!!!");
}

- (NSArray *)rectComponent
{
    CGPoint start = self.startPoint, end = self.endPoint;
    if (ISIPAD) {
        start = [self toIPhonePoint:self.startPoint];
        end = [self toIPhonePoint:self.endPoint];
    }
    return [self rectComponentWithStartPoint:start endPoint:end];
}

- (NSArray *)rectComponentWithStartPoint:(CGPoint)start endPoint:(CGPoint)end
{
    return [NSArray arrayWithObjects:@(start.x), @(start.y), @(end.x), @(end.y), nil];
}


@end