//
//  ColorGroup.m
//  Draw
//
//  Created by  on 12-4-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ColorGroup.h"

@implementation ColorGroup
@synthesize colorViewList = _colorViewList;
@synthesize groupId = _groupId;
@synthesize price = _price;

- (id)initWithGroupId:(NSInteger)groupId colorViewList:(NSArray *)colorViewList
{
    self = [super init];
    if (self) {
        self.groupId = groupId;
        self.colorViewList = colorViewList;
    }
    return self;
}

- (void)dealloc
{
    [_colorViewList release];
    [super dealloc];
}

- (NSInteger)colorViewCount
{
    return [_colorViewList count];
}

@end
