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
#import <QuartzCore/QuartzCore.h>

typedef enum{
    DrawRectTypeNo = 0,
    DrawRectTypeLine = 1,//touch draw
    DrawRectTypeClean = 2,//clean the screen
    DrawRectTypeRedraw = 3,//show the previous action list
    DrawRectTypeChangeBack = 4,//show the previous action list
    DrawRectTypeRevoke = 5,//show the previous action list
    DrawRectTypeRedo = 6,//show the last action list
    
    DrawRectTypeShowImage = 7, //implement by show draw view
}DrawRectType;



@interface SuperDrawView : UIControl
{
    NSMutableArray *_drawActionList;
    
    CGLayerRef cacheLayerRef, showLayerRef;
    CGContextRef cacheContext, showContext;
    
    BOOL showCacheLayer;
    
    
    //used by subclass
    DrawAction *_currentAction;


}

@property (nonatomic, retain) NSMutableArray *drawActionList;


//public method
#pragma mark - util methods
- (BOOL)isViewBlank;
- (UIImage*)createImage;
- (void)showImage:(UIImage *)image;


#pragma mark -show && stroke
- (void)show;
- (void)cleanAllActions;
- (void)addDrawAction:(DrawAction *)drawAction;
- (void)drawAction:(DrawAction *)action inContext:(CGContextRef)context;
- (void)setStrokeColor:(DrawColor *)color lineWidth:(CGFloat)width inContext:(CGContextRef)context;
- (void)strokePaint:(Paint *)paint inContext:(CGContextRef)context clear:(BOOL)clear;

#pragma mark - refresh view
- (void)setNeedsDisplayShowCacheLayer:(BOOL)show;

@end