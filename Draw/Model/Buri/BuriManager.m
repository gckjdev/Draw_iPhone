//
//  BuriManager.m
//  Draw
//
//  Created by 王 小涛 on 13-6-3.
//
//

#import "BuriManager.h"
#import "BuriSerialization.h"
#import "Buri.h"
#import "FileUtil.h"
#import "SynthesizeSingleton.h"

#import "SingOpus.h"

#define BURI_DB_DIR   @"buri_db"

@interface BuriManager()


@end

@implementation BuriManager

- (id)initWithDbName:(NSString*)dbName
{
    self = [super init];
    NSString* dir = [FileUtil filePathInAppDocument:BURI_DB_DIR];
    [FileUtil createDir:dir];    
    NSString* path = [NSString stringWithFormat:@"%@/%@", BURI_DB_DIR, dbName];
    self.db = [Buri databaseInLibraryWithName:path];
    self.bucket = [[[BuriBucket alloc] initWithDB:_db andObjectClass:[SingOpus class]] autorelease];

    return self;
}

- (void)dealloc{

    PPRelease(_bucket);
    PPRelease(_db);
    [super dealloc];
}

- (BuriBucket *)bucketWithObjectClass:(Class)aClass{
    return _bucket;
}



@end

@implementation AllBuriManager

SYNTHESIZE_SINGLETON_FOR_CLASS(AllBuriManager)

- (id)init
{
    self = [super init];
    _allBuriDb = [[NSMutableDictionary alloc] init];
    return self;
}

- (BuriManager*)buriManager:(NSString*)dbName
{
    if ([dbName length] == 0)
        return nil;
    
    BuriManager* manager = [_allBuriDb objectForKey:dbName];
    if (manager != nil)
        return manager;
    
    manager = [[BuriManager alloc] initWithDbName:dbName];
    [_allBuriDb setObject:manager forKey:dbName];
    [manager release];
    
    return manager;
}

@end
