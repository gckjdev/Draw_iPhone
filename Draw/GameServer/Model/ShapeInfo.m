//
//  ShapeInfo.m
//  Draw
//
//  Created by gamy on 13-2-26.
//
//

#import "ShapeInfo.h"
#import "Draw.pb.h"
#import "DrawColor.h"

@implementation ShapeInfo

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
    ShapeInfo *shapeInfo = [[ShapeInfo alloc] init];
    [shapeInfo setType:type];
    [shapeInfo setPenType:penType];
    [shapeInfo setWidth:with];
    [shapeInfo setColor:color];
    return [shapeInfo autorelease];
}

+ (id)shapeWithPBShapeInfo:(PBShapeInfo *)shapeInfo
{
    ShapeInfo *shape = [[ShapeInfo alloc] init];
    [shape setType:shapeInfo.type];
    [shape setPenType:shapeInfo.penType];
    [shape setWidth:shapeInfo.width];
    
    if ([shapeInfo.rectComponentList count] < 4 || [shapeInfo.colorComponentList count] < 4) {
        return nil;
    }
    //set color
    [shape setColor:[DrawColor colorWithRGBAComponent:shapeInfo.colorComponentList]];
    
    //set point
    CGFloat startX = [[shapeInfo.rectComponentList objectAtIndex:0] floatValue];
    CGFloat startY = [[shapeInfo.rectComponentList objectAtIndex:1] floatValue];
    shape.startPoint = CGPointMake(startX, startY);
    
    CGFloat endX = [[shapeInfo.rectComponentList objectAtIndex:2] floatValue];
    CGFloat endY = [[shapeInfo.rectComponentList objectAtIndex:3] floatValue];
    shape.endPoint = CGPointMake(endX, endY);
    
    return [shape autorelease];
}

- (CGRect)rect
{
    CGFloat x = MIN(self.startPoint.x, self.endPoint.x);
    CGFloat y = MIN(self.startPoint.y, self.endPoint.y);
    CGFloat width = ABS(self.startPoint.x - self.endPoint.x);
    CGFloat height = ABS(self.startPoint.y - self.endPoint.y);
    return CGRectMake(x, y, width, height);
}


- (CGRect)bounds
{
    CGRect rect = [self rect];
    rect.origin = CGPointZero;
    return rect;
}

- (void)drawInContext:(CGContextRef)context
{
    if (context != NULL) {
        CGContextSaveGState(context);
        CGContextSetFillColorWithColor(context, self.color.CGColor);
        
        switch (self.type) {
            case ShapeTypeBeeline:
            {
                CGContextSetStrokeColorWithColor(context, self.color.CGColor);
                CGPoint points[2];
                points[0] = self.startPoint;
                points[1] = self.endPoint;
                CGContextStrokeLineSegments(context, points, 2);
                break;
            }
                
            case ShapeTypeRectangle:
            {
                CGContextFillRect(context, self.rect);
                break;
            }
                
            case ShapeTypeEllipse:
            {
                CGContextFillEllipseInRect(context, self.rect);
                break;
            }
                
            case ShapeTypeStar:
            {
                CGRect rect = [self rect];
                
                CGFloat xRatio = 0.5 * (1 - tanf(0.2 * M_PI));
                CGFloat yRatio = 0.5 * (1 - tanf(0.1 * M_PI));
                
                CGFloat minX = CGRectGetMinX(rect);
                CGFloat minY = CGRectGetMinY(rect);
                
                CGFloat maxX = CGRectGetMaxX(rect);
                CGFloat maxY = CGRectGetMaxY(rect);
                CGFloat width = CGRectGetWidth(rect);
                CGFloat height = CGRectGetHeight(rect);
                
                CGContextMoveToPoint(context, minX, minY + yRatio * height);
                
                CGContextAddLineToPoint(context, maxX, minY + yRatio * height);
                CGContextAddLineToPoint(context, minX + xRatio * width, maxY);
                CGContextAddLineToPoint(context, minX + width / 2, minY);
                CGContextAddLineToPoint(context, maxX - xRatio * width, maxY);
                
                CGContextClosePath(context);
                CGContextFillPath(context);
                break;
            }
                
            case ShapeTypeTriangle:
            {
                CGRect rect = [self rect];
                CGContextMoveToPoint(context, CGRectGetMidX(rect), CGRectGetMinY(rect));
                CGContextAddLineToPoint(context, CGRectGetMinX(rect), CGRectGetMaxY(rect));
                CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
                
                CGContextClosePath(context);
                CGContextFillPath(context);
                break;
            }
            default:
                break;
        }
        CGContextRestoreGState(context);
    }
}

- (NSArray *)rectComponent
{
    return [NSArray arrayWithObjects:@(_startPoint.x), @(_startPoint.y), @(_endPoint.x), @(_endPoint.y), nil];
}

- (PBShapeInfo *)toPBShape
{
    PBShapeInfo_Builder *builder = [[[PBShapeInfo_Builder alloc] init] autorelease];
    
    [builder setType:self.type];
    [builder setWidth:self.width];
    [builder addAllColorComponent:[self.color toRGBAComponent]];
    [builder addAllRectComponent:[self rectComponent]];
    
    return [builder build];
}

@end
