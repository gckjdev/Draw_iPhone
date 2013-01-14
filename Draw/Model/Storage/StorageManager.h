//
//  StorageManager.h
//  Draw
//
//  Created by  on 12-11-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    StorageTypeTemp = 1, //store in system temp directory 
    StorageTypePersistent = 2, //store in document directory 
    StorageTypeCache = 3, //store in library directory
}StorageType;

@interface StorageManager : NSObject
{
    StorageType _storageType;
    NSString *_directoryName;
}

@property(atomic, assign)StorageType storageType; //default type is StorageTypeCache
@property(atomic, retain)NSString *directoryName;

+ (id)defaultManager; //StorageTypeCache type, dir name is default

//full path
- (NSString *)pathWithKey:(NSString *)key;
- (NSString *)currentDirectory;


//Relative path below root directory(Document/Library/Temp)
- (NSString *)relativePathWithKey:(NSString *)key;
- (NSString *)fullPathWithRelativePath:(NSString *)relativePath;

- (id)initWithStoreType:(StorageType)type
          directoryName:(NSString *)directoryName;
- (BOOL)saveData:(NSData *)data forKey:(NSString *)key;
- (NSData *)dataForKey:(NSString *)key;

//The object or array should implement the NSCoding protocal
- (BOOL)saveObject:(NSObject *)object forKey:(NSString *)key;
- (id)objectForKey:(NSString *)key;

- (BOOL)saveImage:(UIImage *)image forKey:(NSString *)key;
- (UIImage *)imageForKey:(NSString *)key;

- (BOOL)removeAllData; //remove all the data below the directory. use be careful...

- (BOOL)removeDataForKey:(NSString *)key;
- (BOOL)removeOldFilestimeIntervalSinceNow:(NSTimeInterval)timeInterval;

- (NSInteger)numberOfFiles;
@end
