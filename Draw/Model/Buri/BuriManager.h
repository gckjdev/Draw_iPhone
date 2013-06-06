//
//  BuriManager.h
//  Draw
//
//  Created by 王 小涛 on 13-6-3.
//
//

#import <Foundation/Foundation.h>
#import "BuriBucket.h"

#define BuriBucket(x) ([[BuriManager  defaultManager] bucketWithObjectClass:[x class]])

@interface BuriManager : NSObject

@property (retain, nonatomic) Buri *db;

+ (id)defaultManager;
- (BuriBucket *)bucketWithObjectClass:(Class)aClass;

@end
