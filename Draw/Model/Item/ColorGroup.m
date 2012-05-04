//
//  ColorGroup.m
//  Draw
//
//  Created by  on 12-4-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ColorGroup.h"
#import "ColorView.h"

#define COLOR_VALUE_COUNT 15
#define RGB_COUNT 3
#define RANDOM_OFFSET 4

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

+ (NSMutableArray *)colorGroupForGroupId:(NSInteger)groupId
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
        case GROUP_PURPLE:
        {
            NSInteger values[] = {128,0,128,153,50,204,186,85,211,218,112,214,221,160,221};
            colorValues = values;
            break;            
        }
        case GROUP_PINK:
        {
            NSInteger values[] = {219,112,147,255,20,147,255,106,180,255,182,193,255,192,203};
            colorValues = values;
            break;            
        }
        case GROUP_PINK_PURPLE:
        {
            NSInteger values[] = {139,0,139, 148,0,211,255,0,255,238,130,238,216,191,216 };
            colorValues = values;
            break;            
        }
        case GROUP_LIGHT_BLUE:
        {
            NSInteger values[] = {25,25,112,0,0,128,0,0,255,72,61,139,106,90,205};
            colorValues = values;
            break;            
        }
        case GROUP_BLUE:
        {
            NSInteger values[] = {0,0,139,0,0,205,65,105,225,100,149,237,176,196,222};
            colorValues = values;
            break;            
        }
        case GROUP_BRIGHT_BLUE:
        {
            NSInteger values[] = {70,130,180,0,191,255,135,206,250,173,216,230,230,230,250};
            colorValues = values;
            break;            
        }
        case GROUP_LIGHT_ORANGE:
        {
            NSInteger values[] = {139,69,19,210,105,30,244,164,96,255,222,173,255,235,205};
            colorValues = values;
            break;            
        }
        case GROUP_TREE:
        {
            NSInteger values[] = {128,0,0,222,184,135,178,34,34,205,92,92,240,128,128};
            colorValues = values;
            break;            
        }
        case GROUP_ORANGE:
        {
            NSInteger values[] =    {255,69,0,255,140,0,255,127,80,255,160,122,255,216,165};
            colorValues = values;
            break;            
        }   
            
        case GROUP_DARK_ORANGE:
        {
            NSInteger values[] =   {218,165,32,255,165,0,255,215,0,240,230,140,245,222,179};
            colorValues = values;
            break;            
        }
            
        case GROUP_LIGHT_PINK:
        {
            NSInteger values[] =   {218,165,32,255,165,0,255,215,0,240,230,140,245,222,179};
            colorValues = values;
            break;            
        }
            
        case GROUP_GRAY_GREEN:
        {
            NSInteger values[] =   {0,100,0, 0,128,0, 85,107,47, 128,128,0, 127,255,170};
            colorValues = values;
            break;            
        }
        case GROUP_BRIGHT_GREEN:
        {
            NSInteger values[] =   {34,139,34,50,205,50,0,255,0,124,252,0,173,255,47};
            colorValues = values;
            break;            
        }
        case GROUP_BROWN:
        default:
        {
            NSInteger values[] = {139,0,0,165,42,42,160,82,45,205,133,63,210,180,140};
            colorValues = values;
            break;
        }
    }
    NSMutableArray* array = [[[NSMutableArray alloc] initWithCapacity:COLOR_VALUE_COUNT] autorelease];
    for (int i = 0; i<COLOR_VALUE_COUNT; i++) {
        [array addObject:[NSNumber numberWithInt:colorValues[i]]];
    }
    return array;
    //    NSArray *array = [ColorGroup colorViewListWithColorValues:colorValues];
    //    return [[[ColorGroup alloc] initWithGroupId:groupId colorViewList:array] autorelease];
} 

+ (ColorGroup *)randomColorGroupForGroupId:(NSInteger)groupId
{
    NSInteger randomColorValues[COLOR_VALUE_COUNT];
    NSMutableArray *colorValues;
    for (int i = 0; i < COLOR_VALUE_COUNT/RGB_COUNT; i++) {
        if (groupId+i*RANDOM_OFFSET >= GROUP_COUNT) {
            colorValues = [ColorGroup colorGroupForGroupId:GROUP_START+groupId+i*RANDOM_OFFSET-GROUP_COUNT];
        } else {
            colorValues = [ColorGroup colorGroupForGroupId:groupId+i*RANDOM_OFFSET];
        }
        for (int j = 0; j < RGB_COUNT; j++) {
            randomColorValues[j+i*RGB_COUNT] = [(NSNumber*)[colorValues objectAtIndex:(j+i*RGB_COUNT)] intValue];
        }
    }
    NSArray *array = [ColorGroup colorViewListWithColorValues:randomColorValues];
    return [[[ColorGroup alloc] initWithGroupId:groupId colorViewList:array] autorelease];
}


@end
