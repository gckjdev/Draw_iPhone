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
    DrawRectTypeLine = 1,//touch draw
    DrawRectTypeClean = 2,//clean the screen
    DrawRectTypeRedraw = 3,//show the previous action list
    DrawRectTypeChangeBack = 4,//show the previous action list
    
}DrawRectType;


@class DrawColor;
@class DrawAction;
//@class PenView;

@interface SuperDrawView : UIView
{
    NSMutableArray *_drawActionList;
    DrawAction *_currentDrawAction;
    NSInteger _startDrawActionIndex;
    
    DrawRectType _drawRectType;
    CGPoint _currentPoint;
    CGPoint _previousPoint1;
    CGPoint _previousPoint2;
    UIImage *_curImage;
    CGColorRef _changeBackColor;
}

@property (nonatomic, retain) NSMutableArray *drawActionList;

//public method
- (BOOL)isViewBlank;
- (void)show;
- (UIImage*)createImage;
- (void)cleanAllActions;

//use for sub classes
- (void)resetStartIndex;
@end
