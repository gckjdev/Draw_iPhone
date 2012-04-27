//
//  ColorGroup.h
//  Draw
//
//  Created by  on 12-4-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
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
