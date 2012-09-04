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

- (void)dealloc
{
    PPDebug(@"%@ dealloc", [self description]);
    PPRelease(_drawActionList);
    PPRelease(_curImage);
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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
        }else if ([action isChnageBackAction]) {
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
    CGContextSetLineWidth(context, width);    
    CGContextSetStrokeColorWithColor(context, cgColor);
    CGContextStrokePath(context);
    
}

- (void)drawPaint:(Paint *)paint
{ 
    PPDebug(@"<SuperDrawView> draw paint");
    
    CGContextRef context = UIGraphicsGetCurrentContext(); 
    CGContextSetStrokeColorWithColor(context, paint.color.CGColor);
    CGContextSetFillColorWithColor(context, paint.color.CGColor);

    CGContextSetLineWidth(context, paint.width);    

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
            CGContextSetLineCap(context, kCGLineCapRound);
            
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
    PPDebug(@"<SuperDrawView> draw line");
    if ([_currentDrawAction isDrawAction]) {
        [self.curImage drawAtPoint:CGPointMake(0, 0)];
        CGColorRef color = _currentDrawAction.paint.color.CGColor;
        CGFloat width = _currentDrawAction.paint.width;
        [self drawPoint:width color:color];
    }
}

- (void)drawRect:(CGRect)rect
{
    
    switch (_drawRectType) {
        case DrawRectTypeLine:
        {
            [self drawRectLine:rect];
        }
            break;
        case DrawRectTypeRedraw:
        {
            [self drawRectRedraw:rect];
            break;
        }
        case DrawRectTypeChangeBack:
        {
            PPDebug(@"<SuperDrawView> change back");
            CGContextRef context = UIGraphicsGetCurrentContext(); 
            CGContextSetFillColorWithColor(context, _changeBackColor);
            CGContextFillRect(context, self.bounds);
        }
            break;
        case DrawRectTypeClean:
        default:
            break;
    }    
}


@end
