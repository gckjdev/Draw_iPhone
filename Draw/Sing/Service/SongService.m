//
//  SongService.m
//  Draw
//
//  Created by 王 小涛 on 13-6-17.
//
//

#import "SongService.h"
#import "SynthesizeSingleton.h"
#import "PPGameNetworkRequest.h"
#import "GameNetworkRequest.h"
#import "CommonNetworkClient.h"
#import "UserManager.h"
#import "ConfigManager.h"
#import "GameNetworkConstants.h"
#import "StringUtil.h"


@implementation SongService

SYNTHESIZE_SINGLETON_FOR_CLASS(SongService);

- (void)randomSongsWithPara:(NSDictionary *)para
                  completed:(GetSongsCompleted)completed{
        
    dispatch_async(workingQueue, ^{
                
        GameNetworkOutput* output = [PPGameNetworkRequest trafficApiServerGetAndResponsePB:METHOD_RANDOM_GET_SONGS parameters:para];
        
        PPDebug(@"%@", output.description);
        
        int resultCode = output.resultCode;

        NSArray *songs = nil;
        
        if (resultCode == ERROR_SUCCESS) {
            resultCode = output.pbResponse.resultCode;
            if (resultCode == 0) {
                songs = output.pbResponse.songs.songsList;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            EXECUTE_BLOCK(completed, resultCode, songs);
        });
    });
}

- (void)randomSongs:(int)count
          completed:(GetSongsCompleted)completed{
    
    NSDictionary *para = @{PARA_USERID : [[UserManager defaultManager] userId],
                           PARA_APPID : [ConfigManager appId],
                           PARA_COUNT : [NSString stringWithInt:count]
                           };
    
    [self randomSongsWithPara:para completed:completed];
}

- (void)randomSongsWithTag:(NSString *)tag
                     count:(int)count
                 completed:(GetSongsCompleted)completed{
    
    if (tag == nil) {
        return [self randomSongs:count completed:completed];
    }
    
    NSDictionary *para = @{PARA_USERID : [[UserManager defaultManager] userId],
                           PARA_APPID : [ConfigManager appId],
                           PARA_COUNT : [NSString stringWithInt:count],
                           PARA_SUB_CATEGORY : tag
                           };
    
    [self randomSongsWithPara:para
                    completed:completed];
}

- (void)searchSongWithName:(NSString *)name
                 completed:(GetSongsCompleted)completed{
        
    dispatch_async(workingQueue, ^{
        
        NSDictionary *para = @{
                               PARA_KEYWORD : (name == nil ? @"" : name)
                               };
        
        GameNetworkOutput* output = [PPGameNetworkRequest trafficApiServerGetAndResponsePB:METHOD_SEARCH_SONG parameters:para];
        
        PPDebug(@"%@", output.description);
        
        int resultCode = output.resultCode;
        
        NSArray *songs = nil;
        
        if (resultCode == ERROR_SUCCESS) {
            resultCode = output.pbResponse.resultCode;
            if (resultCode == 0) {
                songs = output.pbResponse.songs.songsList;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            EXECUTE_BLOCK(completed, resultCode, songs);
        });
    });
 
}

@end
