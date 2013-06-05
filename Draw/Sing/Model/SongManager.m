//
//  SongManager.m
//  Draw
//
//  Created by 王 小涛 on 13-5-24.
//
//

#import "SongManager.h"
#import "SynthesizeSingleton.h"

#define SONG_FILE_NAME  @"songs.pb"
#define SONG_FILE_VERSION @"1.0"

@interface SongManager()
@property (retain, nonatomic) NSMutableDictionary *songsDic;
@property (retain, nonatomic) PPSmartUpdateData *smartData;

@end

@implementation SongManager

SYNTHESIZE_SINGLETON_FOR_CLASS(SongManager);

- (void)dealloc{
    
    [_songsDic release];
    [super dealloc];
}

- (id)init{
    
    if (self = [super init]) {
        
        self.songsDic = [NSMutableDictionary dictionary];

//        self.smartData = [[[PPSmartUpdateData alloc] initWithName:SONG_FILE_NAME type:SMART_UPDATE_DATA_TYPE_PB bundlePath:SONG_FILE_NAME initDataVersion:SONG_FILE_VERSION] autorelease];
        
        [self createTestData];
    }
    
    return self;
}

- (void)syncData
{    
    __block typeof(self) bself = self;
    
    [_smartData checkUpdateAndDownload:^(BOOL isAlreadyExisted, NSString *dataFilePath) {
        PPDebug(@"getIngotsList successfully");
        NSData *data = [NSData dataWithContentsOfFile:dataFilePath];
        NSArray *songsList = [[PBSongList parseFromData:data] songsList];
        [bself.songsDic removeAllObjects];
        for (PBSong *song in songsList) {
            [bself.songsDic setObject:song forKey:song.songId];
        }
        
    } failureBlock:^(NSError *error) {
        PPDebug(@"getIngotsList failure error=%@", [error description]);
        NSData *data = [NSData dataWithContentsOfFile:bself.smartData.dataFilePath];
        NSArray *songsList = [[PBSongList parseFromData:data] songsList];
        [bself.songsDic removeAllObjects];
        for (PBSong *song in songsList) {
            [bself.songsDic setObject:song forKey:song.songId];
        }
    }];
}

- (PBSong *)songWithSongId:(NSString *)songId{
    return [_songsDic objectForKey:songId];
}

- (NSArray *)randomSongsWithCount:(int)count{
    
    NSMutableArray *songs = [NSMutableArray array];
    for (NSString *key in [_songsDic allKeys]) {
        [songs addObject:[_songsDic objectForKey:key]];
    }
    
    NSMutableArray *resultSongs = [NSMutableArray array];
    
    for (int i = 0; i < count; i ++) {
        if ([songs count] == 0) {
            break;
        }
        int index = random() % [songs count];
        [resultSongs addObject:[songs objectAtIndex:index]];
        [songs removeObjectAtIndex:index];
    }
    
    return resultSongs;
}

- (NSArray *)randomSongsWithTag:(int)tag
                          count:(int)count{
    
    
    NSMutableArray *songs = [NSMutableArray arrayWithCapacity:count];
    for (NSString *key in [_songsDic allKeys]) {
        PBSong *song = [_songsDic objectForKey:key];
        if ([song.tagList containsObject:@(tag)]) {
            [songs addObject:song];
        }
    }
    
    if (count >= [songs count]) {
        return songs;
    }
    
    NSMutableArray *resultSongs = [NSMutableArray array];

    for (int i = 0; i < count; i ++) {
        int index = arc4random() % [songs count];
        [resultSongs addObject:[songs objectAtIndex:index]];
        [songs removeObjectAtIndex:index];
    }

    return resultSongs;
}

#define SONGS_FILE_PATH @"/Users/Linruin/gitdata/songs.pb"
- (void)createTestData{
    PBSong *song1 = [SongManager songWithName:@"天黑黑" author:@"孙燕姿" lyric:nil tag:nil];
    
    PBSong *song2 = [SongManager songWithName:@"坚持到底" author:@"阿杜" lyric:nil tag:nil];

    
    PBSong *song3 = [SongManager songWithName:@"你的背包" author:@"陈奕迅" lyric:nil tag:nil];

    
    PBSong *song4 = [SongManager songWithName:@"还有你" author:@"任贤齐" lyric:nil tag:nil];

    
    PBSong *song5 = [SongManager songWithName:@"霸王别姬" author:@"屠洪刚" lyric:nil tag:nil];

    
    PBSong *song6 = [SongManager songWithName:@"三年二班" author:@"周杰伦" lyric:nil tag:nil];

    
    PBSong *song7 = [SongManager songWithName:@"大海" author:@"张雨生" lyric:nil tag:nil];

    
    PBSong *song8 = [SongManager songWithName:@"风继续吹" author:@"张国荣" lyric:nil tag:nil];

    
    PBSong *song9 = [SongManager songWithName:@"在那桃花盛开的地方" author:@"蒋大为" lyric:nil tag:nil];

    
    PBSong *song10 = [SongManager songWithName:@"忐忑" author:@"龚琳娜" lyric:nil tag:nil];

    
    NSArray *songs = [NSArray arrayWithObjects:song1, song2, song3, song4, song5, song6, song7, song8, song9, song10, nil];
    
    for (PBSong *song in songs) {
        [self.songsDic setObject:song forKey:song.songId];
    }
    
//    PBSongList_Builder *builer = [[[PBSongList_Builder alloc] init] autorelease];
//    [builer addAllSongs:songs];
//    PBSongList *list = [builer build];
//    [[list data] writeToFile:SONGS_FILE_PATH atomically:YES];
}

+ (PBSong *)songWithName:(NSString *)name
                  author:(NSString *)author
                   lyric:(NSString *)lyric
                     tag:(NSArray *)tag{
    
    PBSong_Builder *builder = [[[PBSong_Builder alloc] init] autorelease];
    [builder setSongId:[self GetUUID]];
    [builder setName:name];
    [builder setAuthor:author];
    [builder setLyric:lyric];
    [builder addAllTag:tag];
    return [builder build];
}

+ (PBSong *)testSong{
    return [SongManager songWithName:@"天黑黑" author:@"孙燕姿" lyric:@"我的小时候\n吵闹任性的时侯\n我的外婆\n总会唱歌哄我\n夏天的午后\n老老的歌安慰我\n那首歌好像这样唱的\n天黑黑 欲落雨\n天黑黑 黑黑\n离开小时候\n有了自己的生活\n新鲜的歌\n新鲜的念头\n任性和冲动\n无法控制的时候\n我忘记\n还有这样的歌\n天黑黑　欲落雨\n天黑黑　黑黑\n我爱上让我奋不顾身的一个人\n我以为\n这就是我所追求的世界\n然而横冲直撞被误解被骗" tag:nil];
}

+ (NSString *)GetUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return [(NSString *)string autorelease];
}

@end
