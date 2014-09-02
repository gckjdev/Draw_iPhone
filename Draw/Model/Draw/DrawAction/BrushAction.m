//
//  BrushAction.m
//  Draw
//
//  Created by 黄毅超 on 14-9-1.
//
//

#import "BrushAction.h"
#import "ClipAction.h"
#import "BrushStroke.h"

@implementation BrushAction

- (void)setCanvasSize:(CGSize)canvasSize
{
    self.brushStroke.canvasRect = CGRectFromCGSize(canvasSize);
}

- (id)initWithWithBrushStroke:(BrushStroke*)brushStroke
{
    self = [super init];
    if (self) {
        self.type = DrawActionTypeBrush;
        self.brushStroke = brushStroke;
    }
    return self;
}

+ (id)brushActionWithBrushStroke:(BrushStroke *)brushStroke
{
    BrushAction *action = [[BrushAction alloc] initWithWithBrushStroke:brushStroke];
    return [action autorelease];
}

- (void)dealloc
{
    PPRelease(_brushStroke);
    [super dealloc];
}

- (CGRect)drawInContext:(CGContextRef)context inRect:(CGRect)rect
{
    CGRect rect1;
    CGContextSaveGState(context);
    [self.clipAction clipContext:context];
    
    if ([self needShowShadow]) {
        CGContextBeginTransparencyLayer(context, NULL);
        [self.shadow updateContext:context];
        rect1 = [self.brushStroke drawInContext:context inRect:rect];
        CGContextEndTransparencyLayer(context);
        [self.shadow spanRect:&rect1];
    }else{
        rect1 = [self.brushStroke drawInContext:context inRect:rect];
    }
    CGContextRestoreGState(context);
    return rect1;
}

- (CGRect)redrawRectInRect:(CGRect)rect
{
    CGRect rect1 = [self.brushStroke redrawRectInRect:rect];
    if (self.shadow) {
        [self.shadow spanRect:&rect1];
    }
    
    return rect1;
}

- (id)initWithPBDrawActionC:(Game__PBDrawAction *)action
{
    self = [super initWithPBDrawActionC:action];
    if (self) {

        /*
        HPointList *pointList = nil;
        pointList = [[HPointList alloc] init];
        
        NSInteger count = action->n_pointsx;
        if (count > 0 && action->pointsx != NULL && action->pointsy != NULL) {
            //            pointList = [NSMutableArray arrayWithCapacity:count];
            
            for (NSInteger i = 0; i < count; ++ i) {
                [pointList addPoint:action->pointsx[i] y:action->pointsy[i]];
            }
        }else{
            //old point data paser
            count = action->n_points;
            if (count > 0 && action->points != NULL) {
                //                pointList = [NSMutableArray arrayWithCapacity:count];
                
                for (int i=0; i<count; i++){
                    CGPoint point = [DrawUtils decompressIntPoint:action->points[i]];
                    
                    [pointList addPoint:point.x y:point.y];
                }
            }
        }
        self.type = DrawActionTypeBrush;
        
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
         */
    }
    return self;
}

// only for online draw, can be disabled
- (id)initWithPBDrawAction:(PBDrawAction *)action
{
    self = [super initWithPBDrawAction:action];
    if (self) {
        
        /*
        HPointList* pointList = [[HPointList alloc] init];
        
        NSInteger count = [action.pointsXList count];
        if (count > 0) {
            //new version draw data
            
            for (NSInteger i = 0; i < count; ++ i) {
                CGFloat x = [[action.pointsXList objectAtIndex:i] floatValue];
                CGFloat y = [[action.pointsYList objectAtIndex:i] floatValue];
                
                [pointList addPoint:x y:y];
                
            }
            
        }else{
            //old point data paser
            count = [action.pointsList count];
            if (count > 0) {
                //                pointList = [NSMutableArray arrayWithCapacity:count];
                for (NSNumber *p in action.pointsList) {
                    CGPoint point = [DrawUtils decompressIntPoint:[p integerValue]];
                    
                    [pointList addPoint:point.x y:point.y];
                    
                }
            }
        }
        self.type = DrawActionTypeBrush;
        
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
         
         */
    }
    return self;
}

// maybe useless, to be checked
/*
- (id)initWithPBNoCompressDrawAction:(PBNoCompressDrawAction *)action
{
    self = [super initWithPBNoCompressDrawAction:action];
    if (self) {
        self.type = DrawActionTypeBrush;
        
        HPointList* pointList = [[HPointList alloc] init];
        
        NSInteger count = 0;
        BOOL usePBPoint = [[action pointList] count] > 0;
        if (usePBPoint) {
            count = [[action pointList] count];
            if (count > 0) {
                for (NSInteger i = 0; i < count; ++ i) {
                    
                    PBPoint *pbPoint = [action.pointList objectAtIndex:i];
                    [pointList addPoint:pbPoint.x y:pbPoint.y];
                }
            }
        }else{
            count = [[action pointXList] count];
            if (count > 0) {

                for (NSInteger i = 0; i < count; ++ i) {
                    CGFloat x = [[action.pointXList objectAtIndex:i] floatValue];
                    CGFloat y = [[action.pointYList objectAtIndex:i] floatValue];
                    
                    [pointList addPoint:x y:y];
                    
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
*/

- (id)initWithPBNoCompressDrawActionC:(Game__PBNoCompressDrawAction *)action
{
    self = [super initWithPBNoCompressDrawActionC:action];
    if (self) {
        
        
        self.type = DrawActionTypeBrush;
        
        /*
        HPointList* pointList = [[HPointList alloc] init];
        
        NSInteger count = 0;
        BOOL usePBPoint = action->n_point > 0;
        if (usePBPoint) {
            count = action->n_point;
            if (count > 0) {

                for (NSInteger i = 0; i < count; ++ i) {
                    Game__PBPoint* point = action->point[i];
                    if (point != NULL){
                        [pointList addPoint:point->x y:point->y];
                    }
                }
            }
        }else{
            count = action->n_pointx; //[[action pointXList] count];
            if (count > 0) {
                for (NSInteger i = 0; i < count; ++ i) {
                    [pointList addPoint:action->pointx[i] y:action->pointy[i]];
                }
            }
        }
        
        [pointList complete];
        
        self.paint = [Paint paintWithWidth:action->width
                                     color:[DrawUtils drawColorFromPBNoCompressDrawActionC:action]  //[action drawColor]
                                   penType:action->pentype
                                 pointList:pointList];
        
        [pointList release];
         
         */
    }
    return self;
}

- (PBDrawAction *)toPBDrawAction
{
    PBDrawAction_Builder *builder = [[PBDrawAction_Builder alloc] init];
    [builder setType:DrawActionTypeBrush];
    [builder setClipTag:self.clipTag];
    [self.brushStroke updatePBDrawActionBuilder:builder];
    [self.shadow updatePBDrawActionBuilder:builder];
    PBDrawAction* pbDrawAction = [builder build];
    [builder release];
    return pbDrawAction;
}

- (void)toPBDrawActionC:(Game__PBDrawAction*)pbDrawActionC
{
    [super toPBDrawActionC:pbDrawActionC];
    pbDrawActionC->type = DrawActionTypeBrush;
    [self.brushStroke updatePBDrawActionC:pbDrawActionC];
    if ([self needShowShadow]) {
        [self.shadow updatePBDrawActionC:pbDrawActionC];
    }
    if (self.clipAction) {
        pbDrawActionC->has_cliptag = 1;
        pbDrawActionC->cliptag = self.clipAction.clipTag;
    }
    return;
}

- (void)addPoint:(CGPoint)point inRect:(CGRect)rect
{
    [super addPoint:point inRect:rect];
    [self.brushStroke addPoint:point inRect:rect];
}

- (NSUInteger)pointCount
{
    return [self.brushStroke pointCount];
}

- (void)finishAddPoint
{
    [super finishAddPoint];
    [self.brushStroke finishAddPoint];
}

- (void)clearMemory
{
    [self.brushStroke clearMemory];
}

@end
