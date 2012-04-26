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
@synthesize hasBought = _hasBought;

- (id)initWithGroupId:(NSInteger)groupId 
        colorViewList:(NSArray *)colorViewList
{
    self = [super init];
    if (self) {
        self.groupId = groupId;
        self.colorViewList = colorViewList;
        self.hasBought = NO;
    }
    return self;
}


- (id)initWithGroupId:(NSInteger)groupId 
        colorViewList:(NSArray *)colorViewList 
            hasBought:(BOOL)hasBought
{
    self = [super init];
    if (self) {
        self.groupId = groupId;
        self.colorViewList = colorViewList;
        self.hasBought = hasBought;
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
