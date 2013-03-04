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
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [osManager showAllLayersInContext:context];
    [super drawRect:rect];
}


#define CTMContext(context,rect) \
CGContextScaleCTM(context, 1.0, -1.0);\
CGContextTranslateCTM(context, 0, -CGRectGetHeight(rect));

- (CGContextRef)createBitmapContext
{
    CGContextRef context = [DrawUtils createNewBitmapContext:self.bounds];//[self createNewBitmapContext];

    UIColor *color = nil;
    color = [UIColor whiteColor];
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, self.bounds);

    
    if (self.drawBg) {
        UIImage *image = [self.drawBg localImage];
        if (image) {
//            CGContextDrawImage(context, self.bounds, image.CGImage);
            [image drawAsPatternInRect:self.bounds];
        }
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
        UIImage *image = [drawBg localImage];
        self.backgroundColor = [UIColor colorWithPatternImage:image];
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
