//
//  PenView.m
//  DrawViewTest
//
//  Created by  on 12-4-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PenView.h"
#import "ShareImageManager.h"
#import "DeviceDetection.h"

#define VIEW_FRAME_IPAD CGRectMake(0,0,42,66)
#define TOTAL_HEIGHT_IPAD 30.0 * 2
#define BODY_HEIGHT_IPAD 20.0 * 2
#define BODY_WIDTH_IPAD 17.5 * 2

#define VIEW_FRAME CGRectMake(0,0,21,33)
#define TOTAL_HEIGHT 30.0
#define BODY_HEIGHT 20.0
#define BODY_WIDTH 17.5



@implementation PenView
@synthesize penType = _penType;

- (void)dealloc
{
    [super dealloc];
}

- (id)initWithPenType:(PenType)type
{
    if ([DeviceDetection isIPAD]) {
        self = [super initWithFrame:VIEW_FRAME_IPAD];        
    }else{
        self = [super initWithFrame:VIEW_FRAME];
    }
    if (self) {
        self.penType = type;
    }
    return self;
}

- (UIImage *)penImageForType:(PenType)type
{
    ShareImageManager *imageManager = [ShareImageManager defaultManager];
    switch (type) {
        case Pen:
            return [imageManager penImage];            
        case Quill:
            return [imageManager quillImage];            
        case WaterPen:
            return [imageManager waterPenImage];            
        case IcePen:
            return [imageManager iceImage];            
        case Pencil:
            return [imageManager pencilImage];            
    }
}



- (void) setPenType:(PenType)penType
{
    _penType = penType;
    UIImage *image = [self penImageForType:penType];
    [self setImage:image forState:UIControlStateNormal];
}

//@synthesize penColor = _penColor;
//
//
//- (void)initMaskImage
//{
//    if (!maskImage) {
//        maskImage = [[ShareImageManager defaultManager] penMaskImage].CGImage;
//        CGImageRetain(maskImage);
//        self.backgroundColor = [UIColor clearColor];                        
//    }
//}
//
//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        [self initMaskImage];
//    }
//    return self;
//}
//
//- (id)initWithPenColor:(DrawColor *)penColor
//{
//    if ([DeviceDetection isIPAD]) {
//        self = [self initWithFrame:VIEW_FRAME_IPAD];        
//    }else{
//        self = [self initWithFrame:VIEW_FRAME];
//    }
//    if (self) {
//        self.penColor = penColor;
//    }
//    return self;
//}
//
//+ (PenView *)viewWithColor:(DrawColor *)color
//{
//    return [[[PenView alloc] initWithPenColor:color] autorelease];
//}
//- (void)dealloc
//{
//    CGImageRelease(maskImage);
//    [_penColor release];
//    [super dealloc];
//}
//
//- (void)drawRect:(CGRect)rect
//{
//    
//    [self initMaskImage];
//    
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetFillColorWithColor(context, self.penColor.CGColor);
//    CGFloat X = 1.5;
//    CGFloat Y = 30;
//    const NSInteger size = 5;
//    
//    CGFloat *xList = NULL;
//    CGFloat *yList = NULL;
//    
//    if ([DeviceDetection isIPAD]) {
//        X = 1.5 * 2;
//        Y = 30 * 2;
//        CGFloat ixArray[] = {X + BODY_WIDTH_IPAD, X + BODY_WIDTH_IPAD, 
//            X + BODY_WIDTH_IPAD / 2.0, X, X};
//        CGFloat iyArray[] = {Y,Y - BODY_HEIGHT_IPAD, 
//            Y - TOTAL_HEIGHT_IPAD, Y - BODY_HEIGHT_IPAD, Y};
//        xList = ixArray;
//        yList = iyArray;
//    }else
//    {
//        CGFloat xArray[] = {X + BODY_WIDTH, X + BODY_WIDTH, X + BODY_WIDTH / 2.0, X, X};
//        CGFloat yArray[] = {Y,Y - BODY_HEIGHT, Y - TOTAL_HEIGHT, Y-BODY_HEIGHT, Y};
//        xList = xArray;
//        yList = yArray;
//    }
//    
//    CGContextMoveToPoint(context, X, Y);
//    for (int i = 0; i < size;  ++ i) {
//        CGContextAddLineToPoint(context, xList[i], yList[i]);
//    }
//    CGContextClosePath(context);
//    CGContextFillPath(context);    
//
//    CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
//	CGContextScaleCTM(context, 1.0, -1.0);
//    CGContextDrawImage(context, self.bounds, maskImage);
//    CGContextSaveGState(context);
//}
//
//- (void)setPenColor:(DrawColor *)penColor
//{
//    if (self.penColor != penColor) {
//        [_penColor release];
//        _penColor = penColor;
//        [_penColor retain];
//    }
//    [self setNeedsDisplay];
//}

@end
