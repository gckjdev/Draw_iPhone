//
//  DrawAction.m
//  Draw
//
//  Created by  on 12-3-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DrawAction.h"
#import "Paint.h"

@implementation DrawAction

@synthesize type = _type;
@synthesize paint = _paint;

- (void)dealloc
{
    [_paint release];
    [super dealloc];
}

@end
