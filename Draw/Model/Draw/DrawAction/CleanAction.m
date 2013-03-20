//
//  CleanAction.m
//  Draw
//
//  Created by gamy on 13-3-18.
//
//

#import "CleanAction.h"

@implementation CleanAction



- (CGRect)drawInContext:(CGContextRef)context inRect:(CGRect)rect
{
    CGContextClearRect(context, rect);
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
    CGContextFillRect(context, rect);
    CGContextRestoreGState(context);
    return rect;
}

- (id)initWithPBDrawAction:(PBDrawAction *)action
{
    self = [super initWithPBDrawAction:action];
    if (self) {
        self.type = DrawActionTypeClean;
    }
    return self;
}

- (id)init{
    self = [super init];
    if (self) {
        self.type = DrawActionTypeClean;
    }
    return self;
}

- (id)initWithPBNoCompressDrawAction:(PBNoCompressDrawAction *)action
{
    self = [super initWithPBNoCompressDrawAction:action];
    if (self) {
        
    }
    return self;
}


- (PBDrawAction *)toPBDrawAction
{
    PBDrawAction_Builder *builder = [[[PBDrawAction_Builder alloc] init] autorelease];
    [builder setType:DrawActionTypeClean];
    return [builder build];
}

- (void)addPoint:(CGPoint)point inRect:(CGRect)rect
{
    
}


@end
