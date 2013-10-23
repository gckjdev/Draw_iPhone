//
//  SongService.h
//  Draw
//
//  Created by 王 小涛 on 13-6-17.
//
//

#import <Foundation/Foundation.h>
#import "CommonService.h"
#import "Opus.pb.h"

typedef void (^GetSongsCompleted)(int resultCode, NSArray *songs);

@interface SongService : CommonService

+ (id)defaultService;

- (void)randomSongs:(int)count
          completed:(GetSongsCompleted)completed;

- (void)randomSongsWithTag:(NSString *)tag
                     count:(int)count
                 completed:(GetSongsCompleted)completed;

- (void)searchSongWithName:(NSString *)name
                 completed:(GetSongsCompleted)completed;

@end
