//
//  Paint.m
//  Draw
//
//  Created by  on 12-3-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Paint.h"
#import "DrawUtils.h"
#import "GameMessage.pb.h"
#import "PenFactory.h"
#import "PointNode.h"
#import "CanvasRect.h"
#import "DrawPenFactory.h"
//#import "DrawPenProtocol.h"


@interface Paint()
{
    
}


@end

@implementation Paint
@synthesize width = _width;
@synthesize color = _color;
@synthesize penType = _penType;
@synthesize pointNodeList = _pointNodeList;


- (id<PenEffectProtocol>)getPen
{
    if (self.pen != nil)
        return self.pen;

    self.pen = [PenFactory getPen:_penType];
    return self.pen;
}

- (void)constructPath
{
    [[self getPen] constructPath:self.pointNodeList inRect:self.canvasRect];
    return;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.width = [aDecoder decodeFloatForKey:@"width"];
        self.color = [aDecoder decodeObjectForKey:@"color"];
        self.pointNodeList = [aDecoder decodeObjectForKey:@"pointNodeList"];
        self.penType = [aDecoder decodeFloatForKey:@"penType"];

        //old version save value list in "pointList"
        NSMutableArray *array = [aDecoder decodeObjectForKey:@"pointList"];
        if ([self.pointNodeList count] == 0 && [array count] != 0) {
            self.pointNodeList = [NSMutableArray array];
            for (NSValue *value in array) {
                CGPoint point = [value CGPointValue];
                PointNode *node = [PointNode pointWithCGPoint:point];
                [self.pointNodeList addObject:node];
            }
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.color forKey:@"color"];
    [aCoder encodeObject:self.pointNodeList forKey:@"pointNodeList"];
    [aCoder encodeFloat:self.width forKey:@"width"];
    [aCoder encodeFloat:self.penType forKey:@"penType"];
    [aCoder encodeObject:nil forKey:@"pointList"];
}

- (id)initWithWidth:(CGFloat)width color:(DrawColor*)color
{
    self = [super init];
    if (self) {
        self.width = width;
        self.color = color;
        _pointNodeList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithWidth:(CGFloat)width
              color:(DrawColor *)color
            penType:(ItemType)penType
          pointList:(NSMutableArray *)pointNodeList
{
    self = [super init];
    if (self) {
        self.width = width;
        self.color = color;
        self.penType = penType;
        if (pointNodeList == nil) {
            self.pointNodeList = [NSMutableArray array];
        }else{
            self.pointNodeList = pointNodeList;
        }
    }
    return self;
}


+ (id)paintWithWidth:(CGFloat)width
               color:(DrawColor *)color
             penType:(ItemType)penType
           pointList:(NSMutableArray *)pointNodeList
{
    return [[[Paint alloc] initWithWidth:width color:color penType:penType pointList:pointNodeList] autorelease];
}


- (id)initWithGameMessage:(GameMessage *)gameMessage
{
    self = [super init];
    if (self && gameMessage) {
        NSInteger intColor = [[gameMessage notification] color];
        CGFloat lineWidth = [[gameMessage notification] width];        
        NSArray *pointList = [[gameMessage notification] pointsList];
        self.width = lineWidth;

        self.penType = [[gameMessage notification] penType];
        self.color = [DrawUtils decompressIntDrawColor:intColor];
        _pointNodeList = [[NSMutableArray alloc] init];
        for (NSNumber *pointNumber in pointList) {
            CGPoint point = [DrawUtils decompressIntPoint:[pointNumber integerValue]];

            //this may be wrong, need test.... By Gamy
            [self addPoint:point inRect:[CanvasRect defaultRect]];
        }
    }
    return self;
}

#define RECT_SPAN_WIDTH 10
- (BOOL)spanRect:(CGRect)rect ContainsPoint:(CGPoint)point
{
    rect.origin.x -= RECT_SPAN_WIDTH;
    rect.origin.y -= RECT_SPAN_WIDTH;
    rect.size.width += RECT_SPAN_WIDTH*2;
    rect.size.height += RECT_SPAN_WIDTH*2;
    return CGRectContainsPoint(rect, point);
}


- (BOOL)isChangeBGPaint
{
    return self.width > (BACK_GROUND_WIDTH/10);
}

- (void)addPoint:(CGPoint)point inRect:(CGRect)rect
{

    if (!CGRectContainsPoint(rect, point) && ![self isChangeBGPaint]){
        //add By Gamy
        //we can change point(304.1,320.4) to point(304,320)
        //this point is not incorrect, but mistake.
        if (![self spanRect:rect ContainsPoint:point]) {
            PPDebug(@"<addPoint> Detect Incorrect Point = %@, Skip It", NSStringFromCGPoint(point));
            return;
        }
        point.x = MAX(point.x, 0);
        point.y = MAX(point.y, 0);
        point.x = MIN(point.x, CGRectGetWidth(rect));
        point.y = MIN(point.y, CGRectGetHeight(rect));
    }
    
    [[self getPen] addPointIntoPath:point];
    [self.pointNodeList addObject:[PointNode pointWithCGPoint:point]];
}


- (CGPathRef)path
{
    id<PenEffectProtocol> pen = [self getPen];
    if (![pen hasPoint]){
        [pen constructPath:self.pointNodeList inRect:self.canvasRect];
    }
    
    return [pen penPath];
}

- (CGRect)drawInContext:(CGContextRef)context inRect:(CGRect)rect
{
    if (self.drawPen == nil) {
        self.drawPen = [DrawPenFactory createDrawPen:self.penType];
    }
    CGContextSaveGState(context);
    
    [self.drawPen updateCGContext:context paint:self];
    CGPathRef path = self.path;
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
    CGRect r = [DrawUtils rectForPath:path withWidth:self.width bounds:rect];
    return r;
    
}

- (void)finishAddPoint
{
    [[self getPen] finishAddPoint];
}

- (NSInteger)pointCount
{
    return [self.pointNodeList count];
}

- (CGPoint)pointAtIndex:(NSInteger)index
{
    if (index < 0 || index >= [self pointCount]) {
        return ILLEGAL_POINT;
    }
    PointNode *node = [self.pointNodeList objectAtIndex:index];
    return node.point;
}


- (void)createPointXList:(NSMutableArray**)pointXList pointYList:(NSMutableArray**)pointYList
{
    if (self.pointCount != 0) {
        *pointXList = [[[NSMutableArray alloc] init] autorelease];
        *pointYList = [[[NSMutableArray alloc] init] autorelease];
        for (PointNode *point in self.pointNodeList) {
            [*pointXList addObject:@(point.point.x)];
            [*pointYList addObject:@(point.point.y)];
        }
    }
}

- (void)updatePBDrawActionBuilder:(PBDrawAction_Builder *)builder
{
    if ([self.pointNodeList count] != 0) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        NSMutableArray *pointXList = nil;
        NSMutableArray *pointYList = nil;
        [self createPointXList:&pointXList pointYList:&pointYList];
        [builder addAllPointsX:pointXList];
        [builder addAllPointsY:pointYList];
        
        [pool drain];
    }
    [builder setBetterColor:[self.color toBetterCompressColor]];
    [builder setPenType:self.penType];
    [builder setWidth:self.width];
}

- (void)dealloc
{
    PPRelease(_color);
    PPRelease(_pen);
    PPRelease(_pointNodeList);
    PPRelease(_drawPen);
    [super dealloc];
}
@end
