//
//  BrushStroke.m
//  Draw
//
//  Created by 黄毅超 on 14-9-1.
//
//

#import "BrushStroke.h"
#import "DrawUtils.h"
#import "GameMessage.pb.h"
#import "PenFactory.h"
#import "PointNode.h"
#import "CanvasRect.h"
#import "DrawPenFactory.h"
//#import "DrawPenProtocol.h"
#import "HBrushPointList.h"

@interface BrushStroke()
{
    
}

@property (nonatomic, retain) HBrushPointList  *hPointList;

@end

@implementation BrushStroke

- (id<PenEffectProtocol>)getPen
{
    if (self.pen != nil)
        return self.pen;
    
    self.pen = [PenFactory getPen:_brushType];
    return self.pen;
}

- (void)constructPath
{
    [[self getPen] constructPath:_hPointList inRect:self.canvasRect];
    return;
}

- (id)initWithWidth:(CGFloat)width color:(DrawColor*)color
{
    self = [super init];
    if (self) {
        self.width = width;
        self.color = color;
        _hPointList = [[HBrushPointList alloc] init];
    }
    return self;
}

- (id)initWithWidth:(CGFloat)width
              color:(DrawColor *)color
            brushType:(ItemType)brushType
          pointList:(HBrushPointList*)pointList
{
    self = [super init];
    if (self) {
        self.width = width;
        self.color = color;
        self.brushType = brushType;
        
        if (pointList == nil){
            _hPointList = [[HBrushPointList alloc] init];
        }
        else{
            self.hPointList = pointList;
        }
    }
    return self;
}


+ (id)paintWithWidth:(CGFloat)width
               color:(DrawColor *)color
             brushType:(ItemType)brushType
           pointList:(HBrushPointList*)pointList
{
    return [[[BrushStroke alloc] initWithWidth:width
                                         color:color
                                     brushType:brushType
                                     pointList:pointList] autorelease];
}


- (id)initWithGameMessage:(GameMessage *)gameMessage
{
    self = [super init];
    if (self && gameMessage) {
        NSInteger intColor = [[gameMessage notification] color];
        CGFloat lineWidth = [[gameMessage notification] width];
        NSArray *pointList = [[gameMessage notification] pointsList];
        self.width = lineWidth;
        
        self.brushType = [[gameMessage notification] penType];
        self.color = [DrawUtils decompressIntDrawColor:intColor];
        _hPointList = [[HBrushPointList alloc] init];
        for (NSNumber *pointNumber in pointList) {
            CGPoint point = [DrawUtils decompressIntPoint:[pointNumber integerValue]];
            
            //this may be wrong, need test.... By Gamy
            [self addPoint:point inRect:[CanvasRect defaultRect]];
        }
        [_hPointList complete];
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

- (void)updateLastPoint:(CGPoint)point inRect:(CGRect)rect
{
    if ([_hPointList count] <= 0){
        return;
    }
    
    CGPoint lastPoint = [_hPointList lastPoint];
    
    if (!CGPointEqualToPoint(point, lastPoint)) {
        [self constructPath];
    }
}


- (void)addPoint:(CGPoint)point inRect:(CGRect)rect
{
    
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
        point.x = MIN(point.x, CGRectGetWidth(rect));
        point.y = MIN(point.y, CGRectGetHeight(rect));
        PPDebug(@"<addPoint> Change Point to %@", NSStringFromCGPoint(point));
    }
    
    [[self getPen] addPointIntoPath:point];
    
    // TODO
    [_hPointList addPoint:point.x y:point.y];
}


- (CGPathRef)path
{
    id<PenEffectProtocol> pen = [self getPen];
    if (![pen hasPoint]){
        [pen constructPath:_hPointList inRect:self.canvasRect];
    }
    
    return [pen penPath];
}

- (CGRect)redrawRectInRect:(CGRect)rect
{
    CGRect r = [DrawUtils rectForPath:self.path
                            withWidth:self.width
                               bounds:rect];
    return r;
}

- (CGRect)drawInContext:(CGContextRef)context inRect:(CGRect)rect
{
    if (self.drawPen == nil) {
        self.drawPen = [DrawPenFactory createDrawPen:self.brushType];
    }
    CGContextSaveGState(context);
    
    [self.drawPen updateCGContext:context paint:self];

    CGContextAddPath(context, [self path]);
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
    return [self redrawRectInRect:rect];
}

- (void)finishAddPoint
{
    [[self getPen] finishAddPoint];
    [_hPointList complete];
}

- (NSInteger)pointCount
{
    return [_hPointList count];
}

- (CGPoint)pointAtIndex:(NSInteger)index
{
    if (index < 0 || index >= [self pointCount]) {
        return ILLEGAL_POINT;
    }
    
    return [_hPointList pointAtIndex:index];
    
}


//- (void)createPointXList:(NSMutableArray**)pointXList
//              pointYList:(NSMutableArray**)pointYList
//{
//    
//}

- (void)updatePBDrawActionBuilder:(PBDrawAction_Builder *)builder
{
    if ([self pointCount] != 0) {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        NSMutableArray *pointXList = nil;
        NSMutableArray *pointYList = nil;
        NSMutableArray *pointWList = nil;
        
        [_hPointList createPointXList:&pointXList
                           pointYList:&pointYList
                            widthList:&pointWList];
        
        [builder addAllPointsX:pointXList];
        [builder addAllPointsY:pointYList];
        [builder addAllBrushPointWidth:pointWList];
        
        [pool drain];
    }
    [builder setBetterColor:[self.color toBetterCompressColor]];
    [builder setPenType:self.brushType];
    [builder setWidth:self.width];
}

- (void)updatePBDrawActionC:(Game__PBDrawAction*)pbDrawActionC
{
    int count = [self pointCount];
    if (count > 0) {
        
        pbDrawActionC->pointsx = malloc(sizeof(float)*count);
        pbDrawActionC->pointsy = malloc(sizeof(float)*count);
        pbDrawActionC->brushpointwidth = malloc(sizeof(float)*count);
        
        pbDrawActionC->n_pointsx = count;
        pbDrawActionC->n_pointsy = count;
        pbDrawActionC->brushpointwidth = count;
        
        [_hPointList createPointFloatXList:pbDrawActionC->pointsx
                                floatYList:pbDrawActionC->pointsy
                                 widthList:pbDrawActionC->brushpointwidth];
        
    }

    pbDrawActionC->bettercolor = [self.color toBetterCompressColor];
    pbDrawActionC->has_bettercolor = 1;
    
    pbDrawActionC->pentype = self.brushType;
    pbDrawActionC->has_pentype = 1;
    
    pbDrawActionC->width = self.width;
    pbDrawActionC->has_width = 1;
    
}

- (void)dealloc
{
    PPRelease(_color);
    PPRelease(_pen);
    PPRelease(_hPointList);
    PPRelease(_drawPen);
    [super dealloc];
}
@end