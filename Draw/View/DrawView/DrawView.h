//
//  DrawView.h
//  Draw
//
//  Created by  on 12-3-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawUtils.h"
#import "Paint.h"
#import "PenView.h"

@protocol DrawViewDelegate <NSObject>

@optional
- (void)didDrawedPaint:(Paint *)paint;
- (void)didStartedTouch:(Paint *)paint;

@end

@class DrawColor;
@class DrawAction;
@class PenView;

@interface DrawView : UIView<UIGestureRecognizerDelegate>
{
    NSMutableArray *_drawActionList;
    DrawAction *_currentDrawAction;
    NSInteger startDrawActionIndex;
    CGFloat _lineWidth;
    DrawColor* _lineColor;    
    PenType _penType;
//    PenView *pen;
}

@property (nonatomic, retain) NSMutableArray *drawActionList;
@property(nonatomic, assign) CGFloat lineWidth; //default is 5.0
@property(nonatomic, retain) DrawColor* lineColor; //default is black
@property(nonatomic, assign) CGFloat simplingDistance; //default is 4.0 * 1.414
@property(nonatomic, assign) id<DrawViewDelegate>delegate;
@property(nonatomic, assign) PenType penType;

- (void)clearAllActions; //remove all the actions
- (void)addCleanAction;
- (void)addAction:(DrawAction *)drawAction;
- (UIImage*)createImage;
- (void)setDrawEnabled:(BOOL)enabled;
- (BOOL)isViewBlank;
@end
