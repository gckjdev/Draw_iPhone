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




- (id)initWithPBNoCompressDrawActionC:(Game__PBNoCompressDrawAction*)action
{
    self = [super initWithPBNoCompressDrawActionC:action];
    if (self) {
        self.type = DrawActionTypeChangeBack;                
        self.color = [DrawUtils drawColorFromPBNoCompressDrawActionC:action];
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

- (void)toPBDrawActionC:(Game__PBDrawAction*)pbDrawActionC
{
    pbDrawActionC->type = DrawActionTypeChangeBack;

    pbDrawActionC->width = BACK_GROUND_WIDTH;
    pbDrawActionC->has_width = 1;
    
    pbDrawActionC->pointsx = malloc(sizeof(float)*2);
    pbDrawActionC->n_pointsx = 2;
    pbDrawActionC->pointsx[0] = 0;
    pbDrawActionC->pointsx[1] = 0;    
    
    pbDrawActionC->pointsy = malloc(sizeof(float)*2);
    pbDrawActionC->n_pointsy = 2;
    pbDrawActionC->pointsy[0] = 0;
    pbDrawActionC->pointsy[1] = BACK_GROUND_WIDTH;
    
    pbDrawActionC->bettercolor = [self.color toBetterCompressColor];
    pbDrawActionC->has_bettercolor = 1;
    
    return;
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
