//
//  StorageManager.m
//  Draw
//
//  Created by  on 12-11-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "StorageManager.h"
#import "UIImageExt.h"
#import "FileUtil.h"

static StorageManager *_staticStorageManager = nil;

@implementation StorageManager
@synthesize storageType = _storageType;
@synthesize directoryName = _directoryName;


- (void)dealloc
{
    PPRelease(_directoryName);
    [super dealloc];
}

- (NSString *)rootDirectory
{
    switch (_storageType) {
        case StorageTypeCache:
            return [FileUtil getAppCacheDir];
        case StorageTypePersistent:
            return [FileUtil getAppHomeDir];
        case StorageTypeTemp:
            return [FileUtil getAppTempDir];
        default:
            PPDebug(@"<rootDirectory> is nil, storageType = %d", _storageType);
            return nil;
    }
}
- (NSString *)currentDirectory
{
    NSString *dir = [self rootDirectory];
    if ([dir length] != 0 && [_directoryName length] != 0) {
        dir = [dir stringByAppendingPathComponent:_directoryName];
        if([FileUtil createDir:dir]){
            return dir;
        }
    }
    PPDebug(@"<path> is nil, directoryName = %@", _directoryName);
    return nil;
}


//Relative path below root directory(Document/Library/Temp)
- (NSString *)relativePathWithKey:(NSString *)key
{
    return [_directoryName stringByAppendingPathComponent:key];
}
- (NSString *)fullPathWithRelativePath:(NSString *)relativePath
{
    return [[self rootDirectory] stringByAppendingPathComponent:relativePath];
}


#define DEFAULT_DIR @"default"

+ (id)defaultManager
{
    static dispatch_once_t onceStorageManagerToken;
    dispatch_once(&onceStorageManagerToken, ^{
        if (_staticStorageManager == nil) {
            _staticStorageManager = [[StorageManager alloc] init];
        }        
    });
    [_staticStorageManager setStorageType:StorageTypeCache];
    [_staticStorageManager setDirectoryName:DEFAULT_DIR];
    return _staticStorageManager;
}

- (id)initWithStoreType:(StorageType)type 
          directoryName:(NSString *)directoryName
{
    self = [super init];
    if (self) {
        self.storageType = type;
        self.directoryName = directoryName;
    }
    return self;
}

- (NSString *)pathWithKey:(NSString *)key
{
    NSString *dir = [self currentDirectory];
    if ([dir length] != 0) {
        return [dir stringByAppendingPathComponent:key];
    }
    return nil;
}

- (BOOL)saveData:(NSData *)data forKey:(NSString *)key
{
    if ([key length] == 0 || data == nil) {
        return NO;
    }
    NSString *path = [self pathWithKey:key];
    if ([path length] != 0) {
        return [data writeToFile:path atomically:YES];        
    }else{
        PPDebug(@"<saveData:forKey:> path is nil! fail to save");
        return NO;
    }
}
- (NSData *)dataForKey:(NSString *)key
{
    if ([key length] != 0) {
        NSString *path = [self pathWithKey:key];
        if ([path length] != 0) {
            return [NSData dataWithContentsOfFile:path];
        }
    }
    return nil;
}

//The object or array should implement the NSCoding protocal
- (BOOL)saveObject:(NSObject *)object forKey:(NSString *)key
{
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:object];
    BOOL flag = [self saveData:data forKey:key];
    data = nil;
    return flag;
}
- (id)objectForKey:(NSString *)key
{
    NSData *data = [self dataForKey:key];
    if (data) {
        NSObject *obj = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        data = nil;
        return obj;
    }
    return nil;
}

- (BOOL)saveImage:(UIImage *)image forKey:(NSString *)key
{
    NSData *imageData = [image data];
    BOOL flag =[self saveData:imageData forKey:key];
    imageData = nil;
    return flag;
}
- (UIImage *)imageForKey:(NSString *)key
{
    NSString *path = [self pathWithKey:key];
    return [UIImage imageWithContentsOfFile:path];
}

- (BOOL)removeAllData //remove all the data below the directory. use be careful...
{
    return [FileUtil removeFile:[self currentDirectory]];
}


- (NSInteger)numberOfFiles
{
    return [FileUtil numberOfFilesBelowDir:[self currentDirectory]];
}

- (BOOL)removeDataForKey:(NSString *)key
{
    NSString *path = [self pathWithKey:key];
    return [FileUtil removeFile:path];
}

- (BOOL)removeOldFilestimeIntervalSinceNow:(NSTimeInterval)timeInterval
{
    NSString *dir = [self currentDirectory];
    PPDebug(@"<removeOldFilestimeIntervalSinceNow> start to delete files below %@, interval = %lf",dir,timeInterval);
    return [FileUtil removeFilesBelowDir:[self currentDirectory] timeIntervalSinceNow:timeInterval];
}


//- (NSString *)currentDirPath
//{
//    return [self currentDirectory];
//}
//- (NSString *)filePathForFileName:(NSString *)fileName;


@end
