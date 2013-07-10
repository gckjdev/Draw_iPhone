//
//  SettingAction.m
//  Draw
//
//  Created by gamy on 13-6-5.
//
//

#import "ClipAction.h"
#import "PointNode.h"
#import "GameBasic.pb-c.h"
#import "GameBasic.pb.h"
#import "Paint.h"
#import "ShapeInfo.h"



@interface ClipAction()
{
    
}

@end

@implementation ClipAction

- (void)dealloc
{
    PPRelease(_paint);
    PPRelease(_shape);
    [super dealloc];
}


- (void)updatePaintWithDrawActionC:(Game__PBDrawAction *)action
{
    NSMutableArray *pointList = nil;
    NSInteger count =  action->n_pointsx;
    
    if (count > 0) {
        pointList = [NSMutableArray arrayWithCapacity:count];
        for (NSInteger i = 0; i < count; ++ i) {
            PointNode *node = [[PointNode alloc] initPointWithX:action->pointsx[i]
                                                              Y:action->pointsy[i]];
            [pointList addObject:node];
            [node release];
        }
    }
    ItemType penType;
    if (action->cliptype == ClipTypePolygon) {
        penType = PolygonPen;
    }else{
        penType = action->pentype;
    }
    self.paint = [Paint paintWithWidth:1
                                 color:[DrawColor blackColor]
                               penType:penType
                             pointList:pointList];
}


- (void)updateShapeWithDrawActionC:(Game__PBDrawAction *)action
{
    ShapeType shapeType = action->cliptype;
    
    self.shape = [ShapeInfo shapeWithType:shapeType
                                  penType:Pencil
                                    width:1
                                    color:[DrawColor blackColor]];

    [self.shape setStroke:YES];
    
    [self.shape setPointsWithPointComponentC:action->rectcomponent listCount:action->n_rectcomponent];
}


- (void)commonInit
{
    self.type = DrawActionTypeClip;
}

- (id)initWithPBDrawAction:(PBDrawAction *)action
{
    self = [super initWithPBDrawAction:action];
    if (self) {
        self.clipType = action.clipType;
        [self commonInit];
    }
    return self;
}

- (id)initWithPBDrawActionC:(Game__PBDrawAction *)action
{
    self = [super initWithPBDrawActionC:action];
    if (self) {
        [self commonInit];
        self.clipType = action->cliptype;
        switch (self.clipType) {
            case ClipTypeEllipse:
            case ClipTypeRectangle:
                [self updateShapeWithDrawActionC:action];
                break;
            case ClipTypePolygon:
            case ClipTypeSmoothPath:
                [self updatePaintWithDrawActionC:action];
                break;
                
            default:
                break;
        }
        
    }
    return self;
}

- (id)initWithShape:(ShapeInfo *)shape
{
    self = [super init];
    if (self) {
        self.shape = shape;
        if (shape.type == ShapeTypeEllipse) {
            self.clipType = ClipTypeEllipse;
        }else if(shape.type == ShapeTypeRectangle){
            self.clipType = ClipTypeRectangle;
        }else{
            self.shape = nil;
        }
    }
    return self;
}

- (id)initWithPaint:(Paint *)paint
{
    self = [super init];
    if (self) {
        self.paint = paint;
        if (paint.penType == PolygonPen) {
            self.clipType = ClipTypePolygon;
        }else{
            self.clipType = ClipTypeSmoothPath;
        }
    }
    return self;
}



+ (id)clipActionWithShape:(ShapeInfo *)shape
{
    return [[[ClipAction alloc] initWithShape:shape] autorelease];
}
+ (id)clipActionWithPaint:(Paint *)paint
{
    return [[[ClipAction alloc] initWithPaint:paint] autorelease];
}

- (CGPathRef)path
{
    if (self.paint) {
        return self.paint.path;
    }else if(self.shape){
        CGRect rect = CGRectWithPoints(self.shape.startPoint, self.shape.endPoint);
        if (self.clipType == ClipTypeRectangle) {
            return [UIBezierPath bezierPathWithRect:rect].CGPath;
        }else if(self.clipType == ClipTypeEllipse){
            return [UIBezierPath bezierPathWithOvalInRect:rect].CGPath;
        }
    }
    return NULL;

}


- (CGRect)drawInContext:(CGContextRef)context inRect:(CGRect)rect
{
    [super drawInContext:context inRect:rect];
    return rect;
}

- (CGRect)showClipInContext:(CGContextRef)context inRect:(CGRect)rect
{
    CGContextSaveGState(context);
    CGRect retRrect;
    
    static CGFloat lengths[] = {5,5};
    
    CGContextSetLineDash(context, 0, lengths, 2);
    CGContextSetLineWidth(context, 2);
    CGContextSetStrokeColorWithColor(context, [UIColor grayColor].CGColor);
    
    if (self.paint) {
        retRrect = [self.paint redrawRectInRect:rect];
    }else{
        retRrect = [self.shape rect];
    }
    CGPathRef path = [self path];
    if (path != NULL) {
        CGContextAddPath(context, path);
        if (self.hasFinishAddPoint && self.paint) {
            CGContextClosePath(context);
        }

        CGContextStrokePath(context);
    }
    CGContextRestoreGState(context);
    
    return retRrect;
}


- (void)clipContext:(CGContextRef)context
{
    CGPathRef path = [self path];
    
    if (path) {
        CGContextAddPath(context, path);
        CGContextClosePath(context);
        CGContextClip(context);        
    }

}




- (void)unClipContext:(CGContextRef)context
{
//    CGContextRestoreGState(context);
}

- (PBDrawAction *)toPBDrawAction
{
    PBDrawAction_Builder *builder = [[PBDrawAction_Builder alloc] init];
    
    [builder setType:DrawActionTypeClip];
    [builder setClipTag:self.clipTag];
    [builder setClipType:self.clipType];

    if (self.paint) {
        [self.paint updatePBDrawActionBuilder:builder];
    }
    if (self.shape) {
        [self.shape updatePBDrawActionBuilder:builder];
    }
    
    PBDrawAction *pbDrawAction = [builder build];
    
    [builder release];
    return pbDrawAction;
}

- (void)toPBDrawActionC:(Game__PBDrawAction*)pbDrawActionC
{
    [super toPBDrawActionC:pbDrawActionC];
    pbDrawActionC->type = DrawActionTypeClip;
    pbDrawActionC->cliptag = self.clipTag;
    pbDrawActionC->cliptype = self.clipType;
    pbDrawActionC->has_cliptag = YES;
    pbDrawActionC->has_cliptype = YES;

    if (self.paint) {
        [self.paint updatePBDrawActionC:pbDrawActionC];
    }
    if (self.shape) {
        [self.shape updatePBDrawActionC:pbDrawActionC];
    }
    
    return;
}


- (void)finishAddPoint
{
    [super finishAddPoint];
    [self.paint finishAddPoint];
}

- (void)addPoint:(CGPoint)point inRect:(CGRect)rect
{
    [super addPoint:point inRect:rect];
    if (self.paint) {
       [self.paint addPoint:point inRect:rect];
    }else if(self.shape){
        self.shape.endPoint = point;
    }
    addPointTimes ++;
}

- (void)updateLastPoint:(CGPoint)point inRect:(CGRect)rect
{
    if (self.paint) {
        [self.paint addPoint:point inRect:rect];
    }else if(self.shape){
        self.shape.endPoint = point;
    }    
}

- (CGRect)redrawRectInRect:(CGRect)rect
{
    if (addPointTimes == 1) {
        return rect;
    }
    if (self.shape) {
        [self.shape rect];
        return self.shape.redrawRect;
    }else if(self.paint){
        return [self.paint redrawRectInRect:rect];
    }
    return CGRectZero;
}

@end