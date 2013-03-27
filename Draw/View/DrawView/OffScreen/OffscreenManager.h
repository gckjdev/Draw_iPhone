//
//  OffscreenManager.h
//  Draw
//
//  Created by gamy on 13-2-20.
//
//

#import <Foundation/Foundation.h>
#import "DrawAction.h"
#import "Offscreen.h"



@interface OffscreenManager : NSObject

@property (nonatomic, assign, readonly)NSUInteger level; //default is 3
@property (nonatomic, assign, readonly)NSUInteger step; //default is 50
@property (nonatomic, assign)BOOL showGridOffscreen;

//- (void)addGridOffscreen;
//- (void)showGridOffscreen:(BOOL)show;


//draw view: the level should be >= 4
//show view: level must be 2 step must be 1
- (id)initWithLevelNumber:(NSUInteger)level maxUndoStep:(NSUInteger)step rect:(CGRect)rect;

+ (id)drawViewOffscreenManagerWithRect:(CGRect)rect; //default OffscreenManager
+ (id)showViewOffscreenManagerWithRect:(CGRect)rect; //default OffscreenManager


//add draw action and draw it in the last layer.
- (CGRect)addDrawAction:(DrawAction *)action;

- (void)cancelLastAction;

- (void)updateWithDrawActionList:(NSArray *)drawActionList;

//show all the action render in the layer list
- (void)showAllLayersInContext:(CGContextRef)context;

//show to index, and return the real index. such as: show to index 12, but can return 10. real index <= index is guaranteed

- (NSUInteger)closestIndexWithActionIndex:(NSUInteger)index;

//- (void)removeContentAfterIndex:(NSUInteger)index;

//find the offscreen which the action is in;
- (Offscreen *)offScreenForActionIndex:(NSInteger)index;

//clean all the layer.
- (void)clean;

//return total action count;
- (NSUInteger)actionCount;

- (BOOL)isEmpty;


- (Offscreen *)enteryScreen;

//- (void)setStrokeColor:(DrawColor *)color width:(CGFloat)width;

//- (void)updateDrawPenWithPaint:(Paint *)paint;

- (CGRect)updateLastAction:(DrawAction *)action;

//- (CGRect)updateLastPaint:(Paint *)paint;


- (BOOL)canUndo;

- (void)printOSInfo;

@end
