//
//  ShapeAction.m
//  Draw
//
//  Created by gamy on 13-3-18.
//
//

#import "ShapeAction.h"
#import "ShapeInfo.h"
#import "ClipAction.h"

@interface ShapeAction()



@end

@implementation ShapeAction

- (id)initWithWithShape:(ShapeInfo *)shape
{
    self = [super init];
    if (self) {
        self.type = DrawActionTypeShape;
        self.shape = shape;
    }
    return self;
}

+ (id)shapeActionWithShape:(ShapeInfo *)shape
{
    ShapeAction *action = [[ShapeAction alloc] initWithWithShape:shape];
    return [action autorelease];
}

- (void)dealloc
{
    PPRelease(_shape);
    [super dealloc];
}

- (CGRect)drawInContext:(CGContextRef)context inRect:(CGRect)rect
{
 
    CGRect returnRect;
    CGContextSaveGState(context);
    [self.clipAction clipContext:context];
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);

    if ([self needShowShadow]) {
        CGContextBeginTransparencyLayer(context, NULL);

//        CGRect transparentLayerRect = self.shape.redrawRect;
//        [self.shadow spanRect:&transparentLayerRect];
//        CGContextBeginTransparencyLayerWithRect(context, transparentLayerRect, NULL);
        
        [self.shadow updateContext:context];
        [self.shape drawInContext:context];
        returnRect = self.shape.redrawRect;
        [self.shadow spanRect:&returnRect];
        CGContextEndTransparencyLayer(context);
    }else{
        [self.shape drawInContext:context];
        returnRect = self.shape.redrawRect;
    }
    CGContextRestoreGState(context);
    return returnRect;
    
}

- (CGRect)redrawRectInRect:(CGRect)rect
{
    [self.shape rect];
    return self.shape.redrawRect;
}

- (id)initWithPBDrawActionC:(Game__PBDrawAction *)action
{
    self = [super initWithPBDrawActionC:action];
    if (self) {
        self.type = DrawActionTypeShape;
        self.shape = [ShapeInfo shapeWithType:action->shapetype
                                      penType:action->pentype
                                        width:action->width
                                        color:nil];
        self.shape.stroke = action->has_shapestroke ? action->shapestroke : NO;
        [self.shape setPointsWithPointComponentC:action->rectcomponent listCount:action->n_rectcomponent];
        
        
        if (action->has_bettercolor) {
            self.shape.color = [DrawColor colorWithBetterCompressColor:action->bettercolor];
        }else{
            self.shape.color  = [DrawUtils decompressIntDrawColor:action->color];
        }
    }
    return self;
}

- (id)initWithPBDrawAction:(PBDrawAction *)action
{
    self = [super initWithPBDrawAction:action];
    if (self) {
        self.type = DrawActionTypeShape;
        self.shape = [ShapeInfo shapeWithType:action.shapeType
                                      penType:action.penType
                                        width:action.width
                                        color:nil];
        [self.shape setPointsWithPointComponent:action.rectComponent];
        self.shape.stroke = action.shapeStroke;
        if ([action hasBetterColor]) {
            self.shape.color = [DrawColor colorWithBetterCompressColor:action.betterColor];
        }else{
            self.shape.color  = [DrawUtils decompressIntDrawColor:action.color];
        }
    }
    return self;
}

- (id)initWithPBNoCompressDrawAction:(PBNoCompressDrawAction *)action
{
    self = [super initWithPBNoCompressDrawAction:action];
    if (self) {
        self.type = DrawActionTypeShape;
        self.shape = [ShapeInfo shapeWithType:action.shapeType
                                      penType:action.penType
                                        width:action.width
                                        color:nil];
        [self.shape setPointsWithPointComponent:action.rectComponent];
        self.shape.color = action.drawColor;
    }
    return self;
}


- (PBDrawAction *)toPBDrawAction
{
    PBDrawActionBuilder *builder = [[[PBDrawActionBuilder alloc] init] autorelease];
    [builder setType:DrawActionTypeShape];
    [builder setClipTag:self.clipTag];
    [self.shape updatePBDrawActionBuilder:builder];
    [self.shadow updatePBDrawActionBuilder:builder];
    return [builder build];
}

- (void)toPBDrawActionC:(Game__PBDrawAction*)pbDrawActionC
{
    [super toPBDrawActionC:pbDrawActionC];
    pbDrawActionC->type = DrawActionTypeShape;
    [self.shape updatePBDrawActionC:pbDrawActionC];
    if ([self needShowShadow]) {
        [self.shadow updatePBDrawActionC:pbDrawActionC];
    }
    if (self.clipAction) {
        pbDrawActionC->has_cliptag = 1;
        pbDrawActionC->cliptag = self.clipAction.clipTag;
    }
    return;
    
//    PBDrawActionBuilder *builder = [[[PBDrawActionBuilder alloc] init] autorelease];
//    [builder setType:DrawActionTypeShape];
//    [self.shape updatePBDrawActionBuilder:builder];
//    return [builder build];
}

- (void)addPoint:(CGPoint)point inRect:(CGRect)rect
{
    self.shape.endPoint = point;
}

@end


