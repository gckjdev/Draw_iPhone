//
//  CacheManager.m
//  Draw
//
//  Created by Kira on 13-3-9.
//
//

#import "CacheManager.h"
#import "FileUtil.h"
#import "SynthesizeSingleton.h"


@implementation CacheManager

SYNTHESIZE_SINGLETON_FOR_CLASS(CacheManager)

- (void)removeCachePathsArray:(NSArray*)pathsArray
                    succBlock:(void (^)(long long fileSize))succBlock
{
    long long fileSize = 0;
    for (NSString* path in pathsArray) {
        NSString* cachePath = [NSString stringWithFormat:@"%@/%@",[FileUtil getAppCacheDir], path];
        fileSize += [FileUtil clearOnlyFilesAtPath:cachePath];
        
    }
    EXCUTE_BLOCK(succBlock, fileSize);
}

@end
