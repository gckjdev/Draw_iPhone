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
#import "PPConfigManager.h"
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
                songs = output.pbResponse.songs.songs;
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
                           PARA_APPID : [PPConfigManager appId],
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
                           PARA_APPID : [PPConfigManager appId],
                           PARA_COUNT : [NSString stringWithInt:count],
                           PARA_SUB_CATEGORY : tag
                           };
    
    [self randomSongsWithPara:para
                    completed:completed];
}

- (void)searchSongWithName:(NSString *)name
                    offset:(NSInteger)offset
                     limit:(NSInteger)limit
                 completed:(GetSongsCompleted)completed{
        
    dispatch_async(workingQueue, ^{
        
        NSDictionary *para = @{
                               PARA_KEYWORD : (name == nil ? @"" : name),
                               PARA_OFFSET : @(offset),
                               PARA_LIMIT : @(limit),
                               };
        
        GameNetworkOutput* output = [PPGameNetworkRequest trafficApiServerGetAndResponsePB:METHOD_SEARCH_SONG parameters:para];
        
        PPDebug(@"%@", output.description);
        
        int resultCode = output.resultCode;
        
        NSArray *songs = nil;
        
        if (resultCode == ERROR_SUCCESS) {
            resultCode = output.pbResponse.resultCode;
            if (resultCode == 0) {
                songs = output.pbResponse.songs.songs;
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            EXECUTE_BLOCK(completed, resultCode, songs);
//            EXECUTE_BLOCK(completed, 0, [SongService testSongs]);
        });
    });
}

+ (NSArray *)testSongs{
    
    PBSong *song1 = [self songWithName:@"爱你一万年" author:@"刘德华" lyric:@"爱你一万年歌词\n------爱你一万年------\n主唱、填词：刘德华\n\n作曲:Giorgio Moroden/刘德华、陈德建\n地球自转一次是一天\n那是代表多想你一天\n真善美的爱恋\n没有极限 也没有缺陷\n地球公转一次是一年\n那是代表多爱你一年\n恒久的地平线\n和我的心 永不改变\n爱你一万年\n爱你经得起考验\n飞越了时间的局限\n拉近了地域的平面\n紧紧的相连\n紧紧相连\nmusic\n有了你的出现\n占据了一切我的视线\n我爱你一万年"];
    
    PBSong *song2 = [self songWithName:@"情书" author:@"张学友" lyric:@"歌曲：情书\n歌手：张学友 专辑：jacky cheung 15\n你瘦了憔悴得让我好心疼\n有时候爱情比时间还残忍\n把人变得盲目而奋不顾身\n忘了爱要两个同样用心的人\n你醉了脆弱得藏不住泪痕\n我知道绝望比冬天还寒冷\n你恨自己是个怕孤独的人\n偏偏又爱上自由自私的灵魂\n你带着它唯一写过的情书\n想证明当初爱得并不糊涂\n他曾为了你的逃离颓废痛苦\n也为了破镜重圆抱着你哭\n哦可惜爱不是几滴眼泪几封情书哦---\n这样的话或许有点残酷\n等待着别人给幸福的人\n往往过的都不怎么幸福\n哦可惜爱不是忍着眼泪留着情书哦---\n伤口清醒要比昏迷痛楚\n禁闭着双眼又拖着错误\n真爱来临时你要怎么留得住"];
    
    NSArray *arr = @[song1, song2];
    return arr;
}

+ (PBSong *)songWithName:(NSString *)name author:(NSString *)author lyric:(NSString *)lyric{
    
    NSString *uuid = [NSString GetUUID];
    
    
    PBSongBuilder *builder = [[[PBSongBuilder alloc] init] autorelease];
    [builder setSongId:uuid];
    [builder setName:name];
    [builder setAuthor:author];
    [builder setLyric:lyric];
    
    return [builder build];
}

@end
