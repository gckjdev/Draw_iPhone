//
//  SongManager.h
//  Draw
//
//  Created by 王 小涛 on 13-5-24.
//
//

#import <Foundation/Foundation.h>
#import "Sing.pb.h"

@interface SongManager : NSObject

+ (id)defaultManager;

- (PBSong *)songWithSongId:(NSString *)songId;

- (NSArray *)randomSongsWithCount:(int)count;

- (NSArray *)randomSongsWithTag:(int)tag
                          count:(int)count;

+ (PBSong *)testSong;

@end
