//
//  MusicItemManager.h
//  Draw
//
//  Created by gckj on 12-5-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MusicItem.h"

@interface MusicItemManager : NSObject

+ (void)saveItem:(MusicItem*)item;
+ (NSArray*) findAllItems;

@end
