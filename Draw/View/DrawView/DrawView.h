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
    
}

@property(nonatomic, assign) id<DrawViewDelegate>delegate;
@property(nonatomic, assign) id<DrawViewStrawDelegate>strawDelegate;
@property(nonatomic, assign) TouchActionType touchActionType;

- (void)setDrawEnabled:(BOOL)enabled;

- (void)clearRedoStack;
- (BOOL)redo;
- (BOOL)undo;
- (void)showDraft:(MyPaint *)draft;


- (NSInteger)totalActionCount;
- (NSInteger)actionCount;

- (DrawInfo *)drawInfo;

@end
