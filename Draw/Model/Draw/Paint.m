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

@implementation Paint
@synthesize width = _width;
@synthesize color = _color;
@synthesize pointList = _pointList;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.width = [aDecoder decodeFloatForKey:@"width"];
        self.color = [aDecoder decodeObjectForKey:@"color"];
        self.pointList = [aDecoder decodeObjectForKey:@"pointList"];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.color forKey:@"color"];
    [aCoder encodeObject:self.pointList forKey:@"pointList"];
    [aCoder encodeFloat:self.width forKey:@"width"];
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
        self.width = width;
        self.color = [DrawUtils decompressIntDrawColor:color];
        _pointList = [[NSMutableArray alloc] init];
        for (NSNumber *pointNumber in numberPointList) {
            CGPoint point = [DrawUtils decompressIntPoint:[pointNumber integerValue]];
            [self addPoint:point];
        }
    }
    return self;
}

- (id)initWithGameMessage:(GameMessage *)gameMessage
{
    self = [super init];
    if (self && gameMessage) {
        NSInteger intColor = [[gameMessage notification] color];
        CGFloat lineWidth = [[gameMessage notification] width];        
        NSArray *pointList = [[gameMessage notification] pointsList];
        self.width = lineWidth;
        self.color = [DrawUtils decompressIntDrawColor:intColor];
        _pointList = [[NSMutableArray alloc] init];
        for (NSNumber *pointNumber in pointList) {
            CGPoint point = [DrawUtils decompressIntPoint:[pointNumber integerValue]];
            [self addPoint:point];
        }
    }
    return self;
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

- (void)dealloc
{
    [_color release];
    [_pointList release];
    [super dealloc];
}
@end
