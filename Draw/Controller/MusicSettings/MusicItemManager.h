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

@property (nonatomic, retain) NSMutableArray *itemList;
@property (nonatomic, retain) MusicItem *currentMusicItem;


+ (MusicItemManager*)defaultManager;

- (void)saveItem:(MusicItem*)item;
- (NSArray*) findAllItems;
- (void)saveMusicItems;
- (void)deleteItem:(MusicItem*)item;
@end
