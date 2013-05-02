//
//  PaintAction.m
//  Draw
//
//  Created by gamy on 13-3-18.
//
//

#import "PaintAction.h"
#import "PointNode.h"

@interface PaintAction()



@end

@implementation PaintAction


- (void)setCanvasSize:(CGSize)canvasSize
{
    self.paint.canvasRect = CGRectFromCGSize(canvasSize);
}

- (id)initWithWithPaint:(Paint *)paint
{
    self = [super init];
    if (self) {
        self.type = DrawActionTypePaint;
        self.paint = paint;
    }
    return self;
}

+ (id)paintActionWithPaint:(Paint *)paint
{
    PaintAction *action = [[PaintAction alloc] initWithWithPaint:paint];
    return [action autorelease];
}

- (void)dealloc
{
    PPRelease(_paint);
    [super dealloc];
}

- (CGRect)drawInContext:(CGContextRef)context inRect:(CGRect)rect
{
    return [self.paint drawInContext:context inRect:rect];
}

- (id)initWithPBDrawActionC:(Game__PBDrawAction *)action
{
    self = [super initWithPBDrawActionC:action];
    if (self) {
        NSMutableArray *pointList = nil;
        NSInteger count = action->n_pointsx; // [action.pointsXList count];
        if (count > 0 && action->pointsx != NULL && action->pointsy != NULL) {
            pointList = [NSMutableArray arrayWithCapacity:count];            
            for (NSInteger i = 0; i < count; ++ i) {
                CGFloat x = action->pointsx[i]; //[[action.pointsXList objectAtIndex:i] floatValue];
                CGFloat y = action->pointsy[i]; // [[action.pointsYList objectAtIndex:i] floatValue];
                PointNode *node = [PointNode pointWithCGPoint:CGPointMake(x, y)];
                [pointList addObject:node];
            }
        }else{
            //old point data paser
            count = action->n_points;
//            count = [action.pointsList count];
            if (count > 0 && action->points != NULL) {
                pointList = [NSMutableArray arrayWithCapacity:count];
                for (int i=0; i<count; i++){
                    CGPoint point = [DrawUtils decompressIntPoint:action->points[i]];
                    PointNode *node = [PointNode pointWithCGPoint:point];
                    [pointList addObject:node];
                    
                }
                
//                for (NSNumber *p in action.pointsList) {
//                    CGPoint point = [DrawUtils decompressIntPoint:[p integerValue]];
//                    PointNode *node = [PointNode pointWithCGPoint:point];
//                    [pointList addObject:node];
//                }
            }
        }
        self.type = DrawActionTypePaint;
        self.paint = [Paint paintWithWidth:action->width
                                     color:nil
                                   penType:action->pentype
                                 pointList:pointList];
        if (action->has_bettercolor) {
            self.paint.color = [DrawColor colorWithBetterCompressColor:action->bettercolor];
        }else{
            self.paint.color  = [DrawUtils decompressIntDrawColor:action->color];
        }
    }
    return self;
}

- (id)initWithPBDrawAction:(PBDrawAction *)action
{
    self = [super initWithPBDrawAction:action];
    if (self) {
        NSMutableArray *pointList = nil;
        NSInteger count = [action.pointsXList count];
        if (count > 0) {
            pointList = [NSMutableArray arrayWithCapacity:count];
            for (NSInteger i = 0; i < count; ++ i) {
                CGFloat x = [[action.pointsXList objectAtIndex:i] floatValue];
                CGFloat y = [[action.pointsYList objectAtIndex:i] floatValue];
                PointNode *node = [PointNode pointWithCGPoint:CGPointMake(x, y)];
                [pointList addObject:node];
            }
        }else{
            //old point data paser
            count = [action.pointsList count];
            if (count > 0) {
                pointList = [NSMutableArray arrayWithCapacity:count];
                for (NSNumber *p in action.pointsList) {
                    CGPoint point = [DrawUtils decompressIntPoint:[p integerValue]];
                    PointNode *node = [PointNode pointWithCGPoint:point];
                    [pointList addObject:node];
                }
            }
        }
        self.type = DrawActionTypePaint;
        self.paint = [Paint paintWithWidth:action.width
                                     color:nil
                                   penType:action.penType
                                 pointList:pointList];
        if ([action hasBetterColor]) {
            self.paint.color = [DrawColor colorWithBetterCompressColor:action.betterColor];
        }else{
            self.paint.color  = [DrawUtils decompressIntDrawColor:action.color];
        }
    }
    return self;
}

- (id)initWithPBNoCompressDrawAction:(PBNoCompressDrawAction *)action
{
    self = [super initWithPBNoCompressDrawAction:action];
    if (self) {
        self.type = DrawActionTypePaint;
        
        NSMutableArray *pointList = nil;
        NSInteger count = 0;
        BOOL usePBPoint = [[action pointList] count] > 0;
        if (usePBPoint) {
            count = [[action pointList] count];
            if (count > 0) {
                pointList = [NSMutableArray arrayWithCapacity:count];
                for (NSInteger i = 0; i < count; ++ i) {
                    PBPoint *pbPoint = [action.pointList objectAtIndex:i];
                    PointNode *node = [PointNode pointWithPBPoint:pbPoint];
                    [pointList addObject:node];
                }
            }
        }else{
            count = [[action pointXList] count];
            if (count > 0) {
                pointList = [NSMutableArray arrayWithCapacity:count];
                for (NSInteger i = 0; i < count; ++ i) {
                    CGFloat x = [[action.pointXList objectAtIndex:i] floatValue];
                    CGFloat y = [[action.pointYList objectAtIndex:i] floatValue];
                    PointNode *node = [PointNode pointWithCGPoint:CGPointMake(x, y)];
                    [pointList addObject:node];
                }
            }
        }

        self.paint = [Paint paintWithWidth:action.width
                                     color:[action drawColor]
                                   penType:action.penType
                                 pointList:pointList];
    }
    return self;
}

- (PBDrawAction *)toPBDrawAction
{
    PBDrawAction_Builder *builder = [[[PBDrawAction_Builder alloc] init] autorelease];
    [builder setType:DrawActionTypePaint];
    [self.paint updatePBDrawActionBuilder:builder];
    return [builder build];
}

- (void)addPoint:(CGPoint)point inRect:(CGRect)rect
{
    [super addPoint:point inRect:rect];
    [self.paint addPoint:point inRect:rect];
}

- (NSUInteger)pointCount
{
    return [self.paint pointCount];
}

- (void)finishAddPoint
{
    [super finishAddPoint];
    [self.paint finishAddPoint];
}


@end
