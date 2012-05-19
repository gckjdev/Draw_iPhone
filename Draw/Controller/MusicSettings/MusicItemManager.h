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
@property (nonatomic, retain) MusicItem *defaultMusicItem;
@property (nonatomic, retain) MusicItem *noneMusicItem;

+ (MusicItemManager*)defaultManager;

- (NSArray*) findAllItems;
- (void)saveMusicItems;

- (void)saveItem:(MusicItem*)item;
- (void)deleteItem:(MusicItem*)item;
- (void)setFileInfo:(MusicItem*)item newFileName:(NSString*)fileName fileSize:(long)fileSize;
- (void)selectCurrentMusicItem:(MusicItem*)item;

- (void)saveCurrentMusic;
- (BOOL)isCurrentMusic:(MusicItem*)item;
- (BOOL)isNoneOrDefaultMusic:(MusicItem*)item;
@end
