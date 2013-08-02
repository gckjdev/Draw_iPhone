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
#import "PathClipTouchHandler.h"
#import "ShapeClipTouchHandler.h"
#import "PolygonClipTouchHandler.h"

#import "DrawUtils.h"
#import "DrawAction.h"
#import "DrawHolderView.h"
#import "GradientAction.h"

#import "DrawLayer.h"
#define MAX_POINT_COUNT 5

#pragma mark - draw view implementation

@interface DrawView()
{
    PPStack *_redoStack;
    CGPoint _currentPoint;
    NSInteger _pointCount;
}
#pragma mark Private Helper function
- (void)clearRedoStack;
@property(nonatomic, retain)TouchHandler *touchHandler;
@property(nonatomic, retain)UITouch *currentTouch;

@end


#define LINE_DEFAULT_WIDTH ([ConfigManager defaultPenWidth])

@implementation DrawView

@synthesize delegate = _delegate;


//- (void)setDrawActionList:(NSMutableArray *)drawActionList
//{
//    [super setDrawActionList:drawActionList];
//}


- (void)callbackFinishDelegateWithAction:(DrawAction *)action
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawView:didFinishDrawAction:)]) {
        [self.delegate drawView:self didFinishDrawAction:action];
    }
}


#pragma mark - paint action

- (void)setDrawEnabled:(BOOL)enabled
{
    self.userInteractionEnabled = enabled;
}

- (void)addDrawAction:(DrawAction *)drawAction show:(BOOL)show
{
    if (drawAction) {
        [self.drawActionList addObject:drawAction];
        [super addDrawAction:drawAction show:show];
        [self clearRedoStack];
        if (![drawAction isPaintAction]) {
            [self callbackFinishDelegateWithAction:drawAction];
        }
    }
}

//remove the last action force to refresh
- (void)cancelLastAction
{
    if ([self.drawActionList count] > 0) {
        [self.drawActionList removeLastObject];
        [super cancelLastAction];
    }
}

#pragma mark Gesture Handler



- (CGPoint)pointForTouches:(NSSet *)touches
{
    if (self.currentTouch == nil) {
        self.currentTouch = [touches anyObject];
    }
    CGPoint point = [self.currentTouch locationInView:self];
    return point;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(drawView:didStartTouchWithAction:)]) {
        [self.delegate drawView:self didStartTouchWithAction:nil];
    }
    
    if (self.currentTouch == nil) {
        
        PPDebug(@"SET touch handler and current touch");
        
        [_gestureRecognizerManager setCapture:YES];
        
        DrawInfo *drawInfo = [self drawInfo];
        
        if (drawInfo.touchType != TouchActionTypeClipPolygon ||
            ![self.touchHandler isKindOfClass:[PolygonClipTouchHandler class]]) {
            
            self.touchHandler = [TouchHandler touchHandlerWithTouchActionType:drawInfo.touchType];
            
            if ([self.touchHandler isKindOfClass:[PolygonClipTouchHandler class]]) {
                [(PolygonClipTouchHandler *)self.touchHandler setDelegate:self];
            }
            
            [self.touchHandler setDrawView:self];
            if (drawInfo.touchType == TouchActionTypeGetColor) {
                [(StrawTouchHandler *)self.touchHandler setStrawDelegate:self.strawDelegate];
            }
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
        if ([[self drawInfo] touchType] != TouchActionTypeClipPolygon) {
            self.touchHandler = nil;
        }
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
        
        self.backgroundColor = [UIColor whiteColor];
        
        _drawActionList = [[NSMutableArray alloc] init];
        _redoStack = [[PPStack alloc] init];
        
        dlManager = [[DrawLayerManager alloc] initWithView:self];
        
        
        
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

    for (DrawLayer *layer in dlManager.layers) {
        layer.frame = rect;
    }
    
    [(DrawHolderView *)self.superview updateContentScale];
}

- (void)dealloc
{
    PPRelease(_drawActionList);
    PPRelease(_redoStack);
    PPRelease(_touchHandler);
    PPRelease(_currentTouch);
    [super dealloc];
}



#pragma mark - Revoke

- (BOOL)undo
{
    if ([self.drawActionList count] == 0) {
        return NO;
    }
    DrawAction *action = [dlManager undoDrawAction:[_drawActionList lastObject]];
    if (action) {
        [_redoStack push:action];
        [_drawActionList removeLastObject];
        return YES;
    }
    return NO;
}

- (BOOL)redo
{
    if ([_redoStack isEmpty]) {
        return NO;
    }
    DrawAction *action = [dlManager redoDrawAction:[_redoStack top]];
    if (action) {
        [_drawActionList addObject:action];
        [_redoStack pop];
        return YES;
    }
    return NO;
}
- (void)clearRedoStack
{
    if (![_redoStack isEmpty]) {
        [_redoStack clear];
    }
}

- (void)showDraft:(MyPaint *)draft
{
    [dlManager updateLayers:draft.layers];
    self.drawActionList = draft.drawActionList;
    [self changeRect:CGRectFromCGSize(draft.canvasSize)];
    [self show];
}

- (DrawAction *)lastAction
{
    return [[self currentLayer] lastAction];
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

#pragma mark -- Polygon Delegate

- (void) didPolygonClipTouchHandler:(PolygonClipTouchHandler *)handler finishAddPointsToAction:(ClipAction *)action
{
    self.touchHandler = nil;
    PPDebug(@"<didPolygonClipTouchHandler> finish!!!");
    PPViewController *vc = (id)[self theViewController];
    [vc popupHappyMessage:NSLS(@"kPolygonJoined") title:nil];
}


///New Methods

- (DrawInfo *)drawInfo{
    return [[self currentLayer] drawInfo];
}


- (void)changeAlpha:(CGFloat)alpha
{
    self.drawInfo.alpha = alpha;
    self.drawInfo.penColor = [DrawColor colorWithColor:self.drawInfo.penColor];
    self.drawInfo.penColor.alpha = alpha;
}
- (void)changePenWidth:(CGFloat)width
{
    self.drawInfo.penWidth = width;
}
- (void)changePenType:(ItemType)penType
{
    self.drawInfo.penType = penType;
}
- (void)changeShapeType:(ShapeType)shapeType
{
    self.drawInfo.shapeType = shapeType;
}
- (void)changePenColor:(DrawColor *)penColor
{
    self.drawInfo.penColor = [DrawColor colorWithColor:penColor];
    self.drawInfo.penColor.alpha = self.alpha;
}
- (void)changeShadow:(Shadow *)shadow
{
    self.drawInfo.shadow = shadow;
}

@end
