//
//  ColorGroup.h
//  Draw
//
//  Created by  on 12-4-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ItemType.h"
#define PACKAGE_START (ItemTypeColor + 1)
#define GRADUAL_START (200)

/*
{229,230,231,208,210,211,146,148,151,88,89,91,35,31,32}; //gray
{249,218,204,243,173,157,238,135,118,233,92,78,229,28,45};//red
{249,227,174,236,193,123,231,157,109,230,112,55,234,82,25};//orange
{252,250,197,240,220,172,232,199,119,244,200,61,244,185,27};//yellow
{201,249,194,144,221,133,92,210,73,60,192,37,33,159,3};//green
{159,192,233,121,169,228,95,150,228,55,121,228,44,89,190};//blue
{187,181,237,114,107,161,90,86,140,83,89,169,81,77,130};purple
{245,195,216,241,128,175,241,75,144,227,20,108,205,0,82};//pink
{205,241,241,160,229,228,113,214,213,70,192,191,50,174,173};//cyan
{205,182,171,187,145,126,168,109,84,136,69,41,91,29,5};//brown
 */


enum{
    
//    package color    
    PACKAGE_16 = PACKAGE_START,
    PACKAGE_3,
    PACKAGE_14,
    PACKAGE_8,
    PACKAGE_1,
    PACKAGE_12,
    PACKAGE_10,
    PACKAGE_2,
    PACKAGE_7,
    PACKAGE_9,
    PACKAGE_0,
    PACKAGE_6,
    PACKAGE_4,
    PACKAGE_5,
    PACKAGE_15,
    PACKAGE_13,
    PACKAGE_11,
    //new package
    
    PACKAGE_END,
    
    
//    Gradual Color
    
    GRADUAL_BROWN = GRADUAL_START,
    GRADUAL_CYAN,
    GRADUAL_PINK,
    GRADUAL_PURPLE,
    GRADUAL_BLUE,
    GRADUAL_GREEN,
    GRADUAL_YELLOW,
    GRADUAL_ORANGE,
    GRADUAL_RED,
    GRADUAL_GRAY, 
    GRADUAL_END,
};

@class ColorView;
@interface ColorGroup : NSObject
{
    NSInteger _groupId;
    NSArray *_colorViewList;
    NSInteger _price;
}

@property(nonatomic, assign) NSInteger groupId;
@property(nonatomic, retain) NSArray *colorViewList;
@property(nonatomic, assign) NSInteger price;
@property(nonatomic, assign) BOOL hasBought;
- (NSInteger)colorViewCount;
- (id)initWithGroupId:(NSInteger)groupId 
        colorViewList:(NSArray *)colorViewList;

- (id)initWithGroupId:(NSInteger)groupId 
        colorViewList:(NSArray *)colorViewList 
            hasBought:(BOOL)hasBought;

+ (NSArray *)colorListForGroupId:(NSInteger)groupId;

+ (NSMutableArray *)colorGroupList;
@end
