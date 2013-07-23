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
    PPRelease(_penColor);
    PPRelease(_bgColor);
    [super dealloc];
}

@end


@implementation DrawLayer
@synthesize name = _name;
@synthesize drawActionList = _drawActionList;
@synthesize drawInfo = _drawInfo;


- (void)dealloc
{
    PPRelease(_drawActionList);
    PPRelease(_name);
    PPRelease(_cdManager);
    PPRelease(_drawInfo);
    [super dealloc];
}

- (void)drawInContext:(CGContextRef)ctx
{
    if (_cdManager) {
        [_cdManager showInContext:ctx];
    }else{
        for (DrawAction *action in _drawActionList) {
            [action drawInContext:ctx inRect:self.bounds];
        }
    }
}

@end
