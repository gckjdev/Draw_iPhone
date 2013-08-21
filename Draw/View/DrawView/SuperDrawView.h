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
#import "DrawBgManager.h"
#import "GestureRecognizerManager.h"
#import <QuartzCore/QuartzCore.h>
#import "ChangeBackAction.h"
#import "CleanAction.h"
#import "PaintAction.h"
#import "ShapeAction.h"
#import "CanvasRect.h"

#import "DrawLayerManager.h"

#define DRAW_VIEW_UPDATED_SCACLE @"DRAW_VIEW_UPDATED_SCACLE"

@interface SuperDrawView : UIControl<GestureRecognizerManagerDelegate, DrawProcessProtocol>
{
    NSMutableArray *_drawActionList;
    
    //used by subclass
    DrawAction *_currentAction;
    
    DrawLayerManager *dlManager;
    
    GestureRecognizerManager *_gestureRecognizerManager;
}

@property (nonatomic, retain) NSMutableArray *drawActionList;

@property (nonatomic, assign) CGFloat scale; //current scale

@property (nonatomic, assign) CGFloat minScale; //default is 1
@property (nonatomic, assign) CGFloat maxScale; //default is 10


- (id)initWithFrame:(CGRect)frame layers:(NSArray *)layers;


//public method
#pragma mark - util methods
- (BOOL)isViewBlank;
- (UIImage*)createImage;
- (UIImage *)createImageWithSize:(CGSize)size;
- (void)showImage:(UIImage *)image;
- (CGContextRef)createBitmapContext;


- (ClipAction *)currentClip;
- (NSArray *)layers;
- (void)updateLayers:(NSArray *)layers;

#pragma mark -show && stroke
- (void)show;
- (void)cleanAllActions;


- (void)resetTransform;
- (void)changeRect:(CGRect)rect;
- (void)setBGImage:(UIImage *)image;



////layer

- (DrawLayer *)currentLayer;
@end



