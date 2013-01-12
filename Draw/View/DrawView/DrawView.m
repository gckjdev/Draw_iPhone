//
//  DrawView.m
//  Draw
//
//  Created by  on 12-3-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DrawView.h"
#import "PPStack.h"
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
    PPStack *_redoStack;
    CGPoint _currentPoint;
    
}
#pragma mark Private Helper function
- (void)clearRedoStack;

@end


#define DEFAULT_LINE_WIDTH (ISIPAD ? 6 : 3)

#define REVOKE_PAINT_COUNT 30
#define REVOKE_CACHE_COUNT 10

@implementation DrawView

@synthesize lineColor = _lineColor;
@synthesize lineWidth = _lineWidth;
@synthesize delegate = _delegate;
@synthesize penType = _penType;
//@synthesize revocationSupported = _revocationSupported;


#pragma mark - util methods
- (CGFloat)correctValue:(CGFloat)value max:(CGFloat)max min:(CGFloat)min
{
    if (value < min)
        return min;
    if(value > max)
        return max;
    return value;
}

- (CGPoint)correctPoint:(CGPoint)point
{
    CGPoint p = CGPointZero;
    p.x = [self correctValue:point.x max:self.bounds.size.width min:0];
    p.y = [self correctValue:point.y max:self.bounds.size.height min:0];
    return p;
}

- (void)addNewPaint
{
    Paint *currentPaint = [Paint paintWithWidth:self.lineWidth color:self.lineColor penType:_penType];
    _currentAction = [DrawAction actionWithType:DRAW_ACTION_TYPE_DRAW paint:currentPaint];
    [self.drawActionList addObject:_currentAction];
    
}

- (void)addPoint:(CGPoint)point toDrawAction:(DrawAction *)drawAction
{
    if (drawAction) {
        [drawAction.paint addPoint:point];
    }
}

//- (BOOL)isEventLegal:(UIEvent *)event
//{
//    if(event && ([[event allTouches] count] == 1))
//    {
//        return YES;
//    }
//    return NO;
//}

//- (CGPoint)touchPoint:(UIEvent *)event
//{
//    for (UITouch *touch in [event allTouches]) {
//        CGPoint point = [touch locationInView:self];
//        return point;
//    }
//    return ILLEGAL_POINT;
//}

#pragma mark -- paint action

- (void)clearScreen
{
    [self clearRedoStack];
    DrawAction *cleanAction = [DrawAction clearScreenAction];
    [self.drawActionList addObject:cleanAction];
    [self drawAction:cleanAction inContext:showContext];
    [self setNeedsDisplayShowCacheLayer:NO];
}
- (void)changeBackWithColor:(DrawColor *)color
{
    [self clearRedoStack];
    DrawAction *cleanAction = [DrawAction changeBackgroundActionWithColor:color];
    [self.drawActionList addObject:cleanAction];
    [self drawAction:cleanAction inContext:showContext];
    [self setNeedsDisplayShowCacheLayer:NO];    
}

- (void)setDrawEnabled:(BOOL)enabled
{
    self.userInteractionEnabled = enabled;
}


#pragma mark Gesture Handler



typedef enum {
    TouchTypeBegin = 0,
    TouchTypeMove = 1,
    TouchTypeEnd = 2,
}TouchType;


- (void)handleTouches:(NSSet *)touches withEvent:(UIEvent *)event type:(TouchType)type
{

    UITouch *touch  = [touches anyObject];
    
    CGPoint point = [touch locationInView:self];

    [self addPoint:point toDrawAction:_currentAction];
    
    Paint *paint = [_currentAction paint];
    
    if (type == TouchTypeBegin) {
        [self setStrokeColor:paint.color lineWidth:paint.width inContext:cacheContext];
        [self strokePaint:paint inContext:cacheContext clear:YES];
        [self setNeedsDisplayShowCacheLayer:YES];
    }else if(type == TouchTypeMove){
        [self strokePaint:paint inContext:cacheContext clear:YES];
        [self setNeedsDisplayShowCacheLayer:YES];
    }else{
        [self setStrokeColor:paint.color lineWidth:paint.width inContext:showContext];
        [self strokePaint:paint inContext:showContext clear:NO];
        [self setNeedsDisplayShowCacheLayer:NO];
    }

}



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

//    UITouch *touch = [touches anyObject];
//    _previousPoint1 = _previousPoint2 = _currentPoint = [touch locationInView:self];
    
    [self addNewPaint];

    [self handleTouches:touches withEvent:event type:TouchTypeBegin];
    
    if (self.delegate && [self.delegate
                            respondsToSelector:@selector(didStartedTouch:)]) {
            [self.delegate didStartedTouch:_currentAction.paint];
    }
    [self clearRedoStack];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    [self handleTouches:touches withEvent:event type:TouchTypeEnd];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDrawedPaint:)]) {
        [self.delegate didDrawedPaint:_currentAction.paint];
    }
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [self handleTouches:touches withEvent:event type:TouchTypeMove];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
}



#pragma mark Constructor & Destructor

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.lineColor = [DrawColor blackColor];
        self.lineWidth = DEFAULT_LINE_WIDTH;
        self.penType = Pencil;
        _drawActionList = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor whiteColor];
        _redoStack = [[PPStack alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    PPDebug(@"%@ dealloc", [self description]);
    PPRelease(_drawActionList);
    PPRelease(_lineColor);
    PPRelease(_redoStack);
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
        id obj = [_drawActionList lastObject];
        [_redoStack push:obj];
        [_drawActionList removeLastObject];
        [self show];
    }
}

- (BOOL)canRedo
{
    return ![_redoStack isEmpty];
}
- (void)redo
{
    if ([self canRedo]) {
        DrawAction *action = [_redoStack pop];
        if (action) {
            [self.drawActionList addObject:action];
            [self drawAction:action inContext:showContext];
            [self setNeedsDisplayShowCacheLayer:NO];
        }        
    }
}
- (void)clearRedoStack
{
    if (![_redoStack isEmpty]) {
        [_redoStack clear];
    }
}

- (void)showDraft:(MyPaint *)draft
{
    self.drawActionList = draft.drawActionList;
    [self show];
}

@end
