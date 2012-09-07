//
//  DrawView.h
//  Draw
//
//  Created by  on 12-3-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperDrawView.h"

@protocol DrawViewDelegate <NSObject>

@optional
- (void)didDrawedPaint:(Paint *)paint;
- (void)didStartedTouch:(Paint *)paint;

@end


@interface DrawView : SuperDrawView<UIGestureRecognizerDelegate>
{
    CGFloat _lineWidth;
    DrawColor* _lineColor;    
    ItemType _penType;
    
}

//@property (nonatomic, retain) NSMutableArray *drawActionList;
@property(nonatomic, assign) CGFloat lineWidth; //default is 5.0
@property(nonatomic, retain) DrawColor* lineColor; //default is black
@property(nonatomic, assign) id<DrawViewDelegate>delegate;
@property(nonatomic, assign) ItemType penType;


- (void)addCleanAction;
- (DrawAction *)addChangeBackAction:(DrawColor *)color;
- (void)setDrawEnabled:(BOOL)enabled;
- (BOOL)canRevoke;

//- (void)revoke;
//- (void)clearAllActions; //remove all the actions
@end
