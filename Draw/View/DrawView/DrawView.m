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
    DrawColor *_bgColor;
    
    NSMutableSet *toucheSet;
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


- (void)synBGColor
{
    NSInteger count = [self.drawActionList count];
    for (NSInteger i = count - 1; i >= 0; -- i) {
        DrawAction *action = [self.drawActionList objectAtIndex:i];
        if ([action isChangeBackAction]) {
            self.bgColor = action.paint.color;
            return;
        }
    }
    self.bgColor = [DrawColor whiteColor];
}

- (DrawColor *)bgColor
{
    if (_bgColor == nil) {
        self.bgColor = [DrawColor whiteColor];
    }
    return _bgColor;
}

//- ()

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

- (void)addNewAction
{
    if (self.touchActionType == DRAW_ACTION_TYPE_DRAW) {
        Paint *currentPaint = [Paint paintWithWidth:self.lineWidth
                                              color:self.lineColor
                                            penType:_penType];
        _currentAction = [DrawAction actionWithType:DRAW_ACTION_TYPE_DRAW paint:currentPaint];
        [self.drawActionList addObject:_currentAction];
    }else if(self.touchActionType == DRAW_ACTION_TYPE_SHAPE){
        ShapeInfo *shape = [ShapeInfo shapeWithType:self.shapeType
                                            penType:_penType
                                              width:_lineWidth
                                              color:_lineColor];
        _currentAction = [DrawAction actionWithShpapeInfo:shape];
        [self.drawActionList addObject:_currentAction];
    }
}

- (void)addPoint:(CGPoint)point toDrawAction:(DrawAction *)drawAction
{
    if (drawAction) {
        [drawAction.paint addPoint:point];
    }
}


#pragma mark - paint action

- (void)clearScreen
{
    [self clearRedoStack];
    DrawAction *cleanAction = [DrawAction clearScreenAction];
    [self.drawActionList addObject:cleanAction];
    [osManager addDrawAction:cleanAction];
    [self drawDrawAction:cleanAction show:YES];
    self.bgColor = [DrawColor whiteColor];
}
- (void)changeBackWithColor:(DrawColor *)color
{
    [self clearRedoStack];
    DrawAction *changBackAction = [DrawAction changeBackgroundActionWithColor:color];
    [self.drawActionList addObject:changBackAction];
    [self drawDrawAction:changBackAction show:YES];
    self.bgColor = color;
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
    for (UITouch *touche in touches) {
        [toucheSet addObject:touche];
    }
    NSInteger count = [toucheSet count];
    if (type == TouchTypeEnd) {
        [toucheSet removeAllObjects];
    }
    if (count != 1) {
        PPDebug(@"<handleDrawTouches> touch tapCount = %d, type = %d", count, type);
        return;
        
    }
    UITouch *touch  = [touches anyObject];
    CGPoint point = [touch locationInView:self];

    [self addPoint:point toDrawAction:_currentAction];
    
    Paint *paint = [_currentAction paint];

    if (type == TouchTypeBegin) {
        [self drawDrawAction:_currentAction show:NO];
//        [osManager setStrokeColor:paint.color width:paint.width];
        [osManager updateDrawPenWithPaint:paint];
        [osManager updateLastPaint:paint];
        [self setNeedsDisplay];

    }else if(type == TouchTypeMove){
        [self drawPaint:paint show:YES];
    }else{
        [paint finishAddPoint];
        [self drawPaint:paint show:YES];
    }
}

- (void)handleShapeTouches:(NSSet *)touches withEvent:(UIEvent *)event type:(TouchType)type
{
    for (UITouch *touche in touches) {
        [toucheSet addObject:touche];
    }
    NSInteger count = [toucheSet count];
    if (type == TouchTypeEnd) {
        [toucheSet removeAllObjects];
    }
    if (count != 1) {
        PPDebug(@"<handleShapeTouches> touch tapCount = %d, type = %d", count, type);
        return;
        
    }
    UITouch *touch  = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    ShapeInfo *shape = [_currentAction shapeInfo];
    
    if (type == TouchTypeBegin) {
        [shape setStartPoint:point];
        [shape setEndPoint:point];
        [osManager addDrawAction:_currentAction];
        [self setNeedsDisplay];
    }else{
        [shape setEndPoint:point];
        [osManager updateLastAction:_currentAction];
        [self setNeedsDisplay];
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

    if ([touch tapCount] != 1) {
        PPDebug(@"<handleDrawTouches> touch tapCount = %d, type = %d", [touch tapCount], type);
        return;
    }
    
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
    }else{
        [self addNewAction];
        if(self.touchActionType == TouchActionTypeShape){
            [self handleShapeTouches:touches withEvent:event type:TouchTypeBegin];
        }else if(self.touchActionType == TouchActionTypeDraw){
            [self handleDrawTouches:touches withEvent:event type:TouchTypeBegin];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(drawView:didStartTouchWithAction:)]) {
            [self.delegate drawView:self didStartTouchWithAction:_currentAction];
        }
        [self clearRedoStack];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    if (self.touchActionType == TouchActionTypeGetColor) {
        [self handleGetColorTouches:touches withEvent:event type:TouchTypeEnd];
    }else{
        if(self.touchActionType == TouchActionTypeShape){
            [self handleShapeTouches:touches withEvent:event type:TouchTypeEnd];
        }else if(self.touchActionType == TouchActionTypeDraw){
            [self handleDrawTouches:touches withEvent:event type:TouchTypeEnd];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(drawView:didFinishDrawAction:)]) {
            [self.delegate drawView:self didFinishDrawAction:_currentAction];
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.touchActionType == TouchActionTypeGetColor) {
        [self handleGetColorTouches:touches withEvent:event type:TouchTypeMove];
    }else{
        if(self.touchActionType == TouchActionTypeShape){
            [self handleShapeTouches:touches withEvent:event type:TouchTypeMove];
        }else if(self.touchActionType == TouchActionTypeDraw){
            [self handleDrawTouches:touches withEvent:event type:TouchTypeMove];
        }
    }
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
        
        osManager = [[OffscreenManager drawViewOffscreenManager] retain];
        toucheSet = [[NSMutableSet setWithCapacity:4] retain];
        [self setMultipleTouchEnabled:YES];
    }
    
    return self;
}

- (void)dealloc
{
    PPRelease(_drawActionList);
    PPRelease(_lineColor);
    PPRelease(_redoStack);
    PPRelease(_bgColor);
    PPRelease(toucheSet);
    [super dealloc];
}



#pragma mark - Revoke
- (void)showForRevoke:(DrawAction*)lastAction finishBlock:(dispatch_block_t)finishiBlock
{
    NSUInteger count = [self.drawActionList count];
    NSUInteger index = [osManager closestIndexWithActionIndex:count];
    Offscreen *os = [osManager offScreenForActionIndex:index];
    [os clear];
//    [osManager removeContentAfterIndex:count];
    for (; index < count; ++ index) {
        DrawAction *action = [self.drawActionList objectAtIndex:index];
        [os drawAction:action clear:NO];
    }
    [self setNeedsDisplay];

    [self synBGColor];
    
    // call block
    if (finishiBlock != NULL){
        finishiBlock();
    }

}

- (BOOL)canRevoke
{
    return [_drawActionList count] > 0 && [osManager canUndo];
}


- (void)revoke:(dispatch_block_t)finishBlock
{
    
    if ([self canRevoke]) {
        DrawAction *obj = [_drawActionList lastObject];
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
            [osManager addDrawAction:action];
            [self setNeedsDisplay];
            if ([action isChangeBackAction]) {
                self.bgColor = [action.paint color];
            }
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
    [self synBGColor];
    [self show];
}

//- (void)setTouchActionType:(TouchActionType)touchActionType
//{
//    _touchActionType = touchActionType;
//}

- (void)setLineWidth:(CGFloat)lineWidth
{
    _lineWidth = lineWidth;
//    if ([_currentAction isShapeAction]) {
//        _currentAction.shapeInfo.width = lineWidth;
//        [osManager updateLastAction:_currentAction];
//        [self setNeedsDisplay];
//    }
}

@end
