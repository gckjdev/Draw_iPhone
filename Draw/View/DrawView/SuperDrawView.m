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
{
    PBDrawBg *_drawBg;
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
    PPRelease(_drawBg);
    PPRelease(_drawBgImage);
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
        _scale = 1;
        _gestureRecognizerManager = [[GestureRecognizerManager alloc] init];
        [_gestureRecognizerManager addPanGestureReconizerToView:self];
        [_gestureRecognizerManager addPinchGestureReconizerToView:self];
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
    [osManager updateWithDrawActionList:self.drawActionList];
    [self setNeedsDisplay];
 
}


- (void)drawPaint:(Paint *)paint show:(BOOL)show
{
    CGRect rect = [osManager updateLastPaint:paint];
    if (show) {
        [self setNeedsDisplayInRect:rect];
    }
}
- (void)drawDrawAction:(DrawAction *)drawAction show:(BOOL)show;
{
    CGRect rect = [osManager addDrawAction:drawAction];
    if (show) {
        [self setNeedsDisplayInRect:rect];
    }
}

- (void)addDrawAction:(DrawAction *)drawAction
{
    [self.drawActionList addObject:drawAction];
}


- (void)setScale:(CGFloat)scale
{
    _scale = scale;
    [self.layer setTransform:CATransform3DMakeScale(scale, scale, 1)];
}

- (UIImage *)drawBGImage
{
    if (self.drawBg) {
        return [self.drawBg localImage];
    }
    return nil;
}

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
    if (self.drawBgImage) {
        CGRect rect = CGRectZero;
        rect.size = self.drawBgImage.size;
        CGContextDrawTiledImage(context, rect, _drawBgImage.CGImage);
    }
    CTMContext(context, self.bounds);
    [osManager showAllLayersInContext:context];
    
    return context;
}

- (UIImage*)createImage
{
    
    PPDebug(@"<createImage> image bounds = %@", NSStringFromCGRect(self.bounds));
    CGContextRef context = [self createBitmapContext];
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

- (void)setDrawBg:(PBDrawBg *)drawBg
{
    if (_drawBg != drawBg) {
        PPRelease(_drawBg);
        _drawBg = [drawBg retain];
        self.drawBgImage = [drawBg localImage];
        if (self.drawBgImage) {
            self.backgroundColor = [UIColor colorWithPatternImage:self.drawBgImage];
        }else{
            //load remote image
            self.backgroundColor = [UIColor whiteColor];
            if ([drawBg.remoteUrl length] != 0) {
                __block SuperDrawView *sv = self;
                [DrawBgManager imageForRemoteURL:drawBg.remoteUrl success:^(UIImage *image, BOOL cached) {
                    sv.drawBgImage = image;
                    sv.backgroundColor = [UIColor colorWithPatternImage:image];
                } failure:^(NSError *error) {
                    PPDebug(@"error!!");
                }];
                
            }
        }
    }
}
- (PBDrawBg *)drawBg
{
    return _drawBg;
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
