//
//  GestureRecognizerManager.h
//  SourceProfile
//
//  Created by gamy on 13-3-8.
//  Copyright (c) 2013年 ict. All rights reserved.
//

#import <Foundation/Foundation.h>


@class GestureRecognizerManager;
@protocol GestureRecognizerManagerDelegate <NSObject>

- (void)gestureRecognizerManager:(GestureRecognizerManager *)manager
                 didGestureBegan:(UIGestureRecognizer *)gestureRecognizer;

- (void)gestureRecognizerManager:(GestureRecognizerManager *)manager
                 didGestureEnd:(UIGestureRecognizer *)gestureRecognizer;

- (void)gestureRecognizerManager:(GestureRecognizerManager *)manager
                   didGestureFailed:(UIGestureRecognizer *)gestureRecognizer;


@end

@interface GestureRecognizerManager : NSObject<UIGestureRecognizerDelegate>

@property(nonatomic, assign)id<GestureRecognizerManagerDelegate>delegate;

- (UIPanGestureRecognizer *)addPanGestureReconizerToView:(UIView *)view;
- (UIPinchGestureRecognizer *)addPinchGestureReconizerToView:(UIView *)view;

@end
