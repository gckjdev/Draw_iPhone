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


- (void)drawPaint:(Paint *)paint;

@end

@implementation SuperDrawView
@synthesize drawActionList = _drawActionList;
@synthesize curImage = _curImage;


//CGPoint midPoint(CGPoint p1, CGPoint p2)
//{
//    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
//}



- (void)dealloc
{
    PPDebug(@"%@ dealloc", [self description]);
    PPRelease(_drawActionList);
    PPRelease(_curImage);
    PPRelease(_image);
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

#pragma mark public method

- (void)clearAllActions
{
    [self.drawActionList removeAllObjects];
    _startDrawActionIndex = 0;
    _drawRectType = DrawRectTypeClean;
    [self setNeedsDisplay];
}

- (BOOL)isViewBlank
{
    return [DrawAction isDrawActionListBlank:self.drawActionList];
}

- (void)resetStartIndex
{
    int count = [self.drawActionList count];
    while (count > 0) {
        DrawAction *action = [self.drawActionList objectAtIndex:--count];
        if ([action isCleanAction]) {
            _startDrawActionIndex = count+1;
            return;
        }else if ([action isChangeBackAction]) {
            _startDrawActionIndex = count;
            _changeBackColor = action.paint.color.CGColor;
            return;
        }
    }
    _startDrawActionIndex = 0;
}


- (void)show
{
    [self resetStartIndex];
    _drawRectType = DrawRectTypeRedraw;
    [self setNeedsDisplay];
}

- (void)showImage:(UIImage *)image
{
    if (_image != image) {
        [_image release];
        _image = [image retain];
    }
    _drawRectType = DrawRectTypeShowImage;
    [self setNeedsDisplay];
}

- (UIImage*)createImage
{
    CGRect rect = self.frame;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if ([self retainCount] > 0) {
        [self.layer renderInContext:context];        
    }else{
        return nil;
    }

    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}


- (void)cleanAllActions
{
    [_drawActionList removeAllObjects];
    _currentDrawAction = nil;
    _drawRectType = DrawRectTypeClean;
    [self setNeedsDisplay];
}



#pragma mark drawRect

- (void)drawPoint:(CGFloat)width color:(CGColorRef)cgColor
{
    CGPoint mid1 = [DrawUtils midPoint1:_previousPoint1
                                 point2:_previousPoint2];
    
    CGPoint mid2 = [DrawUtils midPoint1:_currentPoint
                                 point2:_previousPoint1];

    CGContextRef context = UIGraphicsGetCurrentContext(); 
    
    if (context == NULL) {
        PPDebug(@"context = NULL");
    }
//    PPDebug(@"super draw view retain count = %d", [self retainCount]);
    
    if ([self retainCount] > 10) {
        PPDebug(@"retain count > 10");
    }


    [self.layer renderInContext:context];
    CGContextMoveToPoint(context, mid1.x, mid1.y);
    CGContextAddQuadCurveToPoint(context, _previousPoint1.x, _previousPoint1.y, mid2.x, mid2.y); 
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineWidth(context, width);    

    CGContextSetStrokeColorWithColor(context, cgColor);
    CGContextStrokePath(context);
    
    self.curImage = nil;
}

- (void)drawPaint:(Paint *)paint
{ 
//    PPDebug(@"<SuperDrawView> draw paint");
    
    CGContextRef context = UIGraphicsGetCurrentContext(); 
    CGContextSetStrokeColorWithColor(context, paint.color.CGColor);
    CGContextSetFillColorWithColor(context, paint.color.CGColor);
    CGContextSetLineWidth(context, paint.width);    
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    self.curImage = nil;
    if ([paint pointCount] != 0) {
        
        _currentPoint = _previousPoint2 = _previousPoint1 = [paint pointAtIndex:0];
        CGPoint mid1 = [DrawUtils midPoint1:_previousPoint1
                                     point2:_previousPoint2];
        CGContextMoveToPoint(context, mid1.x, mid1.y);
        for (int i = 0; i < [paint pointCount]; ++ i) {
            _currentPoint = [paint pointAtIndex:i];            
            
            CGPoint mid2 = [DrawUtils midPoint1:_currentPoint
                                         point2:_previousPoint1];
            CGContextAddQuadCurveToPoint(context, _previousPoint1.x, _previousPoint1.y, mid2.x, mid2.y); 
            _previousPoint2 = _previousPoint1;
            _previousPoint1 = _currentPoint;

        }
        CGContextStrokePath(context);
    }else{
        return;
    }


}

- (void)drawRectRedraw:(CGRect)rect
{
    PPDebug(@"<SuperDrawView> drawRectRedraw");
    for (int j = _startDrawActionIndex; j < self.drawActionList.count; ++ j) {
        DrawAction *drawAction = [self.drawActionList objectAtIndex:j];
        if ([drawAction isDrawAction]) {      
            Paint *paint = drawAction.paint;
            [self drawPaint:paint];
        }
    }
}

- (void)drawRectLine:(CGRect)rect
{
//    PPDebug(@"<SuperDrawView> draw line,rect = %@",NSStringFromCGRect(rect));
    
    if ([_currentDrawAction isDrawAction]) {
        [_curImage drawAtPoint:CGPointMake(0, 0)];
        CGColorRef color = _currentDrawAction.paint.color.CGColor;
//        UIImage *image = [UIImage imageNamed:@"brush1.jpg"];
//        CGColorRef color = [UIColor colorWithPatternImage:image].CGColor;
        CGFloat width = _currentDrawAction.paint.width;
        [self drawPoint:width color:color];
        [super drawRect:rect];
    }
}

- (void)revokeRect:(CGRect)rect
{
    PPDebug(@"<SuperDrawView> revokeRect. Should Not Call This!!!!!");
}

//- (void)revokeRect:(CGRect)rect
//{
//    UIImage *image = [_revokeImageList lastObject];
//    [image drawInRect:rect];
//    int j = 0;
//    NSInteger count = [_revokeImageList count];
//    if (count!= 0) {
//        j = [_drawActionList count] / count;
//        j = count * REVOKE_PAINT_COUNT;
//    }
//    for (; j < self.drawActionList.count; ++ j) {
//        DrawAction *drawAction = [self.drawActionList objectAtIndex:j];
//        if ([drawAction isDrawAction]) {      
//            Paint *paint = drawAction.paint;
//            [self drawPaint:paint];
//        }
//    }
//
//}

- (void)drawRect:(CGRect)rect
{
    
    switch (_drawRectType) {
        case DrawRectTypeLine:
        {
//            PPDebug(@"<SuperDrawView> drawRectLine");
            [self drawRectLine:rect];
        }
            break;
        case DrawRectTypeRedraw:
        {
            PPDebug(@"<SuperDrawView> drawRectRedraw");
            [self drawRectRedraw:rect];
            break;
        }
        case DrawRectTypeChangeBack:
        {
            PPDebug(@"<SuperDrawView> DrawRectTypeChangeBack");
            CGContextRef context = UIGraphicsGetCurrentContext(); 
            CGContextSetFillColorWithColor(context, _changeBackColor);
            CGContextFillRect(context, self.bounds);
        }
            break;
            
        case DrawRectTypeRevoke:
        {
            PPDebug(@"<SuperDrawView> DrawRectTypeRevoke");
            [self revokeRect:rect];
        }
            break;
        case DrawRectTypeShowImage:
        {
//            [self stop];
            PPDebug(@"<SuperDrawView> show Image");
            if (_image) {
                [_image drawAtPoint:CGPointMake(0, 0)];
                
                PPDebug(@"<SuperDrawView>draw image (size = %@) in rect(%@)",NSStringFromCGSize(_image.size),NSStringFromCGRect(rect));

            }else{
                [self show];
                PPDebug(@"<SuperDrawView> image is nil");
            }
            

        }
            break;
        case DrawRectTypeClean:
        default:
            break;
    }    
}


@end
