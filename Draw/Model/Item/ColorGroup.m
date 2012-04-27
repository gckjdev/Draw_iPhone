//
//  ColorGroup.m
//  Draw
//
//  Created by  on 12-4-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ColorGroup.h"
#import "ColorView.h"

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

//the value size should be 5 * 3 = 15
#define COLOR_VALUE_SIZE 15
+ (NSArray *)colorViewListWithColorValues:(NSInteger *)values
{
    NSMutableArray *array = [[[NSMutableArray alloc] initWithCapacity:5]autorelease];
    for (int i = 0; i < COLOR_VALUE_SIZE; i += 3) {
        NSInteger red = values[i];
        NSInteger green = values[i + 1];
        NSInteger blue = values[i + 2];
    
        ColorView *colorView = [[ColorView alloc] initWithRed:red 
                                                        green:green 
                                                         blue:blue 
                                                        scale:ColorViewScaleLarge];
        [array addObject:colorView];
        [colorView release];
    }
    return array;
}

#define GROUP_GRAY 101
#define GROUP_DARK_BLUE 102
#define GROUP_SKY_BLUE 103
+ (ColorGroup *)colorGroupForGroupId:(NSInteger)groupId
{
    NSInteger *colorValues = NULL;
    switch (groupId) {
        case GROUP_GRAY:
        {
            NSInteger values[] = {105,105,105,169,169,169,192,192,192,211,211,211,245,245,245};
            colorValues = values;
            break;
        }
        case GROUP_DARK_BLUE:
        {
            NSInteger values[] = {0,0,139, 0,0,205, 0,0,255, 65,105,255, 100,149,237};
            colorValues = values;
            break;            
        }
        case GROUP_SKY_BLUE:
        {
            NSInteger values[] = {70,130,180, 0,191,255, 135,206,235, 135,206,250, 173,216,230};
            colorValues = values;
            break;            
        }
            
        default:
        {
            NSInteger values[] = {128,0,128,153,50,204,186,85,211,218,112,214,221,160,221};
            colorValues = values;
            break;
        }
    }
    NSArray *array = [ColorGroup colorViewListWithColorValues:colorValues];
    return [[[ColorGroup alloc] initWithGroupId:groupId colorViewList:array] autorelease];
}
@end
