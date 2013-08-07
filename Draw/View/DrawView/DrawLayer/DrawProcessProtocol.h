//
//  DrawProcessProtocol.h
//  Draw
//
//  Created by gamy on 13-7-25.
//
//

#import <Foundation/Foundation.h>

@class DrawAction;
@class ClipAction;

@protocol DrawProcessProtocol <NSObject>


@required
//start to add a new draw action
- (void)addDrawAction:(DrawAction *)drawAction show:(BOOL)show;

//update the last action
- (void)updateLastAction:(DrawAction *)action refresh:(BOOL)refresh;

//finish update the last action
- (void)finishLastAction:(DrawAction *)action refresh:(BOOL)refresh;

//remove the last action force to refresh
- (void)cancelLastAction;


//clip action
- (void)enterClipMode:(ClipAction *)clipAction;
- (void)exitFromClipMode;



@optional

//return the action remove or readd.
- (DrawAction *)undoDrawAction:(DrawAction *)action;
- (DrawAction *)redoDrawAction:(DrawAction *)action;

- (BOOL)canRedoDrawAction:(DrawAction *)action;
- (BOOL)canUndoDrawAction:(DrawAction *)action;


@end
