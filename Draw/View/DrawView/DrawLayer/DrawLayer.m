//
//  DrawLayer.m
//  TestCodePool
//
//  Created by gamy on 13-7-22.
//  Copyright (c) 2013年 orange. All rights reserved.
//

#import "DrawLayer.h"
#import "CacheDrawManager.h"
#import "DrawAction.h"



@implementation DrawInfo

- (void)dealloc
{
    PPRelease(_shadow);
    PPRelease(_penColor);
    PPRelease(_bgColor);
    [super dealloc];
}

@end


@implementation DrawLayer
@synthesize drawActionList = _drawActionList;
@synthesize drawInfo = _drawInfo;


- (void)dealloc
{
    PPRelease(_drawActionList);
    PPRelease(_layerName);
    PPRelease(_cdManager);
    PPRelease(_drawInfo);
    [super dealloc];
}

- (void)drawInContext:(CGContextRef)ctx
{
    if (self.supportCache) {
        [_cdManager showInContext:ctx];
    }else{
        for (DrawAction *action in _drawActionList) {
            [action drawInContext:ctx inRect:self.bounds];
        }
    }
}

- (void)addDrawAction:(DrawAction *)action show:(BOOL)show
{
    if (action) {
        [self.drawActionList addObject:action];
        [self updateLastAction:action refresh:show];
    }
}
- (void)updateLastAction:(DrawAction *)action refresh:(BOOL)refresh
{
    if (action && [self.drawActionList lastObject]) {
        if ([self.drawActionList lastObject] != action) {
            [self.drawActionList replaceObjectAtIndex:[self.drawActionList count]-1 withObject:action];
        }
        if (refresh) {
            CGRect rect = [action redrawRectInRect:self.bounds];
            [self setNeedsDisplayInRect:rect];
        }
    }

}
- (void)finishLastAction
{

}

@end
