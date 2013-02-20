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
@property (nonatomic, assign, readonly)NSUInteger setp; //default is 50

//draw view: the level should be >= 4, show view level must be 2
- (id)initWithLevelNumber:(NSUInteger)level maxUndoStep:(NSUInteger)setp;
- (void)addDrawAction:(DrawAction *)action;
- (void)showAllLayersInContext:(CGContextRef)context;
@end
