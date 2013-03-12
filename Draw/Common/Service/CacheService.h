//
//  CacheService.h
//  Draw
//
//  Created by Kira on 13-3-9.
//
//

#import "CommonService.h"

@interface CacheService : CommonService

- (void)cleanDrawCacheSuccBlock:(void (^)(void))succBlock
                      failBlock:(void (^)(void))failBlock;

@end
