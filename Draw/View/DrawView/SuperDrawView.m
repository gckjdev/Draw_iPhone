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

- (void)dealloc
{
    PPRelease(_drawActionList);
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
    [self.layer renderInContext:context];
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
    if ([paint pointCount] != 0) {
        _currentPoint = _previousPoint1 = _previousPoint2 = [paint pointAtIndex:0];
    }
    for (int i = 0; i < [paint pointCount]; ++ i) {
        _currentPoint = [paint pointAtIndex:i];
        [self drawPoint:paint.width color:paint.color.CGColor];
        _previousPoint2 = _previousPoint1;
        _previousPoint1 = _currentPoint;
    }
}

- (void)drawRectRedraw:(CGRect)rect
{
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
    if ([_currentDrawAction isDrawAction]) {
        [_curImage drawAtPoint:CGPointMake(0, 0)];
        CGColorRef color = _currentDrawAction.paint.color.CGColor;
        CGFloat width = _currentDrawAction.paint.width;
        [self drawPoint:width color:color];
        PPRelease(_curImage);
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
