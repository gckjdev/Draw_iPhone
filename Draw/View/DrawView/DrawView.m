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

#pragma mark - draw view implementation

@interface DrawView()
{
    PPStack *_redoStack;
    CGPoint _currentPoint;
    DrawColor *_bgColor;
    
    

}
#pragma mark Private Helper function
- (void)clearRedoStack;
@property(nonatomic, retain)TouchHandler *touchHandler;

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



- (CGPoint)pointForTouches:(NSSet *)touches
{
    UITouch *touch = [touches anyObject];
    return [touch locationInView:self];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
//    PPDebug(@"=========<touchesBegan>======= touch count = %d",[touches count]);
    self.touchHandler = [TouchHandler touchHandlerWithTouchActionType:self.touchActionType];
    [self.touchHandler setDrawView:self];
    [self.touchHandler setOsManager:osManager];
    if (self.touchActionType == TouchActionTypeGetColor) {
        [(StrawTouchHandler *)self.touchHandler setStrawDelegate:self.strawDelegate];
    }
    [self.touchHandler handlePoint:[self pointForTouches:touches] forTouchState:TouchStateBegin];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];

    [self.touchHandler handlePoint:[self pointForTouches:touches] forTouchState:TouchStateMove];

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    PPDebug(@"*********<touchesEnd>********* touch count = %d",[touches count]);
    [self.touchHandler handlePoint:[self pointForTouches:touches] forTouchState:TouchStateEnd];

}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
//    PPDebug(@"#########<touchesCancel>######### touch count = %d",[touches count]);
    [self.touchHandler handlePoint:[self pointForTouches:touches] forTouchState:TouchStateCancel];
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
        [self setMultipleTouchEnabled:YES];
        _gestureRecognizerManager.delegate = self;
    }
    
    return self;
}

- (void)dealloc
{
    PPRelease(_drawActionList);
    PPRelease(_lineColor);
    PPRelease(_redoStack);
    PPRelease(_bgColor);
    PPRelease(_touchHandler);
    [super dealloc];
}



#pragma mark - Revoke
- (void)showForRevoke:(DrawAction*)lastAction finishBlock:(dispatch_block_t)finishiBlock
{
//    [self printOSInfoWithTag:@"<Revoke> Before"];
    
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
//    [self printOSInfoWithTag:@"<Revoke> after"];
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
//            [self printOSInfoWithTag:@"<Redo> before"];
            [self.drawActionList addObject:action];
            [osManager addDrawAction:action];
            [self setNeedsDisplay];
//            [self printOSInfoWithTag:@"<Redo> after"];
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
    if (draft.drawBg) {
        [self setDrawBg: draft.drawBg];
    }
    [self synBGColor];
    [self show];
}


- (void)printOSInfoWithTag:(NSString *)tag
{
    PPDebug(tag);
    PPDebug(@"Action list count = %d",[_drawActionList count]);
    [osManager printOSInfo];
}


- (void)gestureRecognizerManager:(GestureRecognizerManager *)manager
                 didGestureBegan:(UIGestureRecognizer *)gestureRecognizer
{
    PPDebug(@"<didGestureBegan>");
    [self.touchHandler handleFailTouch];
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        PPDebug(@"Double tap Began, undo a paint");
        [self revoke:NULL];
    }
    
}
@end
