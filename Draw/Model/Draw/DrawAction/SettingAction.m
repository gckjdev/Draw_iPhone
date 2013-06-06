//
//  SettingAction.m
//  Draw
//
//  Created by gamy on 13-6-5.
//
//

#import "SettingAction.h"
#import "PointNode.h"
#import "GameBasic.pb-c.h"
#import "GameBasic.pb.h"

@implementation SettingAction

- (id)initWithPBDrawAction:(PBDrawAction *)action
{
    self = [super initWithPBDrawAction:action];
    if (self) {
        if ([action hasSettingInfo]) {
            self.tag = [[action settingInfo] tag];
            self.clipType = [[action settingInfo] clipType];
        }
    }
    return self;
}


- (void)updateDrawActionBuilder:(PBDrawAction_Builder *)builder
{
    [builder setType:DrawActionTypeSelectionEnd];
    
    PBSettingInfo_Builder *setting = [[PBSettingInfo_Builder alloc] init];
    [setting setClipType:self.clipType];
    [setting setTag:self.tag];
    
    [builder setSettingInfo:[setting build]];
}

- (PBDrawAction *)toPBDrawAction
{
    PBDrawAction_Builder *builder = [[PBDrawAction_Builder alloc] init];
    [self updateDrawActionBuilder:builder];
    PBDrawAction *pbDrawAction = [builder build];
    [builder release];
    return pbDrawAction;
}

- (void)toPBDrawActionC:(Game__PBDrawAction*)pbDrawActionC
{
    pbDrawActionC->type = self.type;
    
    //set setting info
    pbDrawActionC->settinginfo = malloc(sizeof(Game__PBSettingInfo));
    game__pbsetting_info__init(pbDrawActionC->settinginfo);
    pbDrawActionC->settinginfo->tag = self.tag;
    pbDrawActionC->settinginfo->cliptype = self.clipType;
    pbDrawActionC->settinginfo->has_cliptype = 1;
    
    return;
}

@end


@interface ClipStartAction()
{
    CGPathRef _clipPath;
    CGFloat *_px;
    CGFloat *_py;
}
@end

@implementation ClipStartAction

- (void)dealloc
{
    
    PPCGPathRelease(_clipPath);
    PPFree(_px);
    PPFree(_py);
    [super dealloc];
}


- (void)createPathWithPBDrawActionC:(Game__PBDrawAction *)action
{
    NSUInteger count = action->n_pointsx;
    if (count > 0 && action->pointsx != NULL && action->pointsy != NULL) {
        
        id<PathConstructorProtocol> constructor = getPathConstructorByPathConstructType(self.clipType);
        _clipPath = [constructor createPathWithXList:action->pointsx yList:action->pointsy count:count];
    }    
}


- (void)createPathWithPBDrawAction:(PBDrawAction *)action
{
    NSUInteger count = [[action pointsXList] count];
    
    if (count > 0) {
        id<PathConstructorProtocol> constructor = getPathConstructorByPathConstructType(self.clipType);
        
        PPFree(_px); PPFree(_py);

        _px = malloc(sizeof(CGFloat) * [[action pointsXList] count]);
        _py = malloc(sizeof(CGFloat) * [[action pointsYList] count]);

        NSUInteger i = 0;
        for (NSNumber *num in action.pointsXList) {
            _px[i ++] = [num floatValue];
        }
        
        i = 0;
        for (NSNumber *num in action.pointsYList) {
            _py[i ++] = [num floatValue];
        }
        
        _clipPath = [constructor createPathWithXList:_px yList:_py count:count];
    }
    
}

- (id)initWithPBDrawAction:(PBDrawAction *)action
{
    self = [super initWithPBDrawAction:action];
    if (self) {
        if ([action hasSettingInfo]) {
            [self createPathWithPBDrawAction:action];
        }
    }
    return self;
}

- (id)initWithPBDrawActionC:(Game__PBDrawAction *)action
{
    self = [super initWithPBDrawActionC:action];
    if (self) {
        if (action->settinginfo != NULL) {
            [self createPathWithPBDrawActionC:action];
        }
    }
    return self;
}

- (CGRect)drawInContext:(CGContextRef)context inRect:(CGRect)rect
{
    CGContextSaveGState(context);
    CGPathRef path = [self clipPath];
    CGContextAddPath(context, path);
    CGContextClip(context);
    return  CGPathGetBoundingBox(path);
}

- (CGPathRef)clipPath
{
    return _clipPath;
}

- (void)updateDrawActionBuilder:(PBDrawAction_Builder *)builder
{
//    if ([self.pointNodeList count] != 0) {
//        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
//        
//        NSMutableArray *pointXList = nil;
//        NSMutableArray *pointYList = nil;
//
//        
//        
//        [builder addAllPointsX:pointXList];
//        [builder addAllPointsY:pointYList];
//        
//        [pool drain];
//    }
}

@end


@implementation ClipEndAction

- (id)initWithPBDrawAction:(PBDrawAction *)action
{
    self = [super initWithPBDrawAction:action];
    if (self) {
        //
    }
    return self;
}

- (id)initWithPBDrawActionC:(Game__PBDrawAction *)action
{
    self = [super initWithPBDrawActionC:action];
    if (self) {
        //
    }
    return self;
}

- (CGRect)drawInContext:(CGContextRef)context inRect:(CGRect)rect
{
    CGContextRestoreGState(context);
    return rect;
}



@end