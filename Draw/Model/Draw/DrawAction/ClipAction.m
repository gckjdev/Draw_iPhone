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
@property(nonatomic, retain)Paint *paint;
@property(nonatomic, retain)ShapeInfo *shape;

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
    NSInteger count =  action->n_points;
    
    if (count > 0) {
        pointList = [NSMutableArray arrayWithCapacity:count];
        for (NSInteger i = 0; i < count; ++ i) {
            Game__PBPoint* point = action->points[i];
            if (point != NULL){
                PointNode *node = [[PointNode alloc] initPointWithX:point->x Y:point->y];
                [pointList addObject:node];
                [node release];
            }
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
    ShapeType shapeType;
    if (action->cliptype == ClipTypeEllipse) {
        shapeType = ShapeTypeEmptyEllipse;
    }else if(action->cliptype == ClipTypeRectangle){
        shapeType = ShapeTypeEmptyRectangle;
    }
    self.shape = [ShapeInfo shapeWithType:shapeType
                                  penType:Pencil
                                    width:1
                                    color:[DrawColor blackColor]];
    
    [self.shape setPointsWithPointComponentC:action->rectcomponent listCount:action->n_rectcomponent];
}


- (void)commonInit
{
    _hasUnClipContext = YES;
    _hasClipContext = NO;
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


- (CGRect)drawInContext:(CGContextRef)context inRect:(CGRect)rect
{
    CGContextSaveGState(context);
    CGRect retRrect;
    
    static CGFloat lengths[] = {3,3};
    
    CGContextSetLineDash(context, 0, lengths, 2);
    
    if (self.paint) {
       retRrect = [self.paint drawInContext:context inRect:rect];
    }else{
        [self.shape drawInContext:context];
        retRrect = self.shape.redrawRect;
    }
    
    CGContextRestoreGState(context);
    
    return retRrect;
}


- (void)clipContext:(CGContextRef)context
{
    if (_hasClipContext) {
        return;
    }
    _hasClipContext = YES;
    _hasUnClipContext = !_hasClipContext;
    
    CGPathRef path = NULL;
    
    if (self.paint) {
        path = self.paint.path;
    }else{
        path = self.shape.path;
    }
    CGContextSaveGState(context);
    CGContextAddPath(context, path);
    CGContextClosePath(context);
    CGContextClip(context);
}




- (void)unClipContext:(CGContextRef)context
{
    if (_hasUnClipContext) {
        return;
    }
    _hasUnClipContext = YES;
    _hasClipContext = !_hasUnClipContext;
    CGContextRestoreGState(context);
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


- (void)addPoint:(CGPoint)point inRect:(CGRect)rect
{
    [super addPoint:point inRect:rect];
    if (self.paint) {
       [self.paint addPoint:point inRect:rect];
    }else if(self.shape){
        self.shape.endPoint = point;
    }
}

@end