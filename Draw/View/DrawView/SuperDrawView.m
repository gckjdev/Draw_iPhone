//
//  SuperDrawView.m
//  Draw
//
//  Created by  on 12-9-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SuperDrawView.h"
#import <QuartzCore/QuartzCore.h>


@interface SuperDrawView()



@end

@implementation SuperDrawView
@synthesize drawActionList = _drawActionList;



//CGPoint midPoint(CGPoint p1, CGPoint p2)
//{
//    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
//}



- (void)dealloc
{
    PPDebug(@"%@ dealloc", [self description]);
    PPRelease(_drawActionList);
    _currentAction = nil;
    CGLayerRelease(cacheLayerRef), cacheLayerRef = NULL;
    CGLayerRelease(showLayerRef), showLayerRef = NULL;
    [super dealloc];
}


- (CGContextRef)createBitmapContext
{
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGColorSpaceRef colorSpace =  CGColorSpaceCreateDeviceRGB();
    
    CGContextRef context = CGBitmapContextCreate(
                                                 NULL,
                                                 width,
                                                 height,
                                                 8, // 每个通道8位
                                                 width * 4,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    return context;
}

- (CGLayerRef)createLayer
{
    CGContextRef context = [self createBitmapContext];
    CGLayerRef layer = CGLayerCreateWithContext(context, self.bounds.size, NULL);
    CGContextRelease(context);
    return layer;
}

- (void)setupCGLayer
{
    cacheLayerRef = [self createLayer];
    showLayerRef = [self createLayer];
    cacheContext = CGLayerGetContext(cacheLayerRef);
    showContext = CGLayerGetContext(showLayerRef);

    CGContextSetLineJoin(showContext, kCGLineJoinRound);
    CGContextSetLineCap(showContext, kCGLineCapRound);
    CGContextSetFlatness(showContext, 0.6f);

    CGContextSetLineJoin(cacheContext, kCGLineJoinRound);
    CGContextSetLineCap(cacheContext, kCGLineCapRound);
    CGContextSetFlatness(cacheContext, 0.6f);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupCGLayer];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

#pragma mark public method



- (BOOL)isViewBlank
{
    return [DrawAction isDrawActionListBlank:self.drawActionList];
}


- (void)show
{
    CGContextClearRect(showContext, self.bounds);
    for (DrawAction *action in self.drawActionList) {
        [self drawAction:action inContext:showContext];
    }
    [self setNeedsDisplayInRect:self.bounds showCacheLayer:NO];
}



- (void)cleanAllActions
{
    _currentAction = nil;
    [self.drawActionList removeAllObjects];
    CGContextClearRect(showContext, self.bounds);
//    showCacheLayer = NO;
    [self setNeedsDisplayInRect:self.bounds showCacheLayer:NO];
}

- (void)addDrawAction:(DrawAction *)drawAction
{
    [self.drawActionList addObject:drawAction];
}

- (void)drawAction:(DrawAction *)action inContext:(CGContextRef)context
{
    if ([action isCleanAction]) {
        CGContextClearRect(context, self.bounds);
    }else if([action isChangeBackAction]){
        CGColorRef color = action.paint.color.CGColor;
        CGContextSetFillColorWithColor(context, color);
        CGContextFillRect(context, self.bounds);
    }else if([action isDrawAction]){
        [self setStrokeColor:action.paint.color lineWidth:action.paint.width inContext:context];
        [self strokePaint:action.paint inContext:context clear:NO];
    }
}

- (void)strokePaint:(Paint *)paint inContext:(CGContextRef)context clear:(BOOL)clear
{
    if (clear) {
        CGRect drawBox = self.bounds;
        //[DrawUtils rectForPath:paint.path withWidth:paint.width];
        CGContextClearRect(context, drawBox);
    }
    CGContextAddPath(context, paint.path);
    CGContextStrokePath(context);
}

- (void)setStrokeColor:(DrawColor *)color lineWidth:(CGFloat)width inContext:(CGContextRef)context
{
    CGContextSetLineWidth(context, width);
    CGContextSetStrokeColorWithColor(context, color.CGColor);
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextDrawLayerAtPoint(context, CGPointZero, showLayerRef);
    if (showCacheLayer) {
        CGContextDrawLayerAtPoint(context, CGPointZero, cacheLayerRef);
    }
    
    [super drawRect:rect];
}


//- (void)setNeedsDisplayShowCacheLayer:(BOOL)show
//{
//    showCacheLayer = show;
//    [self setNeedsDisplay];
//}


- (void)setNeedsDisplayInRect:(CGRect)rect showCacheLayer:(BOOL)show
{
    showCacheLayer = show;
    [self setNeedsDisplayInRect:rect];
}

- (UIImage*)createImage
{
    
    PPDebug(@"<createImage> image bounds = %@", NSStringFromCGRect(self.bounds));
    CGContextRef context = [self createBitmapContext];
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -CGRectGetHeight(self.bounds));
    
    CGContextDrawLayerInRect(context, self.bounds, showLayerRef);

    CGImageRef image = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    if (image == NULL) {
        return nil;
    }else{
        UIImage *img = [UIImage imageWithCGImage:image];
        CGImageRelease(image);
//        PPDebug(@"<createImage> image size = %@",NSStringFromCGSize(img.size));
//        UIImageWriteToSavedPhotosAlbum(img, nil, NULL, nil);
        return img;
    }

}

- (void)showImage:(UIImage *)image
{
    if (image) {
        PPDebug(@"draw image in bounds = %@",NSStringFromCGRect(self.bounds));
//        CGContextSaveGState(showContext);
//        CGContextScaleCTM(showContext, 1.0, -1.0);
//        CGContextTranslateCTM(showContext, 0.0, CGRectGetWidth(self.bounds));
        CGContextDrawImage(showContext, self.bounds, image.CGImage);
//        CGContextRestoreGState(showContext);
        [self setNeedsDisplayInRect:self.bounds showCacheLayer:NO];
    }
}
@end
