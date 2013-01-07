//
//  DrawColorManager.h
//  Draw
//
//  Created by gamy on 13-1-5.
//
//

#import <Foundation/Foundation.h>
#import "DrawColor.h"

@interface DrawColorManager : NSObject

+ (id)sharedDrawColorManager;
- (NSArray *)recentColorList;
- (void)updateColorListWithColor:(DrawColor *)color;
- (void)syncRecentList;


- (NSArray *)boughtColorList;
- (void)addBoughtColorList:(NSArray *)list;
- (NSArray *)boughtColorListWithOffset:(NSUInteger)offset limit:(NSUInteger)limit;
@end
