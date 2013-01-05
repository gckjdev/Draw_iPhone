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


- (NSArray *)getRecentColorList;
- (void)setRecentColorList:(NSArray *)list;
- (void)updateColorListWithColor:(DrawColor *)color;

@end
