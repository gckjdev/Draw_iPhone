//
//  ShapeClipTouchHandler.h
//  Draw
//
//  Created by gamy on 13-7-8.
//
//

#import "TouchHandler.h"
#import "ClipAction.h"
#import "ShapeAction.h"

@interface ShapeClipTouchHandler : TouchHandler

@property(nonatomic, assign) ClipType clipType;
@property(nonatomic, assign) ShapeType shapeType;

- (DrawAction *)drawAction;


@end
