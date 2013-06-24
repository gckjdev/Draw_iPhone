//
//  SuperDrawView.h
//  Draw
//
//  Created by  on 12-9-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawUtils.h"
#import "Paint.h"
#import "DrawColor.h"
#import "DrawAction.h"
#import "ItemType.h"
#import "OffscreenManager.h"
#import "DrawBgManager.h"
#import "GestureRecognizerManager.h"
#import <QuartzCore/QuartzCore.h>
#import "ChangeBackAction.h"
#import "CleanAction.h"
#import "PaintAction.h"
#import "ShapeAction.h"

#import "CacheDrawManager.h"

@interface SuperDrawView : UIControl<GestureRecognizerManagerDelegate>
{
    NSMutableArray *_drawActionList;
    
    //used by subclass
    DrawAction *_currentAction;
    
//    OffscreenManager *osManager;
    CacheDrawManager *cdManager;
    
    GestureRecognizerManager *_gestureRecognizerManager;
}

@property (nonatomic, retain) NSMutableArray *drawActionList;

@property (nonatomic, assign) CGFloat scale; //current scale

@property (nonatomic, assign) CGFloat minScale; //default is 1
@property (nonatomic, assign) CGFloat maxScale; //default is 10

//public method
#pragma mark - util methods
- (BOOL)isViewBlank;
- (UIImage*)createImage;
- (UIImage *)createImageWithSize:(CGSize)size;
- (void)showImage:(UIImage *)image;
- (CGContextRef)createBitmapContext;

#pragma mark -show && stroke
- (void)show;
- (void)cleanAllActions;
- (void)addDrawAction:(DrawAction *)drawAction;
- (DrawAction *)lastAction;


//add a new draw action
- (void)drawDrawAction:(DrawAction *)drawAction show:(BOOL)show;

//update the last action
- (void)updateLastAction:(DrawAction *)action show:(BOOL)show;

//- (void)drawPaint:(Paint *)paint show:(BOOL)show;

- (void)resetTransform;
- (void)changeRect:(CGRect)rect;
- (void)setBGImage:(UIImage *)image;

@end



