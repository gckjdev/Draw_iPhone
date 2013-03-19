//
//  ShapeAction.m
//  Draw
//
//  Created by gamy on 13-3-18.
//
//

#import "ShapeAction.h"
#import "ShapeInfo.h"
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
    [self.shape drawInContext:context];
    return self.shape.redrawRect;
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
        [self.shape setPointsWithPointComponent:action.rectComponentList];
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
        [self.shape setPointsWithPointComponent:action.rectComponentList];
        self.shape.color = action.drawColor;
    }
    return self;
}


- (PBDrawAction *)toPBDrawAction
{
    PBDrawAction_Builder *builder = [[[PBDrawAction_Builder alloc] init] autorelease];
    [builder setType:DrawActionTypeShape];
    [self.shape updatePBDrawActionBuilder:builder];
    return [builder build];
}

- (void)addPoint:(CGPoint)point inRect:(CGRect)rect
{
    self.shape.endPoint = point;
}

@end
