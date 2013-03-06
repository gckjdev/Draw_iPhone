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

#import <QuartzCore/QuartzCore.h>

@interface SuperDrawView : UIControl
{
    NSMutableArray *_drawActionList;
    
    //used by subclass
    DrawAction *_currentAction;
    
    OffscreenManager *osManager;

}

@property (nonatomic, retain) NSMutableArray *drawActionList;
@property (nonatomic, retain) UIImage *drawBgImage;
@property (nonatomic, assign) CGFloat scale;

//public method
#pragma mark - util methods
- (BOOL)isViewBlank;
- (UIImage*)createImage;
- (void)showImage:(UIImage *)image;
- (CGContextRef)createBitmapContext;

#pragma mark -show && stroke
- (void)show;
- (void)cleanAllActions;
- (void)addDrawAction:(DrawAction *)drawAction;

- (void)drawDrawAction:(DrawAction *)drawAction show:(BOOL)show;
- (void)drawPaint:(Paint *)paint show:(BOOL)show;

- (void)setDrawBg:(PBDrawBg *)drawBg;
- (PBDrawBg *)drawBg;



@end