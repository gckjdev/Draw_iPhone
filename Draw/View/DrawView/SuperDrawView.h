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


@class DrawColor;
@class DrawAction;


@interface SuperDrawView : UIView
{
    NSMutableArray *_drawActionList;
    DrawAction *_currentDrawAction;
    NSInteger _startDrawActionIndex;
    
    DrawRectType _drawRectType;
    CGPoint _currentPoint;
    CGPoint _previousPoint1;
    CGPoint _previousPoint2;
    BOOL _edge;
    UIImage *_curImage;
    CGColorRef _changeBackColor;
    
    UIImage *_image; 
}

@property (nonatomic, retain) NSMutableArray *drawActionList;
@property (nonatomic, retain) UIImage *curImage;

//public method
- (BOOL)isViewBlank;
- (void)show;
- (void)showImage:(UIImage *)image;
- (UIImage*)createImage;
- (void)cleanAllActions;

//use for sub classes
- (void)resetStartIndex;
- (void)drawPoint:(CGFloat)width color:(CGColorRef)cgColor;

- (void)drawPaint:(Paint *)paint;
@end
