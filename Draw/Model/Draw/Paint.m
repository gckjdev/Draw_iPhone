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
#import "DeviceDetection.h"
#import "PenFactory.h"
#import "PointNode.h"

CGPoint midPoint(CGPoint p1, CGPoint p2)
{
//    if (CGPointEqualToPoint(p1, p2)) {
//        return p1;
//    }
//    
//    double a = atan((p1.y-p2.y)/(p1.x-p2.x));
//    double L = sqrt(pow((p1.y-p2.y), 2) + pow((p1.x-p2.x), 2));
//    double x = p2.x + L * cos(a+M_1_PI/6.);
//    double y = p2.y + L * sin(a+M_1_PI/6.);
//    CGPoint point = CGPointMake(x, y);
//    PPDebug(@"P1:%@, P2:%@, => P%@", NSStringFromCGPoint(p1), NSStringFromCGPoint(p2), NSStringFromCGPoint(point));
//    return point;
    
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

@implementation Paint
@synthesize width = _width;
@synthesize color = _color;
//@synthesize pointList = _pointList;
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
    [[self getPen] constructPath:self.pointNodeList];
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
        self.pointNodeList = pointNodeList;
    }
    return self;
}


- (id)initWithWidth:(CGFloat)width intColor:(NSInteger)color numberPointList:(NSArray *)numberPointList
{
    self = [super init];
    if (self) {
        if ([DeviceDetection isIPAD]) {
            self.width = width * 2;            
        }else{
            self.width = width;
        }
        self.color = [DrawUtils decompressIntDrawColor:color];
        _pointNodeList = [[NSMutableArray alloc] init];
        for (NSNumber *pointNumber in numberPointList) {
            CGPoint point = [DrawUtils decompressIntPoint:[pointNumber integerValue]];
            if (ISIPAD) {
                point.x = point.x * IPAD_WIDTH_SCALE;
                point.y = point.y * IPAD_HEIGHT_SCALE;
            }
            [self addPoint:point];
        }
    }
    return self;
}

- (id)initWithWidth:(CGFloat)width color:(DrawColor*)color penType:(ItemType)type
{
    self = [self initWithWidth:width color:color];
    self.penType = type;
    return self;
}

- (id)initWithWidth:(CGFloat)width intColor:(NSInteger)color numberPointList:(NSArray *)numberPointList penType:(ItemType)type
{
    self = [self initWithWidth:width intColor:color numberPointList:numberPointList];
    self.penType = type;
    return self;
}


- (id)initWithGameMessage:(GameMessage *)gameMessage
{
    self = [super init];
    if (self && gameMessage) {
        NSInteger intColor = [[gameMessage notification] color];
        CGFloat lineWidth = [[gameMessage notification] width];        
        NSArray *pointList = [[gameMessage notification] pointsList];
        if ([DeviceDetection isIPAD]) {
            self.width = lineWidth * 2;
        }else{
            self.width = lineWidth;
        }
        self.penType = [[gameMessage notification] penType];
        self.color = [DrawUtils decompressIntDrawColor:intColor];
        _pointNodeList = [[NSMutableArray alloc] init];
        for (NSNumber *pointNumber in pointList) {
            CGPoint point = [DrawUtils decompressIntPoint:[pointNumber integerValue]];
            if ([DeviceDetection isIPAD]) {
                point.x = point.x * IPAD_WIDTH_SCALE;
                point.y = point.y * IPAD_HEIGHT_SCALE;
            }
            [self addPoint:point];
        }
    }
    return self;
}
+ (Paint *)paintWithWidth:(CGFloat)width color:(DrawColor*)color
{
    return [[[Paint alloc] initWithWidth:width color:color]autorelease];
}

+ (Paint *)paintWithWidth:(CGFloat)width color:(DrawColor*)color penType:(ItemType)type
{
    return [[[Paint alloc] initWithWidth:width color:color penType:type] autorelease];
}

#define RECT_SPAN_WIDTH 2
- (BOOL)spanRect:(CGRect)rect ContainsPoint:(CGPoint)point
{
    rect.origin.x -= RECT_SPAN_WIDTH;
    rect.origin.y -= RECT_SPAN_WIDTH;
    rect.size.width += RECT_SPAN_WIDTH*2;
    rect.size.height += RECT_SPAN_WIDTH*2;
    return CGRectContainsPoint(rect, point);
}



- (void)addPoint:(CGPoint)point
{
    //    PPDebug(@"<addPointIntoPath> Point = %@,", NSStringFromCGPoint(point));
    CGRect rect = DRAW_VIEW_RECT;
    if (!CGRectContainsPoint(rect, point)){
        //add By Gamy
        //we can change point(304.1,320.4) to point(304,320)
        //this point is not incorrect, but mistake.
        if (![self spanRect:rect ContainsPoint:point]) {
            PPDebug(@"<addPoint> Detect Incorrect Point = %@, Skip It", NSStringFromCGPoint(point));
            return;
        }
        point.x = MAX(point.x, 0);
        point.y = MAX(point.y, 0);
        point.x = MIN(point.x, DRAW_VIEW_WIDTH);
        point.y = MIN(point.y, DRAW_VIEW_HEIGHT);
    }
    
    [[self getPen] addPointIntoPath:point];    
    [self.pointNodeList addObject:[PointNode pointWithCGPoint:point]];
}

- (CGPathRef)path
{
    id<PenEffectProtocol> pen = [self getPen];
    if (![pen hasPoint]){
        [pen constructPath:self.pointNodeList];
    }
    
    return [pen penPath];
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


- (NSMutableArray *)numberPointList
{
    if (self.pointCount == 0) {
        return nil;
    }
    NSMutableArray *pointList = [[[NSMutableArray alloc] init] autorelease];
    for (PointNode *point in self.pointNodeList) {
        NSInteger value = 0;
        if (ISIPAD) {
            value = [point toCompressPointWithXScale:1/IPAD_WIDTH_SCALE yScale:1/IPAD_HEIGHT_SCALE];
        }else{
            value = [point toCompressPoint];
        }
        NSNumber *number = [NSNumber numberWithInt:value];
        [pointList addObject:number];
    }
    return pointList;
}

- (void)dealloc
{
//    PPDebug(@"<dealloc> %@", [self description]);

//    PPRelease(_pointList);
    PPRelease(_color);
    PPRelease(_pen);
    PPRelease(_pointNodeList);
    [super dealloc];
}
@end
