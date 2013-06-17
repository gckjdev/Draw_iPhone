//
//  BuriManager.h
//  Draw
//
//  Created by 王 小涛 on 13-6-3.
//
//

#import <Foundation/Foundation.h>
#import "APLevelDB.h"
#import "BuriBucket.h"

#define BuriBucket(dbName, className) ([[[AllBuriManager defaultManager] buriManager:dbName] bucketWithObjectClass:[className class]])

@interface BuriManager : NSObject

@property (retain, nonatomic) Buri *db;
@property (retain, nonatomic) BuriBucket *bucket;

- (id)initWithDbName:(NSString*)dbName;
- (BuriBucket *)bucketWithObjectClass:(Class)aClass;

@end


@interface AllBuriManager : NSObject

@property (retain, atomic) NSMutableDictionary* allBuriDb;

+ (AllBuriManager*)defaultManager;
- (BuriManager*)buriManager:(NSString*)dbName;

@end
