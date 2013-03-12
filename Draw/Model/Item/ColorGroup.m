//
//  ColorGroup.m
//  Draw
//
//  Created by  on 12-4-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ColorGroup.h"
#import "ColorView.h"
#import "PPDebug.h"
#import "AccountService.h"
#import "ShoppingManager.h"
#import "UserGameItemService.h"

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
    PPRelease(_colorViewList);
    [super dealloc];
}

- (NSInteger)colorViewCount
{
    return [_colorViewList count];
}

//the value size should be 5 * 3 = 15
#define COLOR_VALUE_SIZE 15

+ (NSArray *)drawColorListWithColorValues:(NSInteger *)values
{
    NSMutableArray *array = [[[NSMutableArray alloc] initWithCapacity:5]autorelease];
    for (int i = 0; i < COLOR_VALUE_SIZE; i += 3) {
        NSInteger red = values[i];
        NSInteger green = values[i + 1];
        NSInteger blue = values[i + 2];
        DrawColor *color = [DrawColor colorWithRed:red/255. green:green/255. blue:blue/255. alpha:1];
        [array addObject:color];
    }
    return array;
}

+ (NSArray *)colorListForGroupId:(NSInteger)groupId
{
    NSArray *colors = [ColorGroup colorValueForGroupId:groupId];
    if (colors) {
        NSInteger colorArray[COLOR_VALUE_COUNT];
        for (NSInteger j = 0; j < COLOR_VALUE_COUNT; ++ j) {
            colorArray[j] = [(NSNumber *)[colors objectAtIndex:j] intValue];
        }
        NSArray *array = [ColorGroup drawColorListWithColorValues:colorArray];
        return array;
    }
    return nil;
}

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
        PPDebug(@"red = %d,green = %d, blue = %d", red,green,blue);
        [colorView release];
    }
    return array;
}

+ (NSArray *)colorValueForGroupId:(NSInteger)groupId
{
    NSInteger *colorValues = NULL;
    switch (groupId) {
        case PACKAGE_0:
        {
            NSInteger values[] = {58,47,254,47,217,20,250,255,29,230,11,28,248,153,27};
            colorValues = values;
            break;
        }
        case PACKAGE_1:
        {
            NSInteger values[] = {248,220,29,227,125,24,246,98,27,222,51,23,140,0,63};        
            colorValues = values;
            break;            
        }
        case PACKAGE_2:
        {
            NSInteger values[] = {80,182,253,97,214,253,142,254,253,221,231,219,211,198,185};
            colorValues = values;
            break;            
        }
        case PACKAGE_3:
        {
            NSInteger values[] = {231,104,111,243,181,165,252,222,194,192,211,191,124,116,135};
            colorValues = values;
            break;            
        }
        case PACKAGE_4:
        {
            NSInteger values[] = {86,201,199,209,218,84,199,241,254,241,240,222,130,125,98};           
            colorValues = values;
            break;            
        }
        case PACKAGE_5:
        {
            NSInteger values[] = {242,136,31,92,156,173,235,232,212,210,211,213,59,40,100};
            colorValues = values;
            break;            
        }
        case PACKAGE_6:
        {
            NSInteger values[] = {85,60,22,149,156,83,225,255,187,10,27,83,0,50,255};
            colorValues = values;
            break;            
        }
        case PACKAGE_7:
        {
            NSInteger values[] = {187,10,27,128,136,42,78,59,3,15,35,82,17,0,76};
            colorValues = values;
            break;            
        }
        case PACKAGE_8:
        {
            NSInteger values[] = {248,157,179,246,125,186,143,112,184,82,41,96,37,34,95};
            colorValues = values;
            break;            
        }
        case PACKAGE_9:
        {
           NSInteger values[] = {253,233,214,252,221,192,250,168,169,249,157,103,63,139,150};
            colorValues = values;
            break;            
        }
        case PACKAGE_10:
        {
            NSInteger values[] = {184,83,65,153,90,82,183,81,114,231,116,103,247,196,192};
            colorValues = values;
            break;            
        }
        case PACKAGE_11:
        {
            NSInteger values[] = {121,153,189,96,112,140,68,96,123,63,57,51,128,79,82};
            colorValues = values;
            break;            
        }   
            
        case PACKAGE_12:
        {
            NSInteger values[] = {111,111,119,150,79,66,100,70,73,55,74,75,105,124,101};
            colorValues = values;
            break;            
        }
            
        case PACKAGE_13:
        {
            NSInteger values[] = {200,128,71,76,105,179,225,117,138,198,50,100,255,255,255};
            colorValues = values;
            break;            
        }
        case PACKAGE_14:
        {
            NSInteger values[] = {62,255,170,73,251,231,247,0,129,157,124,237,249,223,28} ;
            colorValues = values;
            break;            
        }
        case PACKAGE_15:
        {
            NSInteger values[] = {20,130,2,247,71,26,76,55,138,155,83,48,204,107,38} ;
            colorValues = values;
            break;            
        }  
        case PACKAGE_16:
        {
            NSInteger values[] = {126,130,9,116,158,8,248,129,85,81,127,179,136,199,236} ;
            colorValues = values;
            break;            
        }  
            
        case GRADUAL_GRAY:
        {
            NSInteger values[] = {229,230,231, 208,210,211, 146,148,151, 88,89,91, 35,31,32};
            colorValues = values;
            break;        }
        case GRADUAL_RED:
        {
            NSInteger values[] = {249,218,204,243,173,157,238,135,118,233,92,78,229,28,45};
            colorValues = values;
            break;//red
        }
        case GRADUAL_ORANGE:
        {
            NSInteger values[] = {249,227,174,236,193,123,231,157,109,230,112,55,234,82,25};
            colorValues = values;
            break;//orange
        }
        case GRADUAL_YELLOW:
        {
            NSInteger values[] = {252,250,197,240,220,172,232,199,119,244,200,61,244,185,27};
            colorValues = values;
            break;//yellow
        }
        case GRADUAL_GREEN:
        {
            NSInteger values[] = {201,249,194,144,221,133,92,210,73,60,192,37,33,159,3};
            colorValues = values;
            break;//green
        }
        case GRADUAL_BLUE:
        {
            NSInteger values[] = {159,192,233,121,169,228,95,150,228,55,121,228,44,89,190};
            colorValues = values;
            break;//blue
        }
        case GRADUAL_PURPLE:
        {
            NSInteger values[] = {187,181,237,114,107,161,90,86,140,83,89,169,81,77,130};
            colorValues = values;
            break;
        }
        case GRADUAL_PINK:
        {
            NSInteger values[] = {245,195,216,241,128,175,241,75,144,227,20,108,205,0,82};
            colorValues = values;
            break;//pink
        }
        case GRADUAL_CYAN:
        {
            NSInteger values[] = {205,241,241,160,229,228,113,214,213,70,192,191,50,174,173};
            colorValues = values;
            break;//cyan
        }
        case GRADUAL_BROWN:
        default:
        {
            NSInteger values[] = {205,182,171,187,145,126,168,109,84,136,69,41,91,29,5};
            colorValues = values;
            break;//brown
        }   
    }
    if (colorValues == NULL) {
        return nil;
    }
    NSMutableArray* array = [[[NSMutableArray alloc] initWithCapacity:COLOR_VALUE_COUNT] autorelease];
    for (int i = 0; i<COLOR_VALUE_COUNT; i++) {
        [array addObject:[NSNumber numberWithInt:colorValues[i]]];
    }
    return array;
} 

+ (ColorGroup *)getGroupWithID:(NSInteger)groupId
{
    NSArray *colors = [ColorGroup colorValueForGroupId:groupId];
    NSInteger colorArray[COLOR_VALUE_COUNT];
    for (NSInteger j = 0; j < COLOR_VALUE_COUNT; ++ j) {
        colorArray[j] = [(NSNumber *)[colors objectAtIndex:j] intValue];
    }
    NSArray *array = [ColorGroup colorViewListWithColorValues:colorArray];
    ColorGroup *group = [[[ColorGroup alloc] initWithGroupId:groupId colorViewList:array] autorelease];

//    if ([[AccountService defaultService] hasEnoughItemAmount:group.groupId amount:1]) {
    if ([[UserGameItemService defaultService] hasEnoughItemAmount:group.groupId amount:1]) {
        group.hasBought = YES;
    }else{
        group.hasBought = NO;
    }
    group.price = [[ShoppingManager defaultManager] getColorPrice];
    return group;
}

+ (NSMutableArray *)colorGroupList
{
    NSMutableArray *groupList = [NSMutableArray array];
    for (int i = GRADUAL_START; i < GRADUAL_END; ++ i) {
        ColorGroup *group = [ColorGroup getGroupWithID:i];
        [groupList addObject:group];
        if (i == GRADUAL_GRAY) {
            group.hasBought = YES;
        }
    }
    for (int i = PACKAGE_START; i < PACKAGE_END; ++ i) {
        ColorGroup *group = [ColorGroup getGroupWithID:i];
        [groupList addObject:group];
    }

    return groupList;
}
//+ (ColorGroup *)randomColorGroupForGroupId:(NSInteger)groupId
//{
//    NSInteger randomColorValues[COLOR_VALUE_COUNT];
//    NSMutableArray *colorValues;
//    for (int i = 0; i < COLOR_VALUE_COUNT/RGB_COUNT; i++) {
//        if (groupId+i*RANDOM_OFFSET >= GROUP_COUNT) {
//            colorValues = [ColorGroup colorGroupForGroupId:GROUP_START+groupId+i*RANDOM_OFFSET-GROUP_COUNT];
//        } else {
//            colorValues = [ColorGroup colorGroupForGroupId:groupId+i*RANDOM_OFFSET];
//        }
//        for (int j = 0; j < RGB_COUNT; j++) {
//            randomColorValues[j+i*RGB_COUNT] = [(NSNumber*)[colorValues objectAtIndex:(j+i*RGB_COUNT)] intValue];
//        }
//    }
//    NSArray *array = [ColorGroup colorViewListWithColorValues:randomColorValues];
//    return [[[ColorGroup alloc] initWithGroupId:groupId colorViewList:array] autorelease];
//}


@end
