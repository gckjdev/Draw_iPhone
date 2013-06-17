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
    [osManager clean];
}

- (void)dealloc
{
    PPDebug(@"%@ dealloc", [self description]);
    PPRelease(_drawActionList);
    _currentAction = nil;
    PPRelease(osManager);
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
    [osManager updateWithDrawActionList:self.drawActionList];
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

- (void)updateLastAction:(DrawAction *)action show:(BOOL)show
{
    CGRect rect = [osManager updateLastAction:action];
    if (show) {
        /* Don't Remove this code!! By Gamy, Optimize draw speed. 
            2013-6-14
         
        if ([action isKindOfClass:[PaintAction class]]) {
            PaintAction *paintAction = (PaintAction *)action;
            NSUInteger count = [[paintAction paint] pointCount];
            if (count > 2) {
                id<PenEffectProtocol> pen = [PenFactory getPen:Pencil];
                NSArray *list = [paintAction.paint.pointNodeList subarrayWithRange:NSMakeRange(count - 3, 3)];
                [pen constructPath:list inRect:self.bounds];
                rect = CGPathGetBoundingBox([pen penPath]);
                CGFloat w = MAX(paintAction.paint.width, SPAN_RECT_MIN_WIDTH);
                CGRectEnlarge(&rect, w * 4, w * 4);
            }
        }
         */ 

        [self setNeedsDisplayInRect:rect];
    }
}

- (void)drawDrawAction:(DrawAction *)drawAction show:(BOOL)show;
{
    if (drawAction) {
        CGRect rect = [osManager addDrawAction:drawAction];
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
    [osManager setBGOffscreenImage:image];
}

//- (void)setScale:(CGFloat)scale
//{
//    _scale = scale;
//    [self.layer setTransform:CATransform3DMakeScale(scale, scale, 1)];
//}


#define CTMContext(context,rect) \
CGContextScaleCTM(context, 1.0, -1.0);\
CGContextTranslateCTM(context, 0, -CGRectGetHeight(rect));


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [osManager showAllLayersInContext:context];
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

    CTMContext(context, self.bounds);
    [osManager showAllLayersInContext:context];
    
    return context;
}

- (UIImage*)createImage
{
    
    PPDebug(@"<createImage> image bounds = %@", NSStringFromCGRect(self.bounds));
    CGContextRef context = [self createBitmapContext];
    if (context == NULL) {
        return nil;
    }
    CGImageRef image = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    if (image == NULL) {
        return nil;
    }else{
        UIImage *img = [UIImage imageWithCGImage:image];
        CGImageRelease(image);
        return img;
    }
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
        [osManager clean];
        Offscreen *os = [osManager enteryScreen];
        [os showImage:image];
    }
}
@end
