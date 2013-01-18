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

- (CGMutablePathRef)getPath
{
    return _path;
}

- (CGMutablePathRef)getPathForShow
{
    return _pathToShow;
}

- (CGRect)rectForPath
{
    return [DrawUtils rectForPath1:_path path2:_pathToShow withWidth:self.width];
}

- (void)clearPath
{
    if (_path != NULL){
        CGPathRelease(_path);
        _path = NULL;
    }
    
    [self releasePathToShow];
}

- (void)constructPath
{
    [self constructPath1];
    return;
    
    if (self.pointCount > 0) {
        if (_path == NULL) {
            _path = CGPathCreateMutable();
        }
        CGPoint p1, p2;
        p1 = p2 = [self pointAtIndex:0];
        
        NSInteger count = self.pointCount;        
        if (count == 1){
            CGPathMoveToPoint(_path, NULL, p1.x, p1.y);
            CGPathAddQuadCurveToPoint(_path, NULL, p1.x, p1.y, p1.x, p1.y);
            return;
        }
        
        CGPathMoveToPoint(_path, NULL, p1.x, p1.y);
        for (int i = 0; i < count-1; ++ i) {
            p1 = [self pointAtIndex:i];
            p2 = [self pointAtIndex:i+1];
            CGPoint mid = midPoint(p1, p2);
            CGPathAddQuadCurveToPoint(_path, NULL, mid.x, mid.y, p2.x, p2.y);
        }
        
    }
}

- (void)constructPath1
{
    if (self.pointCount > 0) {
        if (_path == NULL) {
            _path = CGPathCreateMutable();
            ptsCount = 0;
        }

        NSInteger count = self.pointCount;
        for (int i=0; i<count; i++){
            [self addPointIntoPath:[self pointAtIndex:i] path:_path];
        }
    }
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
        _path = CGPathCreateMutable();
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
    [self addPoint1:point];
    return;
    
    if (_path != NULL) {
    
        if ([self pointCount] == 0) {
            CGPathMoveToPoint(_path, NULL, point.x, point.y);
            CGPathAddQuadCurveToPoint(_path, NULL, point.x, point.y, point.x, point.y);
        }else{
            CGPoint lastPoint = [[_pointList lastObject] CGPointValue];
            CGPoint mid = midPoint(lastPoint, point);
            CGPathAddQuadCurveToPoint(_path, NULL, mid.x, mid.y, point.x, point.y);
        }
    }
    NSValue *pointValue = [NSValue valueWithCGPoint:point];
    [self.pointList addObject:pointValue];
}

- (void)printPts
{
    for (int i=0; i<ptsCount; i++){
//        PPDebug(@"Point[%d]=%@", i, NSStringFromCGPoint(pts[i]));
    }
}

- (void)addPointIntoPath:(CGPoint)point path:(CGMutablePathRef)targetPath
{
    if (targetPath == NULL)
        return;
    
    pts[ptsCount] = point;
    ptsCount ++;
    ptsComplete = NO;
    if (ptsCount == POINT_COUNT){
        // adjust pts[3]
        pts[3] = CGPointMake((pts[2].x + pts[4].x)/2.0f, (pts[2].y + pts[4].y)/2.0f);
        
        CGPathMoveToPoint(targetPath, NULL, pts[0].x, pts[0].y);
        CGPathAddCurveToPoint(targetPath, NULL, pts[1].x, pts[1].y,
                              pts[2].x, pts[2].y,
                              pts[3].x, pts[3].y);
        
//        PPDebug(@"[BEFORE_DRAW] ptsCount=%d", ptsCount);
        [self printPts];

        // replace pts[0] and pts[1]
        pts[0] = pts[3];
        pts[1] = pts[4];
        ptsCount = 2;
        
        ptsComplete = YES;

//        PPDebug(@"[AFTER_DRAW] ptsCount=%d", ptsCount);
        [self printPts];
    }
    else{
//        PPDebug(@"[ADD2] ptsCount=%d", ptsCount);
        [self printPts];
    }
    
    
}

// if you don't understand the code below
// please read here http://mobile.tutsplus.com/tutorials/iphone/ios-sdk_freehand-drawing/
- (void)addPoint1:(CGPoint)point
{
    [self addPointIntoPath:point path:_path];
    NSValue *pointValue = [NSValue valueWithCGPoint:point];
    [self.pointList addObject:pointValue];
}

- (void)releasePathToShow
{
    if (_pathToShow != NULL){
        CGPathRelease(_pathToShow);
        _pathToShow = NULL;
    }
}

// this is used to add points (less than 4) into path
- (void)addPoorPointsIntoPath:(CGMutablePathRef)targetPath
{
    if (ptsCount == 1){
        CGPathMoveToPoint(targetPath, NULL, pts[0].x, pts[0].y);
        CGPathAddQuadCurveToPoint(targetPath, NULL, pts[0].x, pts[0].y, pts[0].x, pts[0].y);
    }
    else if (ptsCount == 2){
        CGPathMoveToPoint(targetPath, NULL, pts[0].x, pts[0].y);
        CGPoint mid = midPoint(pts[0], pts[1]);
        CGPathAddQuadCurveToPoint(targetPath, NULL, mid.x, mid.y, pts[1].x, pts[1].y);
    }
    else if (ptsCount == 3){
        CGPathMoveToPoint(targetPath, NULL, pts[0].x, pts[0].y);
        CGPathAddQuadCurveToPoint(targetPath, NULL, pts[1].x, pts[1].y, pts[2].x, pts[2].y);
    }
    else if (ptsCount == 4){
        CGPathMoveToPoint(targetPath, NULL, pts[0].x, pts[0].y);
        CGPathAddCurveToPoint(targetPath, NULL, pts[1].x, pts[1].y,
                              pts[2].x, pts[2].y,
                              pts[3].x, pts[3].y);
    }
}

- (CGPathRef)path
{
    if (_path == NULL && self.pointCount > 0) {
        // here only happen when the draw is finished, if you are drawing on screen, this cannot happen
        [self constructPath];
        [self addPoorPointsIntoPath:_path];
        return _path;
    }
    
    if (ptsComplete)
        return _path;
    
    if (_pathToShow != NULL){
        CGPathRelease(_pathToShow);
        _pathToShow = NULL;
    }
    
    _pathToShow = CGPathCreateMutableCopy(_path);
    [self addPoorPointsIntoPath:_pathToShow];
    return _pathToShow;
    
    // old implementation here, keep
    if (_path == NULL && self.pointCount > 0) {
        [self constructPath];
    }

    return _path;
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
    [self releasePathToShow];
    PPRelease(_color);
    PPRelease(_pointList);
    if (_path != NULL) {
        CGPathRelease(_path), _path = NULL;
    }
    [super dealloc];
}
@end
