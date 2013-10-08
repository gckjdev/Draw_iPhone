//
//  PaintAction.m
//  Draw
//
//  Created by gamy on 13-3-18.
//
//

#import "PaintAction.h"
#import "PointNode.h"
#import "ClipAction.h"

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
    CGRect rect1;
    CGContextSaveGState(context);
    [self.clipAction clipContext:context];
    if (self.paint.penType == Eraser) {
        CGContextSetBlendMode(context, kCGBlendModeClear);
    }
    if (self.shadow && self.paint.penType != Eraser && self.paint.penType != DeprecatedEraser) {
        CGContextBeginTransparencyLayer(context, NULL);
        [self.shadow updateContext:context];
        rect1 = [self.paint drawInContext:context inRect:rect];
        CGContextEndTransparencyLayer(context);
        [self.shadow spanRect:&rect1];
    }else{
        rect1 = [self.paint drawInContext:context inRect:rect];
    }
    CGContextRestoreGState(context);    
    return rect1;
}

- (CGRect)redrawRectInRect:(CGRect)rect
{
    CGRect rect1 = [self.paint redrawRectInRect:rect];
    if (self.shadow) {
        [self.shadow spanRect:&rect1];
    }
    
//    PPDebug(@"<PaintAction> redrawRectInRect = %@, in rect = %@", NSStringFromCGRect(rect1), NSStringFromCGRect(rect));
    
    return rect1;
}

- (id)initWithPBDrawActionC:(Game__PBDrawAction *)action
{
    self = [super initWithPBDrawActionC:action];
    if (self) {
//        NSMutableArray *pointList = nil;
        
        HPointList *pointList = nil;
        pointList = [[HPointList alloc] init];
        
        NSInteger count = action->n_pointsx; 
        if (count > 0 && action->pointsx != NULL && action->pointsy != NULL) {
//            pointList = [NSMutableArray arrayWithCapacity:count];
                        
            for (NSInteger i = 0; i < count; ++ i) {
                [pointList addPoint:action->pointsx[i] y:action->pointsy[i]];                
//                PointNode *node = [[PointNode alloc] initPointWithX:action->pointsx[i] Y:action->pointsy[i]];
//                [pointList addObject:node];
//                [node release];
            }
        }else{
            //old point data paser
            count = action->n_points;
            if (count > 0 && action->points != NULL) {
//                pointList = [NSMutableArray arrayWithCapacity:count];
                
                for (int i=0; i<count; i++){
                    CGPoint point = [DrawUtils decompressIntPoint:action->points[i]];
                    
                    [pointList addPoint:point.x y:point.y];
                    
//                    PointNode *node = [[PointNode alloc] initPointWithX:point.x Y:point.y];
//                    [pointList addObject:node];
//                    [node release];
                    
                }
            }
        }
        self.type = DrawActionTypePaint;
        
        [pointList complete];

        self.paint = [Paint paintWithWidth:action->width
                                     color:nil
                                   penType:action->pentype
                                 pointList:pointList];
        
        [pointList release];
        
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
//        NSMutableArray *pointList = nil;
        
        HPointList* pointList = [[HPointList alloc] init];
        
        NSInteger count = [action.pointsXList count];
        if (count > 0) {
            //new version draw data
            
//            pointList = [NSMutableArray arrayWithCapacity:count];
            for (NSInteger i = 0; i < count; ++ i) {
                CGFloat x = [[action.pointsXList objectAtIndex:i] floatValue];
                CGFloat y = [[action.pointsYList objectAtIndex:i] floatValue];
                
                [pointList addPoint:x y:y];
                
//                PointNode *node = [[PointNode alloc] initPointWithX:x Y:y];
//                [pointList addObject:node];
//                [node release];
            }
            
        }else{
            //old point data paser
            count = [action.pointsList count];
            if (count > 0) {
//                pointList = [NSMutableArray arrayWithCapacity:count];
                for (NSNumber *p in action.pointsList) {
                    CGPoint point = [DrawUtils decompressIntPoint:[p integerValue]];
                    
                    [pointList addPoint:point.x y:point.y];
                    
//                    PointNode *node = [[PointNode alloc] initPointWithX:point.x Y:point.y];
//                    [pointList addObject:node];
//                    [node release];
                }
            }
        }
        self.type = DrawActionTypePaint;
        
        [pointList complete];
        
        self.paint = [Paint paintWithWidth:action.width
                                     color:nil
                                   penType:action.penType
                                 pointList:pointList];
        
        [pointList release];
        
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
        
//        NSMutableArray *pointList = nil;
        
        HPointList* pointList = [[HPointList alloc] init];
        
        NSInteger count = 0;
        BOOL usePBPoint = [[action pointList] count] > 0;
        if (usePBPoint) {
            count = [[action pointList] count];
            if (count > 0) {
//                pointList = [NSMutableArray arrayWithCapacity:count];
                for (NSInteger i = 0; i < count; ++ i) {

                    PBPoint *pbPoint = [action.pointList objectAtIndex:i];
                    [pointList addPoint:pbPoint.x y:pbPoint.y];
                    
//                    PointNode *node = [PointNode pointWithPBPoint:pbPoint];
//                    [pointList addObject:node];
                }
            }
        }else{
            count = [[action pointXList] count];
            if (count > 0) {
//                pointList = [NSMutableArray arrayWithCapacity:count];
                for (NSInteger i = 0; i < count; ++ i) {
                    CGFloat x = [[action.pointXList objectAtIndex:i] floatValue];
                    CGFloat y = [[action.pointYList objectAtIndex:i] floatValue];

                    [pointList addPoint:x y:y];
                    
                    
//                    PointNode *node = [[PointNode alloc] initPointWithX:x Y:y];
//                    [pointList addObject:node];
//                    [node release];
                }
            }
        }
        
        [pointList complete];

        self.paint = [Paint paintWithWidth:action.width
                                     color:[action drawColor]
                                   penType:action.penType
                                 pointList:pointList];
        
        [pointList release];
    }
    return self;
}

- (id)initWithPBNoCompressDrawActionC:(Game__PBNoCompressDrawAction *)action
{
    self = [super initWithPBNoCompressDrawActionC:action];
    if (self) {
        self.type = DrawActionTypePaint;
        
//        NSMutableArray *pointList = nil;
        HPointList* pointList = [[HPointList alloc] init];
        
        NSInteger count = 0;
        BOOL usePBPoint = action->n_point > 0;
        if (usePBPoint) {
            count = action->n_point;
            if (count > 0) {
//                pointList = [NSMutableArray arrayWithCapacity:count];
                for (NSInteger i = 0; i < count; ++ i) {
//                    PBPoint *pbPoint = [action.pointList objectAtIndex:i];
//                    PointNode *node = [PointNode pointWithPBPoint:pbPoint];
                    Game__PBPoint* point = action->point[i];
                    if (point != NULL){
//                        PointNode *node = [PointNode pointWithCGPoint:CGPointMake(point->x, point->y)];
                        

                        [pointList addPoint:point->x y:point->y];
                        
//                        PointNode *node = [[PointNode alloc] initPointWithX:point->x Y:point->y];
//                        [pointList addObject:node];
//                        [node release];
                    }
                }
            }
        }else{
            count = action->n_pointx; //[[action pointXList] count];
            if (count > 0) {
//                pointList = [NSMutableArray arrayWithCapacity:count];
                for (NSInteger i = 0; i < count; ++ i) {
//                    PointNode *node = [PointNode pointWithCGPoint:CGPointMake(action->pointx[i], action->pointy[i])];
                    
                    [pointList addPoint:action->pointx[i] y:action->pointy[i]];
                    
//                    PointNode *node = [[PointNode alloc] initPointWithX:action->pointx[i] Y:action->pointy[i]];
//                    [pointList addObject:node];
//                    [node release];
                }
            }
        }
        
        [pointList complete];
        
        self.paint = [Paint paintWithWidth:action->width
                                     color:[DrawUtils drawColorFromPBNoCompressDrawActionC:action]  //[action drawColor]
                                   penType:action->pentype
                                 pointList:pointList];
        
        [pointList release];
    }
    return self;
}

- (PBDrawAction *)toPBDrawAction
{
    PBDrawAction_Builder *builder = [[PBDrawAction_Builder alloc] init];
    [builder setType:DrawActionTypePaint];
    [builder setClipTag:self.clipTag];    
    [self.paint updatePBDrawActionBuilder:builder];
    [self.shadow updatePBDrawActionBuilder:builder];
    PBDrawAction* pbDrawAction = [builder build];
    [builder release];
    return pbDrawAction;
}

- (void)toPBDrawActionC:(Game__PBDrawAction*)pbDrawActionC
{
    [super toPBDrawActionC:pbDrawActionC];
    pbDrawActionC->type = DrawActionTypePaint;
    [self.paint updatePBDrawActionC:pbDrawActionC];
    [self.shadow updatePBDrawActionC:pbDrawActionC];
    if (self.clipAction) {
        pbDrawActionC->has_cliptag = 1;
        pbDrawActionC->cliptag = self.clipAction.clipTag;
    }
    return;
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
