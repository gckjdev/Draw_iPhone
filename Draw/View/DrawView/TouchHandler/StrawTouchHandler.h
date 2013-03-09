//
//  StrawTouchHandler.h
//  Draw
//
//  Created by gamy on 13-3-9.
//
//

#import "TouchHandler.h"


@protocol DrawViewStrawDelegate;

@interface StrawTouchHandler : TouchHandler

@property(nonatomic, assign)id<DrawViewStrawDelegate> strawDelegate;

@end
