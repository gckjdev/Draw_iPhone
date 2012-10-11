//
//  DrawView.m
//  Draw
//
//  Created by  on 12-3-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DrawView.h"
#import <QuartzCore/QuartzCore.h>

#pragma mark - revoke image.
@interface RevokeImage : NSObject {
    NSInteger _index;
    UIImage *_image;
}
@property(nonatomic, assign)NSInteger index;
@property(nonatomic, retain)UIImage *image;
+ (RevokeImage *)revokeImageWithImage:(UIImage *)image 
                                index:(NSInteger)index;
@end

@implementation RevokeImage
@synthesize index = _index;
@synthesize image = _image;
- (void)dealloc
{
    PPDebug(@"%@ dealloc", [self description]);
    PPRelease(_image);
    [super dealloc];
}

+ (RevokeImage *)revokeImageWithImage:(UIImage *)image 
                                index:(NSInteger)index
{
    RevokeImage *rImage = [[[RevokeImage alloc] init] autorelease];
    rImage.image = image;
    rImage.index = index;
    return rImage;
}

@end

#pragma mark - draw view implementation

@interface DrawView()
{
//    BOOL _drawFullRect;
    

}
#pragma mark Private Helper function
- (void)revokeRect:(CGRect)rect;

@end

#define DEFAULT_PLAY_SPEED (1/40.0)
#define DEFAULT_SIMPLING_DISTANCE (5.0)
#define DEFAULT_LINE_WIDTH (2.0 * 1.414)

#define REVOKE_PAINT_COUNT 25
#define REVOKE_CACHE_COUNT 5

@implementation DrawView

@synthesize lineColor = _lineColor;
@synthesize lineWidth = _lineWidth;
@synthesize delegate = _delegate;
@synthesize penType = _penType;
@synthesize revocationSupported = _revocationSupported;


- (void)addRevocationImage
{
    if (_revokeImageList == nil) {
        _revokeImageList = [[NSMutableArray alloc] init];
    }
    UIImage *image = [self createImage];
    if ([_revokeImageList count] >= REVOKE_CACHE_COUNT) {
        [_revokeImageList removeObjectAtIndex:0];
    }
    if (image) {
        NSInteger index = [_drawActionList count] - 1;
        RevokeImage *rImage = [RevokeImage revokeImageWithImage:image index:index];
        [_revokeImageList addObject:rImage];
        PPDebug(@"<addRevocationImage>add new revoke image, at index = %d",index);
    }
}
- (NSInteger)currentRevokeImageIndex
{
    RevokeImage *rImage = [_revokeImageList lastObject];
    return rImage.index;
}

- (void)addCleanAction
{
    DrawAction *cleanAction = [DrawAction actionWithType:DRAW_ACTION_TYPE_CLEAN paint:nil];
    [self.drawActionList addObject:cleanAction];
    _startDrawActionIndex = [self.drawActionList count];
    _drawRectType = DrawRectTypeClean;
    [self setNeedsDisplay];
//    [self addRevocationImage];
}

- (DrawAction *)addChangeBackAction:(DrawColor *)color
{
    DrawAction *action = [DrawAction changeBackgroundActionWithColor:color];
    [self.drawActionList addObject:action];
    _startDrawActionIndex = [self.drawActionList count] - 1;
    _drawRectType = DrawRectTypeChangeBack;
    _changeBackColor = color.CGColor;
    [self setNeedsDisplay];
//    [self addRevocationImage];
    return action;
}



- (void)setDrawEnabled:(BOOL)enabled
{
    self.userInteractionEnabled = enabled;
}

- (CGFloat)correctValue:(CGFloat)value max:(CGFloat)max min:(CGFloat)min
{
    if (value < min) 
        return min;
    if(value > max)
        return max;
    return value;
}

#pragma mark Gesture Handler
- (void)addPoint:(CGPoint)point toDrawAction:(DrawAction *)drawAction
{    
    if (drawAction) {
        
        point.x = [self correctValue:point.x max:self.bounds.size.width min:0];
        point.y = [self correctValue:point.y max:self.bounds.size.height min:0];
//        PPDebug(@"add point = %@", NSStringFromCGPoint(point));
        [drawAction.paint addPoint:point];   
    }
}
- (void)setPenType:(ItemType)penType
{
    _penType = penType;
}

- (BOOL)isEventLegal:(UIEvent *)event
{
    if(event && ([[event allTouches] count] == 1))
    {
        return YES;
    }
    return NO;
}
- (CGPoint)touchPoint:(UIEvent *)event
{
    for (UITouch *touch in [event allTouches]) {
        CGPoint point = [touch locationInView:self];
        return point;
    }    
    return ILLEGAL_POINT;
}

- (void)addNewPaint
{
    Paint *currentPaint = [Paint paintWithWidth:self.lineWidth color:self.lineColor penType:_penType];
    _currentDrawAction = [DrawAction actionWithType:DRAW_ACTION_TYPE_DRAW paint:currentPaint];
    [self.drawActionList addObject:_currentDrawAction];

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
//    PPDebug(@"touch began");
    UITouch *touch = [touches anyObject];
    
    _previousPoint1 = [touch previousLocationInView:self];
    _previousPoint2 = [touch previousLocationInView:self];
    _currentPoint = [touch locationInView:self];
    [self addNewPaint];
    [self touchesMoved:touches withEvent:event];
    if (self.delegate && [self.delegate 
                            respondsToSelector:@selector(didStartedTouch:)]) {
            [self.delegate didStartedTouch:_currentDrawAction.paint];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesMoved:touches withEvent:event];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDrawedPaint:)]) {
        [self.delegate didDrawedPaint:_currentDrawAction.paint];
    }
    
    if (![self isRevocationSupported]) {
        return;
    }
    
    //save revoke image
    if ([_drawActionList count] - [self currentRevokeImageIndex] >= 
        REVOKE_PAINT_COUNT) {
        [self addRevocationImage];
    }
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

    
    UITouch *touch  = [touches anyObject];
    
    _previousPoint2  = _previousPoint1;
    _previousPoint1  = _currentPoint;
    _currentPoint    = [touch locationInView:self];
    
    // calculate mid point
    
    CGPoint mid1 = [DrawUtils midPoint1:_previousPoint1
                                 point2:_previousPoint2];
    
    CGPoint mid2 = [DrawUtils midPoint1:_currentPoint
                                 point2:_previousPoint1];
            
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, mid1.x, mid1.y);
    CGPathAddQuadCurveToPoint(path, NULL, _previousPoint1.x, _previousPoint1.y, mid2.x, mid2.y);
    CGRect bounds = CGPathGetBoundingBox(path);
    CGPathRelease(path);
    
    CGRect drawBox = bounds;
    
    //Pad our values so the bounding box respects our line width
    drawBox.origin.x        -= self.lineWidth * 1;
    drawBox.origin.y        -= self.lineWidth * 1;
    drawBox.size.width      += self.lineWidth * 2;
    drawBox.size.height     += self.lineWidth * 2;
    
    
    UIGraphicsBeginImageContext(drawBox.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    self.curImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
        
    _drawRectType = DrawRectTypeLine;
    
    [self setNeedsDisplayInRect:drawBox];
    
    [self addPoint:_currentPoint toDrawAction:_currentDrawAction];

}
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (_drawRectType == DrawRectTypeRevoke) {
        [self revokeRect:rect];
    }
}



#pragma mark Constructor & Destructor

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.lineColor = [DrawColor blackColor];
        self.lineWidth = DEFAULT_LINE_WIDTH;
        _drawActionList = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor whiteColor];        
        _startDrawActionIndex = 0;
    }
    
    
    return self;
}

- (void)dealloc
{
    PPDebug(@"%@ dealloc", [self description]);
    PPRelease(_drawActionList);
    PPRelease(_revokeImageList);
    PPRelease(_lineColor);
    [super dealloc];
}



#pragma mark - Revoke

- (BOOL)canRevoke
{
    return [_drawActionList count] > 0;
}
- (void)revoke
{
    if ([self canRevoke]) {
        [_drawActionList removeLastObject];
        if ([self currentRevokeImageIndex] >= [_drawActionList count]) {
            [_revokeImageList removeLastObject];
        }
        _drawRectType = DrawRectTypeRevoke;
        [self setNeedsDisplay];        
    }
}



- (void)revokeRect:(CGRect)rect
{
    RevokeImage *rImage = [_revokeImageList lastObject];
    [rImage.image drawInRect:self.bounds];
    int j = [self currentRevokeImageIndex];
    for (; j < self.drawActionList.count; ++ j) {
        DrawAction *drawAction = [self.drawActionList objectAtIndex:j];
        CGContextRef context = UIGraphicsGetCurrentContext();
        if ([drawAction isCleanAction]) {
            CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor);
            CGContextFillRect(context, self.bounds);
        }else if([drawAction isChangeBackAction]){
            CGContextSetFillColorWithColor(context, drawAction.paint.color.CGColor);
            CGContextFillRect(context, self.bounds);
        }else if ([drawAction isDrawAction]) {      
            Paint *paint = drawAction.paint;
            [self drawPaint:paint];
        }
    }
}

@end
