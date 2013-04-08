//
//  GestureRecognizerManager.m
//  SourceProfile
//
//  Created by gamy on 13-3-8.
//  Copyright (c) 2013年 ict. All rights reserved.
//

#import "GestureRecognizerManager.h"
#import "SuperDrawView.h"
#import "RoundPercentageView.h"
//#import "DrawUtils.h"
#import "UIViewUtils.h"
#import "DrawView.h"

@interface GestureRecognizerManager()
{
    CGFloat lastScale;
    CGFloat lastRadian;
    NSMutableSet *grSet;
    BOOL _canMove;
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
}

- (BOOL)canMoveView:(UIView *)view
{
//    return !CGAffineTransformEqualToTransform(view.transform, CGAffineTransformIdentity);
    CGRect bounds = view.superview.bounds;
    CGRect frame = view.frame;
    if (CGRectGetWidth(frame) <= CGRectGetWidth(bounds)+1 && CGRectGetHeight(frame) <= CGRectGetHeight(bounds) + 1) {
        return NO;
    }
    return YES;
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
    
    
    UIView *view = [gestureRecognizer view];
    if (![view isKindOfClass:[SuperDrawView class]]) {
        return;
    }

    [self stateCallBack:gestureRecognizer];
    
    SuperDrawView *sDrawView = (SuperDrawView *)view;
    
    CGFloat kMaxScale = sDrawView.maxScale;
    CGFloat kMinScale = sDrawView.minScale;

    
    
    if([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        lastScale = sDrawView.scale;
    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan ||
        [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
                
// Constants to adjust the max/min values of zoom
        CGFloat guestureScale = [gestureRecognizer scale];
        CGFloat currentScale = guestureScale * lastScale;
        
//        CGFloat newScale = guestureScale * lastScale;
        currentScale = MIN(currentScale, kMaxScale);
        currentScale = MAX(currentScale, kMinScale);

        [sDrawView setScale:currentScale];
        PPDebug(@"Guesture Scale = %f, currentScale = %f, lastScale = %f",guestureScale, currentScale, lastScale);
    }else if([gestureRecognizer state] == UIGestureRecognizerStateEnded ||
             [gestureRecognizer state] == UIGestureRecognizerStateCancelled){
        [self adjustView:[gestureRecognizer view]];
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
    
    [self stateCallBack:gestureRecognizer];
    
    if (!_canMove) {
        return;
    }
    
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

        BOOL aX = NO, aY = NO;
        
        if (CGRectGetWidth(frame) <= CGRectGetWidth(bounds)+1) {
            frame.origin.x = (CGRectGetWidth(bounds) - CGRectGetWidth(frame)) / 2.0;
            aX = YES;
        }
        if(CGRectGetHeight(frame) <= CGRectGetHeight(bounds)+1){
            frame.origin.y = (CGRectGetHeight(bounds) - CGRectGetHeight(frame)) / 2.0;
            aY = YES;
        }
        CGPoint origin = frame.origin;
        
        const CGFloat R = 2.0;
    
        if (!aX) {
            if (CGRectGetMaxX(frame) < CGRectGetWidth(bounds) / R ) {
                origin.x = - CGRectGetWidth(frame)  +  CGRectGetWidth(bounds) / R ;
            }else if(CGRectGetMaxX(bounds) - CGRectGetMinX(frame) < CGRectGetWidth(bounds) / R ){
                origin.x = CGRectGetWidth(bounds) / R ;
            }
        }
        if (!aY) {
            if (CGRectGetMaxY(frame) < CGRectGetHeight(bounds) / R) {
                origin.y = - CGRectGetHeight(frame) +  CGRectGetHeight(bounds) / R;
            }else if(CGRectGetMaxY(bounds) - CGRectGetMinY(frame) < CGRectGetHeight(bounds) / R ){
                origin.y = CGRectGetHeight(bounds) / R ;
            }
        }

        frame.origin = origin;
        view.frame = frame;
        _canMove = [self canMoveView:view];

    }
    PPDebug(@"<adjustView> frame = %@",NSStringFromCGRect(view.frame));
    [UIView commitAnimations];
}



- (void)handleDoubleTap:(UITapGestureRecognizer *)doubleTap {
    [self stateCallBack:doubleTap];
    if (doubleTap.state == UIGestureRecognizerStateRecognized) {
        if ([doubleTap.view respondsToSelector:@selector(resetTransform)]) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.5];
            [doubleTap.view performSelector:@selector(resetTransform)];
//            [doubleTap.view setCenter:CGRectGetCenter(doubleTap.view.superview.bounds)];
            PPDebug(@"<handleDoubleTap> frame = %@",NSStringFromCGRect(doubleTap.view.frame));
            [UIView commitAnimations];
        }
//        [doubleTap.view setTransform:CGAffineTransformIdentity];
//        [self adjustView:doubleTap.view];
        _canMove = [self canMoveView:doubleTap.view];
    }
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
//    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && ![self canMoveView:gestureRecognizer.view]) {
//        return NO;
//    }
    return YES;
}
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (!self.capture) {
        return NO;
    }
//    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && ![self canMoveView:gestureRecognizer.view]) {
//        return NO;
//    }
    return YES;
}
@end
