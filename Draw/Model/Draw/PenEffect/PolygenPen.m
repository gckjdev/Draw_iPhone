//
//  PolygenPen.m
//  Draw
//
//  Created by gamy on 13-6-6.
//
//

#import "PolygenPen.h"
#import "DrawUtils.h"


@interface PolygenPen()
{
    CGMutablePathRef _path;
    
    BOOL _startAddPoint;
    BOOL _hasPoint;
}

@end

@implementation PolygenPen

- (id)init
{
    //    PPDebug(@"<init> %@", [self description]);
    
    self = [super init];
    _path = CGPathCreateMutable();
    _startAddPoint = YES;
    return self;
}

- (void)dealloc
{
    PPCGPathRelease(_path);
    [super dealloc];
}

- (BOOL)hasPoint
{
    return _hasPoint;
}


- (void)constructPath:(NSArray*)pointList inRect:(CGRect)rect
{
    
    BOOL checkPoint = !CGRectEqualToRect(rect, CGRectZero);
    
    [self startAddPoint];
    
    int pointCount = [pointList count];
    
    if (pointCount > 0) {
        
        for (int i=0; i<pointCount; i++){
            PointNode *node = [pointList objectAtIndex:i];
            if (!checkPoint || [node pointInRect:rect]) {
                [self addPointIntoPath:node.point];
            }
            
        }
        
    }
    
    [self finishAddPoint];
}

- (CGPathRef)penPath
{
    return _path;
}

- (void)startAddPoint
{
    if (_path != NULL && !CGPathIsEmpty(_path)) {
        PPCGPathRelease(_path);
        _path = CGPathCreateMutable();
    }
    _hasPoint = NO;
    _startAddPoint = YES;
}


- (void)addPointIntoPath:(CGPoint)point
{
    if (!_hasPoint) {
        CGPathMoveToPoint(_path, NULL, point.x, point.y);
    }else{
        CGPathAddLineToPoint(_path, NULL, point.x, point.y);
    }
    _hasPoint = YES;
}

- (void)finishAddPoint
{

}

@end
