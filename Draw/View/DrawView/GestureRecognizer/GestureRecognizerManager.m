//
//  GestureRecognizerManager.m
//  SourceProfile
//
//  Created by gamy on 13-3-8.
//  Copyright (c) 2013年 ict. All rights reserved.
//

#import "GestureRecognizerManager.h"
#import "ArcGestureRecognizer.h"
#import "SuperDrawView.h"
#import "RoundPercentageView.h"
//#import "DrawUtils.h"
#import "UIViewUtils.h"
#import "DrawView.h"

@interface GestureRecognizerManager()
{
    CGFloat lastScale;
    CGFloat lastRadian;
    BOOL lastDirection;
    NSMutableSet *grSet;
    BOOL _canMove;
    
    RoundPercentageView *roundPercentView;
    ArcGestureRecognizer *arcGesture;
//    BOOL notScale;
}

@end


//12,9,9,55
//82,81,79 45

#define ROUND_BG_COLOR [UIColor colorWithRed:82/255. green:81/255. blue:79/255. alpha:45/255.]
#define ROUND_FG_COLOR [UIColor colorWithRed:12/255. green:9/255. blue:9/255. alpha:55/255.]
#define VALUE(X) (ISIPAD ? 2 * X : X)

#define ROUND_BORDER_WIDTH VALUE(5)
#define ROUND_VIEW_WIDTH VALUE(200)
#define ROUND_FONT_SIZE VALUE(16)

@implementation GestureRecognizerManager

- (id)init
{
    self = [super init];
    if (self) {
        self.capture = YES;
        grSet = [[NSMutableSet alloc] initWithCapacity:5];
        roundPercentView = [[RoundPercentageView alloc] initWithFrame:CGRectMake(0, 0, ROUND_VIEW_WIDTH, ROUND_VIEW_WIDTH)];
        [roundPercentView setBackgroundTintColor:ROUND_BG_COLOR];
        [roundPercentView setProgressTintColor:ROUND_BG_COLOR];
        [roundPercentView setProgressColor:ROUND_FG_COLOR];
        [roundPercentView setLineWidth:ROUND_BORDER_WIDTH];
        [roundPercentView setTextColor:[UIColor whiteColor]];
        [roundPercentView setTextFont:[UIFont boldSystemFontOfSize:ROUND_FONT_SIZE]];
    }
    return self;
}

- (void)dealloc
{
    PPRelease(grSet);
    PPRelease(roundPercentView);
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

- (ArcGestureRecognizer *)addArcGestureRecognizerToView:(UIView *)view
{
    view.userInteractionEnabled = YES;  // Enable user interaction
    view.multipleTouchEnabled = YES;
    arcGesture = [[ArcGestureRecognizer alloc] initWithTarget:self action:@selector(handleArcGesture:)];
    [view addGestureRecognizer:arcGesture];
    [grSet addObject:arcGesture];
    return [arcGesture autorelease];
}

#define REDO_UNDO_RADIAN 1

- (void)updateRoundPercentViewWithDirection:(BOOL)direction angle:(CGFloat)angle
{
    [roundPercentView setAngle:angle];
    if (direction) {
        [roundPercentView setText:NSLS(@"kRedoing")];
    }else{
        [roundPercentView setText:NSLS(@"kUndoing")];
    }
}

- (CGFloat)angleForDrawView:(DrawView *)drawView
{
    if ([drawView isKindOfClass:[DrawView class]]) {
        return M_PI_2 * (1 - ((CGFloat)drawView.actionCount / (CGFloat)drawView.totalActionCount));
    }
    return 0;
}

- (void)handleArcGesture:(ArcGestureRecognizer *)gestureRecognizer
{
    [self stateCallBack:gestureRecognizer];
    
    CGFloat angle = [self angleForDrawView:(DrawView *)gestureRecognizer.view];
    
    if([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        PPDebug(@"=======================<handleArcGesture> began!!!=======================");
        lastRadian = 0;
        [[gestureRecognizer.view superview] addSubview:roundPercentView];
        roundPercentView.center = CGRectGetCenter([gestureRecognizer.view superview].bounds);
        [self updateRoundPercentViewWithDirection:lastDirection angle:angle];
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
        
        [self updateRoundPercentViewWithDirection:lastDirection angle:angle];

//        NSString *dir = [gestureRecognizer direction] ? @">>>>>>>>>>>>>>" : @"<<<<<<<<<<<<<";
//        PPDebug(@"direction = %@, radian = %f", dir, gestureRecognizer.radian);
    }else if([gestureRecognizer state] == UIGestureRecognizerStateEnded ||
             [gestureRecognizer state] == UIGestureRecognizerStateCancelled){
        [roundPercentView removeFromSuperview];
    }else if(gestureRecognizer.state == UIGestureRecognizerStateFailed){
        PPDebug(@"=======================<handleArcGesture> failed!!!=======================");
        [roundPercentView removeFromSuperview];        
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
        
//        CGFloat currentScale = [[view.layer valueForKeyPath:@"transform.scale"] floatValue];
        
        // Constants to adjust the max/min values of zoom
        CGFloat guestureScale = [gestureRecognizer scale];
        CGFloat currentScale = guestureScale * lastScale;
        
//        CGFloat newScale = guestureScale * lastScale;
        currentScale = MIN(currentScale, kMaxScale);
        currentScale = MAX(currentScale, kMinScale);

        [sDrawView setScale:currentScale];
        PPDebug(@"Guesture Scale = %f, currentScale = %f, lastScale = %f",guestureScale, currentScale, lastScale);
        
//        CGFloat newScale = 1 -  (lastScale - [gestureRecognizer scale]) * (kSpeed);
//        newScale = MIN(newScale, kMaxScale / currentScale);
//        newScale = MAX(newScale, kMinScale / currentScale);
        
//        PPDebug(@"lastScale = %f, guestureScale =%f, newScale = %f", lastScale, guestureScale, newScale);
        
//        CGAffineTransform transform = CGAffineTransformScale([view transform], newScale, newScale);

//        PPDebug(@"<Pinch>scale = %f, transform = %@", newScale, NSStringFromCGAffineTransform(transform));
        
//        [gestureRecognizer view].transform = transform;
//        lastScale = [gestureRecognizer scale];  // Store the previous scale factor for the next pinch gesture call
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
        arcGesture.forceCircle = !_canMove;

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
