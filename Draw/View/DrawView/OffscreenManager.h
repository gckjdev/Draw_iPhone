//
//  OffscreenManager.h
//  Draw
//
//  Created by gamy on 13-2-20.
//
//

#import <Foundation/Foundation.h>
#import "DrawAction.h"

@interface OffscreenManager : NSObject

@property (nonatomic, assign, readonly)NSUInteger level; //default is 3
@property (nonatomic, assign, readonly)NSUInteger step; //default is 50

//draw view: the level should be >= 4
//show view: level must be 2 step must be 1
- (id)initWithLevelNumber:(NSUInteger)level maxUndoStep:(NSUInteger)step;

+ (id)drawViewOffscreenManager; //default OffscreenManager
+ (id)showViewOffscreenManager; //default OffscreenManager


//add draw action and draw it in the last layer.
- (void)addDrawAction:(DrawAction *)action;

//show all the action render in the layer list
- (void)showAllLayersInContext:(CGContextRef)context;

//show to index, and return the real index. such as: show to index 12, but can return 10. real index <= index is guaranteed
- (NSUInteger)showToIndex:(NSUInteger)index inContext:(CGContextRef)context;

@end
