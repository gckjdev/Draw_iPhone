//
//  GestureRecognizerManager.m
//  SourceProfile
//
//  Created by gamy on 13-3-8.
//  Copyright (c) 2013年 ict. All rights reserved.
//

#import "GestureRecognizerManager.h"
#import "ArcGestureRecognizer.h"

@interface GestureRecognizerManager()
{
    CGFloat lastScale;
    CGFloat lastRadian;
    BOOL lastDirection;
    NSMutableSet *grSet;
//    BOOL notScale;
}

@end

@implementation GestureRecognizerManager

- (id)init
{
    self = [super init];
    if (self) {
        self.capture = YES;
        grSet = [[NSMutableSet alloc] initWithCapacity:5];
    }
    return self;
}

- (void)dealloc
{
    PPRelease(grSet);
    [super dealloc];
}

- (void)setCapture:(BOOL)capture
{
    _capture = capture;
    UIGestureRecognizerState state = UIGestureRecognizerStatePossible;
    if (!capture) {
        state = UIGestureRecognizerStateFailed;
    }
    for (UIGestureRecognizer *gr in grSet) {
        gr.state = state;
    }

}

- (BOOL)canMoveView:(UIView *)view
{
    return !CGAffineTransformEqualToTransform(view.transform, CGAffineTransformIdentity);
}

- (UIPanGestureRecognizer *)addPanGestureReconizerToView:(UIView *)view
{
    view.userInteractionEnabled = YES;  // Enable user interaction
    view.multipleTouchEnabled = YES;
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                 action:@selector(handlePanGesture:)];
    [panGesture setMaximumNumberOfTouches:2];
    [panGesture setMinimumNumberOfTouches:2];
    [panGesture setDelegate:self];
    [view addGestureRecognizer:panGesture];
    [grSet addObject:panGesture];
    return [panGesture autorelease];
}

- (UIPinchGestureRecognizer *)addPinchGestureReconizerToView:(UIView *)view
{
    view.userInteractionEnabled = YES;  // Enable user interaction
    view.multipleTouchEnabled = YES;

    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [view addGestureRecognizer:pinchGesture];
    [grSet addObject:pinchGesture];
    return [pinchGesture autorelease];
}


- (UITapGestureRecognizer *)addDoubleTapGestureReconizerToView:(UIView *)view
{
    view.userInteractionEnabled = YES;  // Enable user interaction
    view.multipleTouchEnabled = YES;
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [doubleTap setNumberOfTouchesRequired:2];
    [view addGestureRecognizer:doubleTap];
    [grSet addObject:doubleTap];
    return [doubleTap autorelease];

}

- (ArcGestureRecognizer *)addArcGestureRecognizerToView:(UIView *)view
{
    view.userInteractionEnabled = YES;  // Enable user interaction
    view.multipleTouchEnabled = YES;
    ArcGestureRecognizer *arcGesture = [[ArcGestureRecognizer alloc] initWithTarget:self action:@selector(handleArcGesture:)];
    [view addGestureRecognizer:arcGesture];
    [grSet addObject:arcGesture];
    return [arcGesture autorelease];
}

#define REDO_UNDO_RADIAN 1

- (void)handleArcGesture:(ArcGestureRecognizer *)gestureRecognizer
{
    [self stateCallBack:gestureRecognizer];
    if([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        PPDebug(@"=======================<handleArcGesture> began!!!=======================");
        lastRadian = 0;
    }
    if ([gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        BOOL direction = [gestureRecognizer direction];
//        PPDebug(@"<DIRECTION> %@", direction ? @">>>>>>>>>" : @"<<<<<<<<<<<");
        if (direction != lastDirection) {
            lastDirection = direction;
            lastRadian = 0;
        }else{
            if (gestureRecognizer.radian - lastRadian >= REDO_UNDO_RADIAN) {
                lastRadian = gestureRecognizer.radian;
                PPDebug(@"Radian = %f",gestureRecognizer.radian);
                SEL selector = NULL;
                if (direction) {
                    PPDebug(@">>>>> clock wise redo >>>>>");
                    selector = @selector(redo);
                }else{
                    selector = @selector(undo);
                    PPDebug(@"<<<<<< anti clock wise undo <<<<<");
                }
                if ([gestureRecognizer.view respondsToSelector:selector]) {
                    [gestureRecognizer.view performSelector:selector];
                }
            }
        }
        
//        NSString *dir = [gestureRecognizer direction] ? @">>>>>>>>>>>>>>" : @"<<<<<<<<<<<<<";
//        PPDebug(@"direction = %@, radian = %f", dir, gestureRecognizer.radian);
    }else if([gestureRecognizer state] == UIGestureRecognizerStateEnded ||
             [gestureRecognizer state] == UIGestureRecognizerStateCancelled){
        
    }else if(gestureRecognizer.state == UIGestureRecognizerStateFailed){
        PPDebug(@"=======================<handleArcGesture> failed!!!=======================");
    }
    
}

- (void)stateCallBack:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateFailed) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(gestureRecognizerManager:didGestureFailed:)]) {
            [self.delegate gestureRecognizerManager:self didGestureFailed:gesture];
        }
    }else if (gesture.state == UIGestureRecognizerStateBegan) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(gestureRecognizerManager:didGestureBegan:)]) {
            [self.delegate gestureRecognizerManager:self didGestureBegan:gesture];
        }
    }else  if (gesture.state == UIGestureRecognizerStateEnded) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(gestureRecognizerManager:didGestureEnd:)]) {
            [self.delegate gestureRecognizerManager:self didGestureEnd:gesture];
        }
    }

}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)gestureRecognizer {
    
    [self stateCallBack:gestureRecognizer];
    if([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        // Reset the last scale, necessary if there are multiple objects with different scales
        lastScale = [gestureRecognizer scale];
    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan ||
        [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        
        CGFloat currentScale = [[[gestureRecognizer view].layer valueForKeyPath:@"transform.scale"] floatValue];
        
        // Constants to adjust the max/min values of zoom
        const CGFloat kMaxScale = 10;
        const CGFloat kMinScale = 1;
        const CGFloat kSpeed = 0.75;
        
        CGFloat newScale = 1 -  (lastScale - [gestureRecognizer scale]) * (kSpeed);
        newScale = MIN(newScale, kMaxScale / currentScale);
        newScale = MAX(newScale, kMinScale / currentScale);
        CGAffineTransform transform = CGAffineTransformScale([[gestureRecognizer view] transform], newScale, newScale);
        [gestureRecognizer view].transform = transform;
        lastScale = [gestureRecognizer scale];  // Store the previous scale factor for the next pinch gesture call
    }else if([gestureRecognizer state] == UIGestureRecognizerStateEnded ||
             [gestureRecognizer state] == UIGestureRecognizerStateCancelled){
        [self adjustView:[gestureRecognizer view]];
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    
    [self stateCallBack:gestureRecognizer];
    
    UIView *myView = [gestureRecognizer view];
    
    CGPoint translate = [gestureRecognizer translationInView:[myView superview]];
    
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        [myView setCenter:CGPointMake(myView.center.x + translate.x, myView.center.y + translate.y)];
        [gestureRecognizer setTranslation:CGPointZero inView:[myView superview]];
    }else if([gestureRecognizer state] == UIGestureRecognizerStateEnded ||
             [gestureRecognizer state] == UIGestureRecognizerStateCancelled){
        [self adjustView:myView];
    }
    
}

- (void)adjustView:(UIView *)view
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    CGRect frame = view.frame;
    if(view.superview)
    {
        CGRect bounds = view.superview.bounds;
        if (CGRectGetWidth(frame) <= CGRectGetWidth(bounds) &&
            CGRectGetHeight(frame) <= CGRectGetHeight(bounds)) {
            view.center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
        }else{
            CGPoint origin = frame.origin;
            CGSize size = frame.size;
            origin.x = MIN(0, origin.x);
            origin.y = MIN(0, origin.y);
            origin.x = MAX(origin.x, CGRectGetWidth(view.superview.bounds) - size.width);
            origin.y = MAX(origin.y, CGRectGetHeight(view.superview.bounds) - size.height);
            frame.origin = origin;
            view.frame = frame;
        }
    }
    [UIView commitAnimations];
}



- (void)handleDoubleTap:(UITapGestureRecognizer *)doubleTap {
    [self stateCallBack:doubleTap];
    if (doubleTap.state == UIGestureRecognizerStateRecognized) {
        [doubleTap.view setTransform:CGAffineTransformIdentity];
        [self adjustView:doubleTap.view];
    }
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && ![self canMoveView:gestureRecognizer.view]) {
        return NO;
    }
    return YES;
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (!self.capture) {
        return NO;
    }
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && ![self canMoveView:gestureRecognizer.view]) {
        return NO;
    }
    return YES;
}
@end