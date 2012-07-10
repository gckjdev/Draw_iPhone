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
@implementation Paint
@synthesize width = _width;
@synthesize color = _color;
@synthesize pointList = _pointList;
@synthesize penType = _penType;

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
    NSValue *pointValue = [NSValue valueWithCGPoint:point];
    [self.pointList addObject:pointValue];
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
    return [self toString];
}

- (void)dealloc
{
    [_color release];
    [_pointList release];
    [super dealloc];
}
@end
