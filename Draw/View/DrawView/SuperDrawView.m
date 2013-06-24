//
//  SuperDrawView.m
//  Draw
//
//  Created by  on 12-9-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SuperDrawView.h"
#import <QuartzCore/QuartzCore.h>
#import "DrawView.h"
#import "UIViewUtils.h"
#import "UIImageExt.h"
#import "PenFactory.h"
#import "ImageManagerProtocol.h"
#import "SmoothQuadCurvePen.h"

#define DEFALT_MIN_SCALE 1
#define DEFALT_MAX_SCALE 10

@interface SuperDrawView()
{

}


@end

@implementation SuperDrawView
@synthesize drawActionList = _drawActionList;



- (void)cleanAllActions
{
    [_drawActionList removeAllObjects];
//    [osManager clean];
    [cdManager reset];
}

- (void)dealloc
{
    PPDebug(@"%@ dealloc", [self description]);
    PPRelease(_drawActionList);
    _currentAction = nil;
//    PPRelease(osManager);
    PPRelease(cdManager);
    PPRelease(_gestureRecognizerManager);
    [super dealloc];
}

- (CGLayerRef)createLayer
{
    return [DrawUtils createCGLayerWithRect:self.bounds];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
//        _scale = 1;
        self.minScale = DEFALT_MIN_SCALE;
        self.maxScale = DEFALT_MAX_SCALE;
        self.scale = self.minScale;
        _gestureRecognizerManager = [[GestureRecognizerManager alloc] init];
        [_gestureRecognizerManager addPanGestureReconizerToView:self];
        [_gestureRecognizerManager addPinchGestureReconizerToView:self];
        [_gestureRecognizerManager addDoubleTapGestureReconizerToView:self];
        _gestureRecognizerManager.delegate = self;

    }
    return self;
}

#pragma mark public method

- (void)setScale:(CGFloat)scale
{
    _scale = scale;
    CGAffineTransform transform = self.transform; //CGAffineTransformScale(self.transform, scale, scale);
    transform.a = transform.d = scale;
    self.transform = transform;
    
    PPDebug(@"<setScale>scale = %f, transform = %@, frame = %@", scale, NSStringFromCGAffineTransform(transform), NSStringFromCGRect(self.frame));
}

- (void)resetTransform
{
    [self setScale:self.minScale];
    self.center = CGRectGetCenter(self.superview.bounds);
}


- (BOOL)isViewBlank
{
    return [self.drawActionList count] == 0;
}


- (void)show
{
//    [osManager updateWithDrawActionList:self.drawActionList];
    [cdManager updateWithDrawActionList:self.drawActionList];
    [self setNeedsDisplay];
 
}


//- (void)drawPaint:(Paint *)paint show:(BOOL)show
//{
//    CGRect rect = [osManager updateLastPaint:paint];
//    if (show) {
//        [self setNeedsDisplayInRect:rect];
//    }
//}

#define SPAN_RECT_MIN_WIDTH 20

#define LAST_ACTION_UPDATE_POINT_COUNT 3

- (void)updateLastAction:(DrawAction *)action show:(BOOL)show
{
//    CGRect rect = [osManager updateLastAction:action];
    CGRect rect = [cdManager updateLastAction:action];
    if (show) {
        //如果笔不是透明的话，则更新最后3个点所在的区域即可，否则整笔全部更新
        
        if ([action isKindOfClass:[PaintAction class]]) {
            PaintAction *paintAction = (PaintAction *)action;
            if (paintAction.paint.color.alpha >= 1) {
                NSUInteger count = [[paintAction paint] pointCount];
                if (count > LAST_ACTION_UPDATE_POINT_COUNT) {
                    id<PenEffectProtocol> pen = [PenFactory getPen:Pencil];
                    NSArray *list = [paintAction.paint.pointNodeList subarrayWithRange:NSMakeRange(count - LAST_ACTION_UPDATE_POINT_COUNT, LAST_ACTION_UPDATE_POINT_COUNT)];
                    [pen constructPath:list inRect:self.bounds];
                    rect = CGPathGetBoundingBox([pen penPath]);
                    CGFloat w = MAX(paintAction.paint.width, SPAN_RECT_MIN_WIDTH);
                    CGRectEnlarge(&rect, w * 2, w * 2);
                }                
            }
        }

        [self setNeedsDisplayInRect:rect];
    }
}

- (void)drawDrawAction:(DrawAction *)drawAction show:(BOOL)show;
{
    if (drawAction) {
//        CGRect rect = [osManager addDrawAction:drawAction];
        CGRect rect = [cdManager addDrawAction:drawAction];
        if (show) {
            [self setNeedsDisplayInRect:rect];
        }        
    }
}

- (void)addDrawAction:(DrawAction *)drawAction
{
    if (drawAction) {
        [self.drawActionList addObject:drawAction];        
    }

}

- (DrawAction *)lastAction
{
    return [self.drawActionList lastObject];
}

- (void)changeRect:(CGRect)rect
{
    
}

- (void)setBGImage:(UIImage *)image
{
//    [osManager setBGOffscreenImage:image];
    [cdManager setBgPhto:image];
}

//- (void)setScale:(CGFloat)scale
//{
//    _scale = scale;
//    [self.layer setTransform:CATransform3DMakeScale(scale, scale, 1)];
//}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
//    [osManager showAllLayersInContext:context];
    [cdManager showInContext:context];
    [super drawRect:rect];
}



- (CGContextRef)createBitmapContext
{
    CGContextRef context = [DrawUtils createNewBitmapContext:self.bounds];    

    if (context == NULL) {
        PPDebug(@"<createBitmapContext> failed. context = NULL");
        return NULL;
    }
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, self.bounds);

    [cdManager showInContextWithoutGrid:context];
    
    return context;
}


- (UIImage*)createImage
{
    UIGraphicsBeginImageContext(self.bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [cdManager showInContextWithoutGrid:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;

}

- (UIImage *)createImageWithSize:(CGSize)size
{
    UIImage *image = [self createImage];
    UIImage *ret = [image imageByScalingAndCroppingForSize:size];
    image = nil;
    return ret;
}

- (void)showImage:(UIImage *)image
{
    if (image) {
        [self setBackgroundColor:[UIColor clearColor]];
        PPDebug(@"draw image in bounds = %@",NSStringFromCGRect(self.bounds));
        [cdManager reset];
        [cdManager setBgPhto:image];
        [self setNeedsDisplay];
//        [osManager clean];
//        Offscreen *os = [osManager enteryScreen];
//        [os showImage:image];
    }
}
@end
