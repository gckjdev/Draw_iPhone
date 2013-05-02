//
//  ChangeBackAction.m
//  Draw
//
//  Created by gamy on 13-3-18.
//
//

#import "ChangeBackAction.h"
#import "DrawUtils.h"
#import "DrawColor.h"
#import "Paint.h"

@interface ChangeBackAction()
{
    
}
@property(nonatomic, retain)DrawColor *color;

@end

@implementation ChangeBackAction

- (DrawColor *)color
{
    return _color;
}
- (void)dealloc
{
    PPRelease(_color);
    [super dealloc];
}

- (CGRect)drawInContext:(CGContextRef)context inRect:(CGRect)rect
{
    CGContextClearRect(context, rect);
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, [self.color CGColor]);
    CGContextFillRect(context, rect);
    CGContextRestoreGState(context);
    return rect;
}

- (id)initWithColor:(DrawColor *)color
{
    self = [super init];
    if (self) {
        self.color = color;
        self.type = DrawActionTypeChangeBack;
    }
    return self;
}

- (id)initWithPBDrawActionC:(Game__PBDrawAction *)action
{
    self = [super initWithPBDrawActionC:action];
    if (self) {
        self.type = DrawActionTypeChangeBack;
        if (action->has_bettercolor) {
            self.color = [DrawColor colorWithBetterCompressColor:action->bettercolor];
        }else{
            self.color = [DrawUtils decompressIntDrawColor:action->color];
        }
    }
    return self;
}

- (id)initWithPBDrawAction:(PBDrawAction *)action
{
    self = [super initWithPBDrawAction:action];
    if (self) {
        self.type = DrawActionTypeChangeBack;
        if ([action hasBetterColor]) {
            self.color = [DrawColor colorWithBetterCompressColor:action.betterColor];
        }else{
            self.color = [DrawUtils decompressIntDrawColor:action.color];
        }
    }
    return self;
}

- (id)initWithPBNoCompressDrawAction:(PBNoCompressDrawAction *)action
{
    self = [super initWithPBNoCompressDrawAction:action];
    if (self) {
        self.type = DrawActionTypeChangeBack;
        self.color = action.drawColor;
    }
    return self;
}


- (PBDrawAction *)toPBDrawAction
{
    PBDrawAction_Builder *builder = [[[PBDrawAction_Builder alloc] init] autorelease];
    [builder setType:DrawActionTypeChangeBack];
    [builder setWidth:BACK_GROUND_WIDTH];
    [builder addPointsX:0];
    [builder addPointsX:0];
    [builder addPointsY:0];
    [builder addPointsY:BACK_GROUND_WIDTH];
    [builder setBetterColor:[self.color toBetterCompressColor]];
    return [builder build];
}

- (void)addPoint:(CGPoint)point inRect:(CGRect)rect
{
    [super addPoint:point inRect:rect];
}

- (void)finishAddPoint
{
    [super finishAddPoint];
}

@end
