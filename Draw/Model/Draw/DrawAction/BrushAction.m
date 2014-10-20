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
#import "HBrushPointList.h"

@implementation BrushAction

//- (void)setCanvasSize:(CGSize)canvasSize
//{
//    self.brushStroke.canvasRect = CGRectFromCGSize(canvasSize);
//}

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

    // no need to support shadow for brush
//    if ([self needShowShadow]) {
//        CGContextBeginTransparencyLayer(context, NULL);
//        [self.shadow updateContext:context];
//        rect1 = [self.brushStroke drawInContext:context inRect:rect];
//        CGContextEndTransparencyLayer(context);
//        [self.shadow spanRect:&rect1];
//    }else{
        rect1 = [self.brushStroke drawInContext:context inRect:rect];
//    }
    CGContextRestoreGState(context);
    return rect1;
}

- (CGRect)redrawRectInRect:(CGRect)rect
{
    CGRect newRect = [self.brushStroke redrawRectInRect:rect];

//    PPDebug(@"rect=%@", NSStringFromCGRect(newRect));
    
    return newRect;
}

- (id)initWithPBDrawActionC:(Game__PBDrawAction *)action
{
    self = [super initWithPBDrawActionC:action];
    if (self) {

        HBrushPointList *pointList = nil;
        pointList = [[HBrushPointList alloc] init];
        
        NSInteger count = action->n_pointsx;
        if (count > 0 && action->pointsx != NULL && action->pointsy != NULL) {
            
            float width = action->width;
            bool hasPointWidth = (action->brushpointwidth != NULL && action->n_brushpointwidth == action->n_pointsx);
            for (NSInteger i = 0; i < count; ++ i) {
                width = hasPointWidth ? action->brushpointwidth[i] : action->width;
                [pointList addPoint:action->pointsx[i] y:action->pointsy[i] width:width];
            }
        }
        
        self.type = DrawActionTypeBrush;
        
        [pointList complete];
        
        DrawColor* color = [DrawColor colorWithBetterCompressColor:action->bettercolor];
        self.brushStroke = [BrushStroke brushStrokeWithWidth:action->width
                                                       color:color
                                                   brushType:action->pentype
                                                   pointList:pointList];
        
        [pointList release];
        
    }
    return self;
}

// only for online draw, can be disabled
- (id)initWithPBDrawAction:(PBDrawAction *)action
{
    self = [super initWithPBDrawAction:action];
    if (self) {
        
        HBrushPointList* pointList = [[HBrushPointList alloc] init];
        
        NSInteger count = [action.pointsXList count];
        if (count > 0) {
            //new version draw data
            float width = action.width;
            bool hasPointWidth = (action.brushPointWidthList != nil && [action.brushPointWidthList count] == count);

            for (NSInteger i = 0; i < count; ++ i) {
                
                width = hasPointWidth ? [[action.brushPointWidthList objectAtIndex:i] floatValue] : action.width;

                CGFloat x = [[action.pointsXList objectAtIndex:i] floatValue];
                CGFloat y = [[action.pointsYList objectAtIndex:i] floatValue];
                
                [pointList addPoint:x y:y width:width];
            }
        }
        
        self.type = DrawActionTypeBrush;
        
        [pointList complete];
        
        DrawColor* color;
        if ([action hasBetterColor]) {
            color = [DrawColor colorWithBetterCompressColor:action.betterColor];
        }else{
            color  = [DrawUtils decompressIntDrawColor:action.color];
        }
        
        self.brushStroke = [BrushStroke brushStrokeWithWidth:action.width
                                                       color:color
                                                   brushType:action.penType
                                                   pointList:pointList];

        [pointList release];
        
    }
    return self;
}

- (id)initWithPBNoCompressDrawAction:(PBNoCompressDrawAction *)action
{
    self = [super initWithPBNoCompressDrawAction:action];
    if (self) {
        self.type = DrawActionTypeBrush;
        
        HBrushPointList* pointList = [[HBrushPointList alloc] init];
        
        NSInteger count = [action.pointXList count];
        if (count > 0) {
            //new version draw data
            float width = action.width;
            bool hasPointWidth = (action.brushPointWidthList != nil && [action.brushPointWidthList count] == count);
            
            for (NSInteger i = 0; i < count; ++ i) {
                
                width = hasPointWidth ? [[action.brushPointWidthList objectAtIndex:i] floatValue] : action.width;
                
                CGFloat x = [[action.pointXList objectAtIndex:i] floatValue];
                CGFloat y = [[action.pointYList objectAtIndex:i] floatValue];
                
                [pointList addPoint:x y:y width:width];
            }
        }
        
        [pointList complete];
        
        self.brushStroke = [BrushStroke brushStrokeWithWidth:action.width
                                                       color:[action drawColor]
                                                   brushType:action.penType
                                                   pointList:pointList];
        
        [pointList release];
    }
    return self;
}

- (id)initWithPBNoCompressDrawActionC:(Game__PBNoCompressDrawAction *)action
{
    self = [super initWithPBNoCompressDrawActionC:action];
    if (self) {
        
        
        self.type = DrawActionTypeBrush;
        
        HBrushPointList* pointList = [[HBrushPointList alloc] init];
        
        NSInteger count = 0;
        count = action->n_pointx; //[[action pointXList] count];
        if (count > 0 && action->pointx != NULL && action->pointy != NULL) {
            
            float width = action->width;
            bool hasPointWidth = (action->brushpointwidth != NULL && action->n_brushpointwidth == action->n_pointx);
            for (NSInteger i = 0; i < count; ++ i) {
                width = hasPointWidth ? action->brushpointwidth[i] : action->width;
                [pointList addPoint:action->pointx[i] y:action->pointy[i] width:width];
            }
        }
        
        [pointList complete];
        
        DrawColor* color = [DrawColor colorWithBetterCompressColor:action->color];
        self.brushStroke = [BrushStroke brushStrokeWithWidth:action->width
                                                       color:color
                                                   brushType:action->pentype
                                                   pointList:pointList];
        
        [pointList release];
         
        
    }
    return self;
}

- (PBDrawAction *)toPBDrawAction
{
    PBDrawAction_Builder *builder = [[PBDrawAction_Builder alloc] init];
    [builder setType:DrawActionTypeBrush];
    [builder setClipTag:self.clipTag];
    [self.brushStroke updatePBDrawActionBuilder:builder];
//    [self.shadow updatePBDrawActionBuilder:builder];
    PBDrawAction* pbDrawAction = [builder build];
    [builder release];
    return pbDrawAction;
}

- (void)toPBDrawActionC:(Game__PBDrawAction*)pbDrawActionC
{
    [super toPBDrawActionC:pbDrawActionC];
    pbDrawActionC->type = DrawActionTypeBrush;
    [self.brushStroke updatePBDrawActionC:pbDrawActionC];
//    if ([self needShowShadow]) {
//        [self.shadow updatePBDrawActionC:pbDrawActionC];
//    }
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

- (void)addPoint:(CGPoint)point
           width:(float)width
          inRect:(CGRect)rect
         forShow:(BOOL)forShow
{
    [self.brushStroke addPoint:point
                         width:width
                        inRect:rect
                       forShow:forShow];
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
