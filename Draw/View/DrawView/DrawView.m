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
#import "StrawView.h"
#import "ConfigManager.h"

#pragma mark - draw view implementation

@interface DrawView()
{
    PPStack *_redoStack;
    CGPoint _currentPoint;
    StrawView *_strawView;
    CGContextRef _tempBitmapContext;
    
}
#pragma mark Private Helper function
- (void)clearRedoStack;

@end


#define LINE_DEFAULT_WIDTH ([ConfigManager defaultPenWidth])

@implementation DrawView

@synthesize lineColor = _lineColor;
@synthesize lineWidth = _lineWidth;
@synthesize delegate = _delegate;
@synthesize penType = _penType;


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

#pragma mark - paint action

- (void)clearScreen
{
    [self clearRedoStack];
    DrawAction *cleanAction = [DrawAction clearScreenAction];
    [self.drawActionList addObject:cleanAction];
    [self drawAction1:cleanAction inContext:showContext];
    [self setNeedsDisplayInRect:self.bounds showCacheLayer:NO];
    
}
- (void)changeBackWithColor:(DrawColor *)color
{
    [self clearRedoStack];
    DrawAction *cleanAction = [DrawAction changeBackgroundActionWithColor:color];
    [self.drawActionList addObject:cleanAction];
    [self drawAction1:cleanAction inContext:showContext];
    [self setNeedsDisplayInRect:self.bounds showCacheLayer:NO];    
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


- (void)handleDrawTouches:(NSSet *)touches withEvent:(UIEvent *)event type:(TouchType)type
{

    UITouch *touch  = [touches anyObject];    
    CGPoint point = [touch locationInView:self];

    [self addPoint:point toDrawAction:_currentAction];
    
    Paint *paint = [_currentAction paint];
    
    CGRect drawBox; //= [paint rectForPath];
    if (type == TouchTypeBegin) {
        [self setStrokeColor:paint.color lineWidth:paint.width inContext:cacheContext];
        drawBox = [self strokePaint1:paint inContext:cacheContext clear:YES];
        [self setNeedsDisplayInRect:drawBox showCacheLayer:YES];
    }else if(type == TouchTypeMove){
        drawBox = [self strokePaint1:paint inContext:cacheContext clear:YES];
        [self setNeedsDisplayInRect:drawBox showCacheLayer:YES];
    }else{        
        [paint finishAddPoint];
        drawBox = [self strokePaint1:paint inContext:cacheContext clear:YES];
        [self setNeedsDisplayInRect:drawBox showCacheLayer:YES];
        
        [self setStrokeColor:paint.color lineWidth:paint.width inContext:showContext];
        drawBox = [self strokePaint1:paint inContext:showContext clear:NO];
        [self setNeedsDisplayInRect:drawBox showCacheLayer:NO];
    }
}

- (DrawColor *)colorAtPoint:(CGPoint)point inContext:(CGContextRef)context
{
    unsigned char* data = CGBitmapContextGetData (context);
    DrawColor *color = nil;
    CGFloat w = CGRectGetWidth(self.bounds);
    if (data != NULL) {
        //offset locates the pixel in the data from x,y.
        //4 for 4 bytes of data per pixel, w is width of one row of data.
        int offset = 4*((w*round(point.y))+round(point.x));

        int red = data[offset++];
        int green = data[offset++];
        int blue = data[offset++];
        int alpha =  data[offset++];
        
//        PPDebug(@"offset:%d, alpha = %d, red = %d, green = %d, blue = %d",offset, alpha, red, green, blue);
        color = [DrawColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
    }
    // Free image data memory for the context
    
//    if (data) { free(data); }
    return color;
}

- (void)handleGetColorTouches:(NSSet *)touches withEvent:(UIEvent *)event type:(TouchType)type
{
    UITouch *touch  = [touches anyObject];
    CGPoint point = [touch locationInView:self];

    switch (type) {
        case TouchTypeBegin:
        {
            //new and show color view and show it in the super view
            _tempBitmapContext = [self createBitmapContext];
            DrawColor *color = [self colorAtPoint:point inContext:_tempBitmapContext];
            _strawView = [StrawView strawViewWithColor:color.color];
            [self addSubview:_strawView];
            _strawView.center = point;
        }
            break;
        case TouchTypeMove:
            //move the view
        {
            DrawColor *color = [self colorAtPoint:point inContext:_tempBitmapContext];
            [_strawView setColor:color.color];
            _strawView.center = point;
            break;
        }
        case TouchTypeEnd:
        {
            //remove the show color view
            [_strawView removeFromSuperview];
            _strawView = nil;
            DrawColor *color = [self colorAtPoint:point inContext:_tempBitmapContext];
//            color.alpha = 1.0;
            if (_strawDelegate && [_strawDelegate respondsToSelector:@selector(didStrawGetColor:)]) {
                [_strawDelegate didStrawGetColor:color];
            }
            CGContextRelease(_tempBitmapContext);
            _tempBitmapContext = NULL;
            break;
        }
        default:
            break;
    }
    //set the view with the color
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    if (self.touchActionType == TouchActionTypeGetColor) {
        [self handleGetColorTouches:touches withEvent:event type:TouchTypeBegin];
        return;
    }
    [self addNewPaint];

    [self handleDrawTouches:touches withEvent:event type:TouchTypeBegin];
    
    if (self.delegate && [self.delegate
                            respondsToSelector:@selector(didStartedTouch:)]) {
            [self.delegate didStartedTouch:_currentAction.paint];
    }
    [self clearRedoStack];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    if (self.touchActionType == TouchActionTypeGetColor) {
        [self handleGetColorTouches:touches withEvent:event type:TouchTypeEnd];
        return;
    }

    [self handleDrawTouches:touches withEvent:event type:TouchTypeEnd];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didDrawedPaint:)]) {
        [self.delegate didDrawedPaint:_currentAction.paint];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.touchActionType == TouchActionTypeGetColor) {
        [self handleGetColorTouches:touches withEvent:event type:TouchTypeMove];
        return;
    }

    [self handleDrawTouches:touches withEvent:event type:TouchTypeMove];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
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
        self.lineWidth = LINE_DEFAULT_WIDTH;
        self.penType = Pencil;
        _drawActionList = [[NSMutableArray alloc] init];
        self.backgroundColor = [UIColor whiteColor];
        _redoStack = [[PPStack alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    PPRelease(_drawActionList);
    PPRelease(_lineColor);
    PPRelease(_redoStack);
    [super dealloc];
}



#pragma mark - Revoke
- (void)showForRevoke:(DrawAction*)lastAction finishBlock:(dispatch_block_t)finishiBlock
{
    // draw on show context, this takes a lot of performance if the draw
    CGContextClearRect(showContext, self.bounds);
    for (DrawAction *action in self.drawActionList) {
        [self drawAction1:action inContext:showContext];
    }
    
    // refresh screen
    CGRect rect = self.bounds;
    if (lastAction.paint != nil){
        rect = [DrawUtils rectForPath:lastAction.paint.path withWidth:lastAction.paint.width bounds:self.bounds];
    }
    [self setNeedsDisplayInRect:rect showCacheLayer:NO];
    
    // call block
    if (finishiBlock != NULL){
        finishiBlock();
    }
    
}

- (BOOL)canRevoke
{
    return [_drawActionList count] > 0;
}

- (void)revoke:(dispatch_block_t)finishBlock
{
    if ([self canRevoke]) {
        id obj = [_drawActionList lastObject];
        [_redoStack push:obj];
        [_drawActionList removeLastObject];
        [self showForRevoke:obj finishBlock:finishBlock];
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
            CGRect rect = [self drawAction1:action inContext:showContext];
            [self setNeedsDisplayInRect:rect showCacheLayer:NO];
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
