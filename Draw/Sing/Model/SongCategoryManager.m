//
//  SongCategoryManager.m
//  Draw
//
//  Created by 王 小涛 on 13-6-13.
//
//

#import "SongCategoryManager.h"
#import "SynthesizeSingleton.h"
#import "PPSmartUpdateData.h"
#import "Sing.pb.h"

#define FileName @"songCategory.pb"

@interface SongCategoryManager()
@property (retain, nonatomic) PPSmartUpdateData *smartData;
@property (retain, nonatomic) NSArray *categorys;
@end

@implementation SongCategoryManager

SYNTHESIZE_SINGLETON_FOR_CLASS(SongCategoryManager);

- (void)dealloc
{
    [_smartData release];
    [_categorys release];
    [super dealloc];
}

- (id)init
{
    if(self = [super init])
    {
        self.smartData = [[[PPSmartUpdateData alloc] initWithName:FileName type:SMART_UPDATE_DATA_TYPE_PB bundlePath:FileName initDataVersion:@"1.0"] autorelease];
    }
    
    return self;
}

- (void)syncData
{    
    __block typeof(self) bself = self;
    
    [_smartData checkUpdateAndDownload:^(BOOL isAlreadyExisted, NSString *dataFilePath) {
        PPDebug(@"getIngotsList successfully");
        
        NSData *data = [NSData dataWithContentsOfFile:dataFilePath];
        NSArray *categorys = [[PBSongCategoryList parseFromData:data] categorysList];
        bself.categorys = categorys;
    } failureBlock:^(NSError *error) {
        
        NSData *data = [NSData dataWithContentsOfFile:bself.smartData.dataFilePath];
        NSArray *categorys = [[PBSongCategoryList parseFromData:data] categorysList];
        bself.categorys = categorys;

    }];
}

+ (NSArray *)createTestData{
    PBSongCategoryList_Builder *builder = [[[PBSongCategoryList_Builder alloc] init] autorelease];
    
    [builder addAllCategorys:[NSArray arrayWithObjects:[self hot], [self mood], nil]];
    
    
    
    return [[builder build] categorysList];
}

+ (PBSongCategory *)hot{
    PBSongCategory_Builder *builder = [[[PBSongCategory_Builder alloc] init] autorelease];
    [builder setCategoryId:1];
    [builder setName:@"热门"];
    
    PBSongTag *tag1 = [self songTagWithId:1  name:@"经典老歌"];
    PBSongTag *tag2 = [self songTagWithId:2  name:@"我是歌手"];
    PBSongTag *tag3 = [self songTagWithId:3  name:@"影视原声"];
    PBSongTag *tag4 = [self songTagWithId:4  name:@"日韩"];
    PBSongTag *tag5 = [self songTagWithId:5  name:@"欧美"];
    PBSongTag *tag6 = [self songTagWithId:6  name:@"对唱"];
    PBSongTag *tag7 = [self songTagWithId:7  name:@"中国风"];
    PBSongTag *tag8 = [self songTagWithId:8  name:@"天籁"];
    PBSongTag *tag9 = [self songTagWithId:9  name:@"情歌"];
    PBSongTag *tag10 = [self songTagWithId:10  name:@"儿歌"];
    NSArray *arr = [NSArray arrayWithObjects:tag1, tag2, tag3, tag4, tag5, tag6, tag7, tag8, tag9, tag10, nil];
    
    [builder addAllSongTags:arr];
    return [builder build];
}

+ (PBSongCategory *)mood{
    PBSongCategory_Builder *builder = [[[PBSongCategory_Builder alloc] init] autorelease];
    [builder setCategoryId:2];
    [builder setName:@"心情"];
    
    PBSongTag *tag1 = [self songTagWithId:101  name:@"伤感"];
    PBSongTag *tag2 = [self songTagWithId:102  name:@"想念"];
    PBSongTag *tag3 = [self songTagWithId:103  name:@"寂寞"];
    PBSongTag *tag4 = [self songTagWithId:104  name:@"安静"];
    PBSongTag *tag5 = [self songTagWithId:105  name:@"甜蜜"];
    PBSongTag *tag6 = [self songTagWithId:106  name:@"励志"];
    PBSongTag *tag7 = [self songTagWithId:107  name:@"舒服"];
    PBSongTag *tag8 = [self songTagWithId:108  name:@"怀念"];
    PBSongTag *tag9 = [self songTagWithId:109  name:@"浪漫"];
    PBSongTag *tag10 = [self songTagWithId:110 name:@"喜悦"];
    PBSongTag *tag11 = [self songTagWithId:111 name:@"深情"];
    PBSongTag *tag12 = [self songTagWithId:112 name:@"美好"];
    PBSongTag *tag13 = [self songTagWithId:113 name:@"怀旧"];
    PBSongTag *tag14 = [self songTagWithId:114 name:@"激情"];

    [builder addAllSongTags:[NSArray arrayWithObjects:tag1, tag2, tag3, tag4, tag5, tag6, tag7, tag8, tag9, tag10, tag11, tag12, tag13, tag14, nil]];
    return [builder build];
}

+ (PBSongTag *)songTagWithId:(int)tagId
                        name:(NSString *)name{
    PBSongTag_Builder *builder = [[[PBSongTag_Builder alloc] init] autorelease];
    [builder setTagId:tagId];
    [builder setTagName:name];
    return [builder build];
}


@end
