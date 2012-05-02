//
//  ColorGroup.h
//  Draw
//
//  Created by  on 12-4-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#define GROUP_START 101

enum{
    GROUP_GRAY = GROUP_START,
    GROUP_DARK_BLUE,
    GROUP_SKY_BLUE,
    GROUP_BLUE,
    GROUP_LIGHT_BLUE,
    GROUP_BRIGHT_BLUE,
    
    GROUP_PURPLE,
    GROUP_PINK_PURPLE,
    GROUP_PINK,
    GROUP_LIGHT_PINK,
    
    GROUP_ORANGE,
    GROUP_DARK_ORANGE,
    GROUP_LIGHT_ORANGE,
    
    GROUP_TREE,
    GROUP_GRAY_GREEN,
    GROUP_BRIGHT_GREEN,
    GROUP_BROWN,
    GROUP_COUNT
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
+ (ColorGroup *)colorGroupForGroupId:(NSInteger)groupId;

@end
