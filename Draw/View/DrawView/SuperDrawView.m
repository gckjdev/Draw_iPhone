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
/*
- (ClipAction *)currentClip
{
    return [cdManager currentClip];
}
*/
- (void)cleanAllActions
{
    [_drawActionList removeAllObjects];
//    [osManager clean];
//    [cdManager reset];
}

- (void)dealloc
{
    PPDebug(@"%@ dealloc", [self description]);
    PPRelease(_drawActionList);
    _currentAction = nil;
//    PPRelease(osManager);
//    PPRelease(cdManager);
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
    [dlManager arrangeActions:self.drawActionList];
}

//start to add a new draw action
- (void)addDrawAction:(DrawAction *)drawAction show:(BOOL)show
{
    [dlManager updateLastAction:drawAction refresh:show];
}

//update the last action
- (void)updateLastAction:(DrawAction *)action refresh:(BOOL)refresh
{
    [dlManager updateLastAction:action refresh:refresh];
}

//finish update the last action
- (void)finishLastAction:(DrawAction *)action refresh:(BOOL)refresh
{
    [dlManager finishLastAction:action refresh:refresh];
}

//remove the last action force to refresh
- (void)cancelLastAction{
    [dlManager cancelLastAction];
}


- (void)changeRect:(CGRect)rect
{
    
}

- (void)setBGImage:(UIImage *)image
{
//    [cdManager setBgPhto:image];
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

    [self.layer renderInContext:context];
    return context;
}


- (UIImage*)createImage
{
    UIGraphicsBeginImageContext(self.bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor whiteColor] setFill];
    CGContextFillRect(context, self.bounds);
//    [cdManager showInContextWithoutGrid:context];
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
        self.layer.contents = (id)image.CGImage;
    }
}
- (DrawLayer *)currentLayer
{
    return [dlManager selectedLayer];
}

- (void)enterClipMode:(ClipAction *)clipAction
{
    [dlManager enterClipMode:clipAction];
}

- (void)exitFromClipMode
{
    [dlManager exitFromClipMode];
}


@end
