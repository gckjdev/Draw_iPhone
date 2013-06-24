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

#import "StrawTouchHandler.h"
#import "DrawTouchHandler.h"
#import "ShapeTouchHandler.h"
#import "DrawUtils.h"
#import "DrawAction.h"
#import "DrawHolderView.h"


#define MAX_POINT_COUNT 5

#pragma mark - draw view implementation

@interface DrawView()
{
    PPStack *_redoStack;
    CGPoint _currentPoint;
    DrawColor *_bgColor;
    NSInteger _pointCount;
//    NSInteger

}
#pragma mark Private Helper function
- (void)clearRedoStack;
@property(nonatomic, retain)TouchHandler *touchHandler;
@property(nonatomic, retain)UITouch *currentTouch;

@end


#define LINE_DEFAULT_WIDTH ([ConfigManager defaultPenWidth])

@implementation DrawView

@synthesize lineColor = _lineColor;
@synthesize lineWidth = _lineWidth;
@synthesize delegate = _delegate;
@synthesize penType = _penType;


- (void)setDrawActionList:(NSMutableArray *)drawActionList
{
    [super setDrawActionList:drawActionList];
    [cdManager setDrawActionList:drawActionList];
}


- (void)callbackFinishDelegateWithAction:(DrawAction *)action
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawView:didFinishDrawAction:)]) {
        [self.delegate drawView:self didFinishDrawAction:action];
    }
}

- (void)synBGColor
{
    NSInteger count = [self.drawActionList count];
    for (NSInteger i = count - 1; i >= 0; -- i) {
        DrawAction *action = [self.drawActionList objectAtIndex:i];
        if ([action isKindOfClass:[ChangeBackAction class]]) {
            self.bgColor = [(ChangeBackAction *)action color];
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


#pragma mark - paint action

- (void)clearScreen
{
    [self clearRedoStack];
    DrawAction *cleanAction = [[[CleanAction alloc] init] autorelease];
    [self.drawActionList addObject:cleanAction];
//    [osManager addDrawAction:cleanAction];
    [cdManager addDrawAction:cleanAction];
    [self drawDrawAction:cleanAction show:YES];
    self.bgColor = [DrawColor whiteColor];
}
- (ChangeBackAction *)changeBackWithColor:(DrawColor *)color
{
    [self clearRedoStack];
    ChangeBackAction *changBackAction = [[[ChangeBackAction alloc] initWithColor:color] autorelease];
    [self.drawActionList addObject:changBackAction];
    [self drawDrawAction:changBackAction show:YES];
    self.bgColor = color;
    [self callbackFinishDelegateWithAction:changBackAction];
    return changBackAction;
}
- (ChangeBGImageAction *)changeBGImageWithDrawBG:(PBDrawBg *)drawBg
{
    [self clearRedoStack];
    
    ChangeBGImageAction *changBG = [[[ChangeBGImageAction alloc] initWithDrawBg:drawBg] autorelease];
    [self addDrawAction:changBG];
    [self drawDrawAction:changBG show:YES];
                                    
    self.bgColor = [DrawColor whiteColor];
    [self callbackFinishDelegateWithAction:changBG];
    return changBG;
}

- (void)setDrawEnabled:(BOOL)enabled
{
    self.userInteractionEnabled = enabled;
}



#pragma mark Gesture Handler



- (CGPoint)pointForTouches:(NSSet *)touches
{
    if (self.currentTouch == nil) {
        self.currentTouch = [touches anyObject];
    }
    CGPoint point = [self.currentTouch locationInView:self];
//    PPDebug(@"<pointForTouches> point = %@",NSStringFromCGPoint(point));
    return point;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawView:didStartTouchWithAction:)]) {
        [self.delegate drawView:self didStartTouchWithAction:nil];
    }
    
//    PPDebug(@"=========<touchesBegan>======= touch count = %d",[touches count]);
    
    if (self.currentTouch == nil) {
        
        PPDebug(@"SET touch handler and current touch");
        
        [_gestureRecognizerManager setCapture:YES];
        self.touchHandler = [TouchHandler touchHandlerWithTouchActionType:self.touchActionType];
        [self.touchHandler setDrawView:self];
//        [self.touchHandler setOsManager:osManager];
        [self.touchHandler setCdManager:cdManager];
        if (self.touchActionType == TouchActionTypeGetColor) {
            [(StrawTouchHandler *)self.touchHandler setStrawDelegate:self.strawDelegate];
        }
        [self.touchHandler handlePoint:[self pointForTouches:touches] forTouchState:TouchStateBegin];
        _pointCount = 1;
    }else{
        _pointCount ++;
        UITouch *otherTouch = nil;
        for (UITouch *touch in touches) {
            if (touch != self.currentTouch) {
                otherTouch = touch;
                break;
            }
        }
        if (otherTouch) {
            if (_pointCount >= MAX_POINT_COUNT && ![self.touchHandler handleFailed] && _gestureRecognizerManager.capture) {
                _gestureRecognizerManager.capture = NO;
                PPDebug(@"point count > %d stop to recognizer miltiple touch gestures", MAX_POINT_COUNT);
            }

        }
        
    }
    
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    _pointCount ++;
    [super touchesMoved:touches withEvent:event];
    [self.touchHandler handlePoint:[self pointForTouches:touches] forTouchState:TouchStateMove];

}

- (void)finishTouches:(NSSet *)touches withTouchState:(TouchState)state
{
    if ([touches containsObject:self.currentTouch]) {
        DrawAction *drawAction = nil;
        if ([self.touchHandler respondsToSelector:@selector(drawAction)]){
            drawAction = [self.touchHandler performSelector:@selector(drawAction)];
        }
        
        [self.touchHandler handlePoint:[self pointForTouches:touches] forTouchState:state];
        
        [self callbackFinishDelegateWithAction:drawAction];
        
        PPDebug(@"RESET touch handler and current touch");
        self.touchHandler = nil;
        self.currentTouch = nil;
        _pointCount = 0;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    PPDebug(@"**********<touchesEND>********** touch count = %d",[touches count]);    
    [self finishTouches:touches withTouchState:TouchStateEnd];
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
//    PPDebug(@"#########<touchesCancel>######### touch count = %d",[touches count]);
    [self finishTouches:touches withTouchState:TouchStateCancel];
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
        self.backgroundColor = [UIColor whiteColor];
        
        _drawActionList = [[NSMutableArray alloc] init];
        _redoStack = [[PPStack alloc] init];
        
//        osManager = [[OffscreenManager drawViewOffscreenManagerWithRect:self.bounds] retain];
        cdManager = [[CacheDrawManager managerWithRect:self.bounds] retain];
        cdManager.drawActionList = self.drawActionList;
        [self setMultipleTouchEnabled:YES];
        _gestureRecognizerManager.delegate = self;
    }
    
    return self;
}

- (void)changeRect:(CGRect)rect
{
    if (CGRectEqualToRect(rect, self.bounds)) {
        return;
    }
    
    self.transform = CGAffineTransformIdentity;
    self.bounds = rect;
    self.frame = rect;
    [cdManager release];
    cdManager = [[CacheDrawManager managerWithRect:self.bounds] retain];
    cdManager.drawActionList = self.drawActionList;
    [cdManager setShowGrid:_grid];
//    [osManager release];
//    osManager = [[OffscreenManager drawViewOffscreenManagerWithRect:self.bounds] retain];
//    if (_grid) {
//        [osManager setShowGridOffscreen:YES];
//    }
    [(DrawHolderView *)self.superview updateContentScale];
    [self setNeedsDisplay];
}

- (void)setGrid:(BOOL)grid
{
    _grid = grid;
//    [osManager setShowGridOffscreen:grid];
    [cdManager setShowGrid:grid];
    [self setNeedsDisplay];
}

- (void)dealloc
{
    PPRelease(_drawActionList);
    PPRelease(_lineColor);
    PPRelease(_redoStack);
    PPRelease(_bgColor);
    PPRelease(_touchHandler);
    PPRelease(_currentTouch);
    [super dealloc];
}



#pragma mark - Revoke
- (void)showForRevoke:(DrawAction*)lastAction finishBlock:(dispatch_block_t)finishiBlock
{
//    [self printOSInfoWithTag:@"<Revoke> Before"];
    
/*
    NSUInteger count = [self.drawActionList count];
    NSUInteger index = [osManager closestIndexWithActionIndex:count];
    Offscreen *os = [osManager offScreenForActionIndex:index];
    [os clear];
//    [osManager removeContentAfterIndex:count];
    for (; index < count; ++ index) {
        DrawAction *action = [self.drawActionList objectAtIndex:index];
        [os drawAction:action clear:NO];
    }
 */
    [cdManager undo];
    [self setNeedsDisplay];

    [self synBGColor];
    
    // call block
    if (finishiBlock != NULL){
        finishiBlock();
    }
//    [self printOSInfoWithTag:@"<Revoke> after"];
}

- (BOOL)canRevoke
{
//    return [_drawActionList count] > 0 && [osManager canUndo];
    return [_drawActionList count] > 0 && [cdManager canUndo];
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


- (void)undo
{
    [self revoke:NULL];
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
//            [self printOSInfoWithTag:@"<Redo> before"];
            [self.drawActionList addObject:action];
//            [osManager addDrawAction:action];
            [cdManager addDrawAction:action];
            [self setNeedsDisplay];
//            [self printOSInfoWithTag:@"<Redo> after"];
            if ([action isKindOfClass:[ChangeBackAction class]]) {
                self.bgColor = [(ChangeBackAction *)action color];
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
    [self changeRect:CGRectFromCGSize(draft.canvasSize)];
    [self synBGColor];
    [self show];
}



- (void)printOSInfoWithTag:(NSString *)tag
{
    PPDebug(tag);
    PPDebug(@"Action list count = %d",[_drawActionList count]);
//    [osManager printOSInfo];
}


- (UIImage *)createImage
{
    if ([cdManager showGrid]) {
        [cdManager setShowGrid:NO];
    }
    UIImage *image = [super createImage];
    return image;
}

- (NSInteger)totalActionCount
{
    return [self actionCount] + [_redoStack size];
}

- (NSInteger)actionCount
{
    return [[self drawActionList] count];
}
- (void)gestureRecognizerManager:(GestureRecognizerManager *)manager
                 didGestureBegan:(UIGestureRecognizer *)gestureRecognizer
{
    PPDebug(@"gestureRecognizer = %@ <didGestureBegan>", [gestureRecognizer class]);
    if (![gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        [self.touchHandler handleFailTouch];
        self.touchHandler = nil;
    }
}

- (void)gestureRecognizerManager:(GestureRecognizerManager *)manager
                   didGestureEnd:(UIGestureRecognizer *)gestureRecognizer
{
    PPDebug(@"<didGestureEnd>");
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        [self.touchHandler handleFailTouch];
        self.touchHandler = nil;
    }
}
@end
