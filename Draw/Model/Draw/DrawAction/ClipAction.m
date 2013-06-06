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

- (id)initWithPBDrawAction:(PBDrawAction *)action
{
    self = [super initWithPBDrawAction:action];
    if (self) {
        self.clipTag = (action.hasClipTag ? action.clipTag : 0);
        self.clipType = action.clipType;

        _hasUnClipContext = YES;
        _hasClipContext = NO;
    }
    return self;
}

- (id)initWithPBDrawActionC:(Game__PBDrawAction *)action
{
    self = [super initWithPBDrawActionC:action];
    if (self) {
        self.clipTag = action->has_cliptag ? action->cliptag : 0;
        self.clipType = action->cliptype;
        
        _hasUnClipContext = YES;
        _hasClipContext = NO;
    }
    return self;
}

- (CGRect)drawInContext:(CGContextRef)context inRect:(CGRect)rect
{
    CGContextSaveGState(context);
    CGRect retRrect;
    if (self.paint) {
       retRrect = [self.paint drawInContext:context inRect:rect];
    }else{
        [self.shape drawInContext:context];
        retRrect = self.shape.redrawRect;
    }
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
//        path = self.shape.path;
    }
    CGContextSaveGState(context);
    CGContextAddPath(context, path);
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
    pbDrawActionC->type = DrawActionTypeClip;
    pbDrawActionC->cliptag = self.clipTag;
    pbDrawActionC->cliptype = self.clipType;

    if (self.paint) {
        [self.paint updatePBDrawActionC:pbDrawActionC];
    }
    if (self.shape) {
        [self.shape updatePBDrawActionC:pbDrawActionC];
    }
    
    return;
}

@end