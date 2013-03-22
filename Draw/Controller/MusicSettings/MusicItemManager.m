//
//  MusicItemManager.m
//  Draw
//
//  Created by gckj on 12-5-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MusicItemManager.h"
#import "LocaleUtils.h"
#import "AudioManager.h"
#import "LocaleUtils.h"
#import "ConfigManager.h"
#import "ASIHTTPRequest.h"
#import "UIUtils.h"

#define KEY_MUSICLIST @"musicList"
#define KEY_CURRENT_MUSIC @"currentMusic"
#define DELIMITER @"$$"

@interface MusicItemManager()

- (MusicItem*) parseMusicItemFromString:(NSString*)str;

@end

@implementation MusicItemManager

@synthesize itemList;
@synthesize currentMusicItem;
@synthesize defaultMusicItem;
@synthesize noneMusicItem;

static MusicItemManager *_defaultManager;

+ (MusicItemManager*)defaultManager
{
    if (_defaultManager == nil){
        _defaultManager = [[MusicItemManager alloc] init];
    }
    
    return _defaultManager;
}

- (void)loadMusicItems
{
    //no music item
    noneMusicItem = [[MusicItem alloc] initWithUrl:@"" fileName:NSLS(@"kNoMusic") filePath:@"" tempPath:@""];
    noneMusicItem.status = [NSNumber numberWithInt:DOWNLOAD_STATUS_FINISH];
    noneMusicItem.downloadProgress = [NSNumber numberWithFloat:1.0f];
    [itemList addObject:noneMusicItem];
    
    //default music item
    NSString* soundFilePath = [[NSBundle mainBundle] pathForResource:@"cannon" ofType:@"mp3"];
    defaultMusicItem = [[MusicItem alloc] initWithUrl:nil fileName:NSLS(@"kDefaultMusic") filePath:soundFilePath tempPath:nil];
    defaultMusicItem.status = [NSNumber numberWithInt:DOWNLOAD_STATUS_FINISH];
    defaultMusicItem.downloadProgress = [NSNumber numberWithFloat:1.0f];
    [itemList addObject:defaultMusicItem];
    
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

- (void)loadCurrentMusic
{
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    NSString *data = [userDefault objectForKey:KEY_CURRENT_MUSIC];
    if (data != nil) {
        MusicItem *item = [self parseMusicItemFromString:data];
        self.currentMusicItem = item;
    }
    
    if (self.currentMusicItem == nil) {
        if ([ConfigManager isInReviewVersion] == YES){
            self.currentMusicItem = noneMusicItem;
        }
        else{
            self.currentMusicItem = defaultMusicItem;
        }
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        
        self.itemList = [[[NSMutableArray alloc] init] autorelease];
        [self loadMusicItems];
        [self loadCurrentMusic];
    }
    return self;
}

- (void)dealloc
{
    [itemList release];
    [currentMusicItem release];
    [defaultMusicItem release];
    [noneMusicItem release];
    
    [super dealloc];
}

- (MusicItem*) parseMusicItemFromString:(NSString*)str
{
    if (str == nil)
        return nil;
    
    NSMutableString *string = [[[NSMutableString alloc] initWithString:str] autorelease];
    NSArray *array = [string componentsSeparatedByString:DELIMITER];
    if ([array count] < 6)
        return nil;
    
    NSString *fileName = [array objectAtIndex:0];
    NSString *url = [array objectAtIndex:1];
    NSString *localPath = [array objectAtIndex:2];
    NSString *tempPath = [array objectAtIndex:3];
    NSString *statusString = [array objectAtIndex:4];
    NSString *downloadProgress = [array objectAtIndex:5];
    MusicItem *item = [[[MusicItem alloc] initWithUrl:url fileName:fileName filePath:localPath tempPath:tempPath] autorelease];
    item.downloadProgress = [NSNumber numberWithLongLong:[downloadProgress longLongValue]];
    item.status = [NSNumber numberWithInt:[statusString intValue]];

    return item;
}


- (void)saveMusicItems
{        
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];

    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (MusicItem *item in self.itemList) {
        //do not save default and no into UserDefaults
        if (item == defaultMusicItem || item == noneMusicItem) {
            continue;
        }
        
        NSMutableString *itemString = [[NSMutableString alloc]init];
        [itemString appendFormat:@"%@%@%@%@%@%@%@%@%@%@%@", 
                        item.fileName, DELIMITER, 
                        item.url, DELIMITER, 
                        item.localPath, DELIMITER, 
                        item.tempPath, DELIMITER, 
                        [item.status stringValue], DELIMITER, 
                        [item.downloadProgress stringValue]];
        
        [list addObject:itemString];
        [itemString release];

    }
    
    [userDefaults setObject: list forKey:KEY_MUSICLIST];
    [list release];
    [userDefaults synchronize];
    
}

- (void)saveCurrentMusic
{        
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    
    NSMutableString *itemString = [[NSMutableString alloc]init];
    [itemString appendFormat:@"%@%@%@%@%@%@%@%@%@%@%@", 
         currentMusicItem.fileName, DELIMITER, 
         currentMusicItem.url, DELIMITER, 
         currentMusicItem.localPath, DELIMITER, 
        currentMusicItem.tempPath, DELIMITER, 
         [currentMusicItem.status stringValue],DELIMITER,
         [currentMusicItem.downloadProgress stringValue]];
        
    [userDefaults setObject: itemString forKey:KEY_CURRENT_MUSIC];
    [userDefaults synchronize];
    [itemString release];

}

- (BOOL)isCurrentMusic:(MusicItem*)item
{
    return [item.fileName isEqualToString:currentMusicItem.fileName];
}

- (BOOL)isNoneOrDefaultMusic:(MusicItem*)item
{
    return item == noneMusicItem || item == defaultMusicItem;
}

- (void)saveItem:(MusicItem*)item
{
    if (itemList != nil && [itemList indexOfObject:item] != -1) {
        [itemList removeObject:item];
    }
    [itemList addObject:item];
}

- (void)removeFile:(MusicItem*)item
{
    NSFileManager *manager = [NSFileManager defaultManager];
    if([manager fileExistsAtPath:item.tempPath]){
        [manager removeItemAtPath:item.tempPath error:nil];
    }
    if ([manager fileExistsAtPath:item.localPath]) {
        [manager removeItemAtPath:item.localPath error:nil];
    }
    
    [[item request] clearDelegatesAndCancel];
    
}

- (void)deleteItem:(MusicItem*)item
{
    if (itemList != nil && [itemList indexOfObject:item] != -1) {
        [itemList removeObject:item];
        //delete file 
        [self removeFile:item];        
        [self saveMusicItems];
    }
}

- (NSArray*) findAllItems
{   
    return itemList;
}

- (NSArray*)findAllItemsByStatus:(int)status
{
    NSMutableArray *retList = [[[NSMutableArray alloc] init] autorelease];
    for (MusicItem *item in itemList) {
        if (item.status.intValue == status) {
            [retList addObject:item];
        }
    }
    return retList;
}

- (void)setFileInfo:(MusicItem*)item newFileName:(NSString*)fileName fileSize:(long)fileSize
{
    [itemList removeObject:item];
    item.fileName = fileName;
    item.fileSize = [NSNumber numberWithLong:fileSize];
    [itemList addObject:item];
}

//select current background Music to play
- (void)selectCurrentMusicItem:(MusicItem*)item
{
    if (item.downloadProgress.floatValue < 1.0) {
        return;
    }
    if (self.currentMusicItem != item) {
        self.currentMusicItem = item;
        [self saveCurrentMusic];

    }
    AudioManager *audioManager = [AudioManager defaultManager];
    if (currentMusicItem == noneMusicItem) {
        [audioManager setIsMusicOn:NO];
    }
    else {
        [audioManager setIsMusicOn:YES];
//        NSURL *url = [NSURL fileURLWithPath:self.currentMusicItem.localPath];
//        if([audioManager setBackGroundMusicWithURL:url]){
//            [audioManager backgroundMusicStart];
//        }
//        else {
            [UIUtils alert:NSLS(@"kMusicWrong")];
//        }
    }
}

#pragma STATUS CONTROL
- (void)downloadFinish:(MusicItem*)item
{
    [item setRequest:nil];
    [item setStatus:[NSNumber numberWithInt:DOWNLOAD_STATUS_FINISH]];
    [item setDownloadProgress:[NSNumber numberWithFloat:1.0]];
    [self saveItem:item];

}

- (void)downloadFailure:(MusicItem*)item
{
    [item setRequest:nil];
    [item setStatus:[NSNumber numberWithInt:DOWNLOAD_STATUS_FAIL]];
    [self saveItem:item];

}

- (void)downloadStart:(MusicItem*)item request:(ASIHTTPRequest*)request
{
    [item setRequest:request];
    [item setStatus:[NSNumber numberWithInt:DOWNLOAD_STATUS_STARTED]];
}

@end
