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
@synthesize pointList = _pointList;
@synthesize penType = _penType;

- (id<PenEffectProtocol>)getPen
{
    if (self.pen != nil)
        return self.pen;

    self.pen = [PenFactory getPen:_penType];
    return self.pen;
}

- (void)constructPath
{
    [[self getPen] constructPath:self.pointList];
    return;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.width = [aDecoder decodeFloatForKey:@"width"];
        self.color = [aDecoder decodeObjectForKey:@"color"];
        self.pointList = [aDecoder decodeObjectForKey:@"pointList"];
        self.penType = [aDecoder decodeFloatForKey:@"penType"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.color forKey:@"color"];
    [aCoder encodeObject:self.pointList forKey:@"pointList"];
    [aCoder encodeFloat:self.width forKey:@"width"];
    [aCoder encodeFloat:self.penType forKey:@"penType"];
}

- (id)initWithWidth:(CGFloat)width color:(DrawColor*)color
{
    self = [super init];
    if (self) {
        self.width = width;
        self.color = color;
        _pointList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithWidth:(CGFloat)width
              color:(DrawColor *)color
            penType:(ItemType)penType
          pointList:(NSMutableArray *)pointList
{
    self = [super init];
    if (self) {
        self.width = width;
        self.color = color;
        self.penType = penType;
        self.pointList = pointList;
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
        _pointList = [[NSMutableArray alloc] init];
        for (NSNumber *pointNumber in numberPointList) {
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
        _pointList = [[NSMutableArray alloc] init];
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

- (void)addPoint:(CGPoint)point
{
    [[self getPen] addPointIntoPath:point];
    NSValue *pointValue = [NSValue valueWithCGPoint:point];
    [self.pointList addObject:pointValue];    
    return;
}

- (CGPathRef)path
{
    id<PenEffectProtocol> pen = [self getPen];
    if (![pen hasPoint]){
        [pen constructPath:self.pointList];
    }
    
    return [pen penPath];
}

- (void)finishPoint
{
    [[self getPen] finishAddPoint];
}

- (NSInteger)pointCount
{
    return [self.pointList count];
}

- (CGPoint)pointAtIndex:(NSInteger)index
{
    if (index < 0 || index >= [self.pointList count]) {
        return ILLEGAL_POINT;
    }
    NSValue *value = [self.pointList objectAtIndex:index];
    return [value CGPointValue];
}

- (NSString *)getPointListString:(NSArray *)list
{
    NSString *string = @"{";
    for (NSValue *value in list) {
        CGPoint point = [value CGPointValue];
        string = [NSString stringWithFormat:@"%@(%f, %f), ",string,point.x,point.y];
    }
    string = [NSString stringWithFormat:@"%@}",string];
    return string;
}
- (NSString *)toString
{
    return [NSString stringWithFormat:@"<Paint>:[width = %f,point = %@]",self.width, [self getPointListString:self.pointList]];
}

- (NSString*)description
{
    return [super description];
//    return [self toString];
}

- (void)dealloc
{
//    PPDebug(@"<dealloc> %@", [self description]);
    PPRelease(_color);
    PPRelease(_pointList);
    PPRelease(_pen);
    [super dealloc];
}
@end
