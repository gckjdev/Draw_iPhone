//
//  DrawView.h
//  Draw
//
//  Created by  on 12-3-4.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperDrawView.h"
#import "MyPaint.h"
#import "ShapeInfo.h"
#import "ChangeBGImageAction.h"
//#import "PolygonClipTouchHandler.h"

@class DrawView;
@class Gradient;

//@protocol PolygonClipTouchHandlerDelegate <NSObject>
//- (void) didPolygonClipTouchHandler:(PolygonClipTouchHandler *)handler finishAddPointsToAction:(ClipAction *)action;
//@end


@protocol DrawViewDelegate <NSObject>

@optional

- (void)drawView:(DrawView *)drawView didStartTouchWithAction:(DrawAction *)action;
- (void)drawView:(DrawView *)drawView didFinishDrawAction:(DrawAction *)action;


@end



@protocol DrawViewStrawDelegate <NSObject>

@optional
- (void)didStrawGetColor:(DrawColor *)color;
@end



@interface DrawView : SuperDrawView
{
    CGMutablePathRef tempPath;
    
}

//@property (nonatomic, retain) NSMutableArray *drawActionList;

@property(nonatomic, retain) DrawColor* lineColor; //default is black
@property(nonatomic, retain) DrawColor* bgColor; //default is black
@property(nonatomic, retain) Shadow *shadow;


@property(nonatomic, assign) CGFloat lineWidth; //default is 5.0
@property(nonatomic, assign) ItemType penType;
@property(nonatomic, assign) ShapeType shapeType;
@property(nonatomic, assign) BOOL strokeShape;
@property(nonatomic, assign) id<DrawViewDelegate>delegate;
@property(nonatomic, assign) id<DrawViewStrawDelegate>strawDelegate;
@property(nonatomic, assign) TouchActionType touchActionType;
@property(nonatomic, assign) BOOL grid;


- (void)clearScreen;
- (ChangeBackAction *)changeBackWithColor:(DrawColor *)color;
- (ChangeBGImageAction *)changeBGImageWithDrawBG:(PBDrawBg *)drawBg;

- (void)setDrawEnabled:(BOOL)enabled;

- (BOOL)canRevoke;
- (void)revoke:(dispatch_block_t)finishBlock; //undo
- (BOOL)canRedo;
- (void)redo;
- (void)undo;
- (void)showDraft:(MyPaint *)draft;
- (void)clearRedoStack;

- (NSInteger)totalActionCount;
- (NSInteger)actionCount;

- (void)updateLastAction:(DrawAction *)action;
- (void)saveLastAction:(DrawAction *)action;
- (void)cancelLastAction;
- (DrawAction *)inDrawAction;

- (void)exitFromClipMode;


/////New Methods

@end
