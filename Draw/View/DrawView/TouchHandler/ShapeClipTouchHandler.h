//
//  ShapeClipTouchHandler.h
//  Draw
//
//  Created by gamy on 13-7-8.
//
//

#import "TouchHandler.h"
#import "ClipAction.h"

@interface ShapeClipTouchHandler : TouchHandler

@property(nonatomic, assign) ClipType clipType;


- (void)drawAction;


@end
