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

typedef enum{
    Unplaying = 0x1,
    Playing = 0x1 << 1 
}DrawViewStatus;


@protocol DrawViewDelegate <NSObject>

@optional
- (void)didDrawedPaint:(Paint *)paint;
- (void)didStartedTouch;

@end

@class DrawColor;
@interface DrawView : UIView<UIGestureRecognizerDelegate>
{
    BOOL _drawEnable;
    NSMutableArray *_paintList;
    Paint *currentPaint;
    UIPanGestureRecognizer *pan;
    UITapGestureRecognizer *tap;

    CGFloat _lineWidth;
    DrawColor* _lineColor;    

    DrawViewStatus _status;
    CGPoint _paintPosition;
    NSTimer *_playTimer;
    
}

@property(nonatomic, assign, getter = isDrawEnabled) BOOL drawEnabled; //default is yes
@property(nonatomic, retain) NSMutableArray *paintList;
@property(nonatomic, assign) CGFloat lineWidth; //default is 5.0
@property(nonatomic, retain) DrawColor* lineColor; //default is black
@property(nonatomic, readonly) DrawViewStatus status; //default is Drawing
@property(nonatomic, assign) CGFloat playSpeed; //default is 1/40.0;
@property(nonatomic, assign) CGFloat simplingDistance; //default is 4.0 * 1.414

@property(nonatomic, assign) id<DrawViewDelegate>delegate;

- (NSInteger)lastPaintPointCount;
- (void)addPaint:(Paint *)paint play:(BOOL)play;
- (void)clear;
- (void)play;
-(UIImage*)createImage;

@end
