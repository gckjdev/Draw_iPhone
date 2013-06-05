//
//  BuriManager.h
//  Draw
//
//  Created by 王 小涛 on 13-6-3.
//
//

#import <Foundation/Foundation.h>
#import "BuriBucket.h"

@interface BuriManager : NSObject

@property (retain, nonatomic) Buri *db;

+ (id)defaultManager;
- (BuriBucket *)createBucketWithObjectClass:(Class)class;

@end
