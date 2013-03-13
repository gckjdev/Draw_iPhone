//
//  GestureRecognizerManager.h
//  SourceProfile
//
//  Created by gamy on 13-3-8.
//  Copyright (c) 2013年 ict. All rights reserved.
//

#import <Foundation/Foundation.h>


@class GestureRecognizerManager;
@class ArcGestureRecognizer;

@protocol GestureRecognizerManagerDelegate <NSObject>

@optional
- (void)gestureRecognizerManager:(GestureRecognizerManager *)manager
                 didGestureBegan:(UIGestureRecognizer *)gestureRecognizer;

- (void)gestureRecognizerManager:(GestureRecognizerManager *)manager
                 didGestureEnd:(UIGestureRecognizer *)gestureRecognizer;

- (void)gestureRecognizerManager:(GestureRecognizerManager *)manager
                   didGestureFailed:(UIGestureRecognizer *)gestureRecognizer;

@end

@interface GestureRecognizerManager : NSObject<UIGestureRecognizerDelegate>

@property(nonatomic, assign)id<GestureRecognizerManagerDelegate>delegate;
@property(nonatomic, assign)BOOL capture;

- (UIPanGestureRecognizer *)addPanGestureReconizerToView:(UIView *)view;
- (UIPinchGestureRecognizer *)addPinchGestureReconizerToView:(UIView *)view;
- (UIPanGestureRecognizer *)addDoubleTapGestureReconizerToView:(UIView *)view;
- (ArcGestureRecognizer *)addArcGestureRecognizerToView:(UIView *)view;
@end
