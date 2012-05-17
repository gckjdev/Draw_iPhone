//
//  MusicItemManager.m
//  Draw
//
//  Created by gckj on 12-5-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MusicItemManager.h"
#import "LocaleUtils.h"

#define KEY_MUSICLIST @"musicList"
#define DELIMITER @"$$"


@implementation MusicItemManager
@synthesize itemList;
@synthesize currentMusicItem;

static MusicItemManager *_defaultManager;

+ (MusicItemManager*)defaultManager
{
    if (_defaultManager == nil){
        _defaultManager = [[MusicItemManager alloc] init];
    }
    
    return _defaultManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        self.itemList = [[NSMutableArray alloc] init];
        [self loadMusicItems];
        
        NSString* soundFilePath = [[NSBundle mainBundle] pathForResource:@"cannon" ofType:@"mp3"];
        currentMusicItem = [[MusicItem alloc] initWithUrl:nil fileName:NSLS(@"cannon.mp3") filePath:soundFilePath tempPath:nil];
        [itemList addObject:currentMusicItem];
    }
    return self;
}

- (void)dealloc
{
    [self.itemList release];
    [super dealloc];
}

- (MusicItem*) parseMusicItemFromString:(NSString*)str
{
    NSMutableString *string = [[NSMutableString alloc] initWithString:str];
    NSArray *array = [string componentsSeparatedByString:DELIMITER];
    
    NSString *fileName = [array objectAtIndex:0];
    NSString *url = [array objectAtIndex:1];
    NSString *localPath = [array objectAtIndex:2];
    NSString *downloadProgress = [array objectAtIndex:3];
    MusicItem *item = [[MusicItem alloc] initWithUrl:url fileName:fileName filePath:localPath tempPath:nil];
    item.downloadProgress = [NSNumber numberWithLongLong:[downloadProgress longLongValue]];
    return item;
}

- (void)loadMusicItems
{
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    NSArray *data = [userDefault arrayForKey:KEY_MUSICLIST];
    if (data != nil) {
        for (NSString* str in data) {
            MusicItem *item = [self parseMusicItemFromString:str];
            if ([self.itemList indexOfObject:item] != -1) {
                [self.itemList addObject:item];
            }
        }
    }
}

- (void)saveMusicItems
{        
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (MusicItem *item in self.itemList) {
        if ([item.fileName isEqualToString:@"cannon.mp3"]) {
            return;
        }
        NSMutableString *itemString = [[NSMutableString alloc]init];
        [itemString appendFormat:@"%@%@%@%@%@%@%@", 
                        item.fileName, DELIMITER, 
                        item.url, DELIMITER, 
                        item.localPath, DELIMITER, 
                        [item.downloadProgress stringValue]];
        
        [list addObject:itemString];
        [itemString release];

    }
    
    [userDefaults setObject: list forKey:KEY_MUSICLIST];
    [list release];
    
}


- (void)saveItem:(MusicItem*)item
{
    [itemList addObject:item];
}

- (void)deleteItem:(MusicItem*)item
{
    if (itemList != nil && [itemList indexOfObject:item] != -1) {
        [itemList removeObject:item];
        [self removeFile:item];
    }
}

- (void)setFileInfo:(MusicItem*)item newFileName:(NSString*)fileName fileSize:(long)fileSize
{
    [itemList removeObject:item];
    item.fileName = fileName;
    item.fileSize = [NSNumber numberWithLong:fileSize];
    [itemList addObject:item];
}


- (void)removeFile:(MusicItem*)item
{
    NSFileManager *manager = [NSFileManager defaultManager];
    [manager removeItemAtPath:item.localPath error:nil];
}

- (NSArray*) findAllItems
{   
    return itemList;
}

@end
