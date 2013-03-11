//
//  CacheManager.h
//  Draw
//
//  Created by Kira on 13-3-9.
//
//

#import <Foundation/Foundation.h>

@interface CacheManager : NSObject

+ (CacheManager*)defaultManager;
- (void)removeCachePathsArray:(NSArray*)pathsArray
                    succBlock:(void (^)(long long fileSize))succBlock;

@end
