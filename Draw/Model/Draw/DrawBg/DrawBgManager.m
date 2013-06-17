//
//  DrawBgManager.m
//  Draw
//
//  Created by gamy on 13-3-2.
//
//

#import "DrawBgManager.h"
#import "SynthesizeSingleton.h"
#import "PPSmartUpdateData.h"
#import "Draw.pb.h"
#import "FileUtil.h"
#import "ConfigManager.h"
#import "UIImageExt.h"

#define DRAW_BG_ZIP_NAME @"draw_bg.zip"
#define DRAW_BG_VERSION_KEY @"CFDrawBGVersion"
#define DRAW_BG_META_FILE @"meta.pb"
#define SUFFIX @".jpg"
#define THUMB_SUFFIX @"_m.jpg"

@interface DrawBgManager()
{
    PPSmartUpdateData *_smartData;
    NSArray *_drawBgGroupList;
}

@end

@implementation DrawBgManager

SYNTHESIZE_SINGLETON_FOR_CLASS(DrawBgManager);

- (void)dealloc
{
    PPRelease(_smartData);
    PPRelease(_drawBgGroupList);
    [super dealloc];
}

- (void)updateDrawBgList
{
    if (_drawBgGroupList) {
        PPRelease(_drawBgGroupList);
    }
    NSString *filePath = [[_smartData currentDataPath] stringByAppendingPathComponent:DRAW_BG_META_FILE];
    @try {
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        if (data) {
            _drawBgGroupList = [[[PBDrawBgMeta parseFromData:data] drawBgGroupList] retain];
        }
    }
    @catch (NSException *exception) {
        _drawBgGroupList = nil;
        PPDebug(@"<updateDrawBgList>Fail to parse draw bg data");
    }    
}

- (id)init
{
    self = [super init];
    if (self) {

        _smartData = [[PPSmartUpdateData alloc] initWithName:DRAW_BG_ZIP_NAME
                                                        type:SMART_UPDATE_DATA_TYPE_ZIP
                                                  bundlePath:DRAW_BG_ZIP_NAME
                                             initDataVersion:[ConfigManager currentDrawBgVersion]];

        [self updateDrawBgList];
        
        __block DrawBgManager *pt = self;

        [_smartData checkUpdateAndDownload:^(BOOL isAlreadyExisted, NSString *dataFilePath) {
            if (!isAlreadyExisted) {
                [pt updateDrawBgList];
            }
            PPDebug(@"checkUpdateAndDownload successfully");
        } failureBlock:^(NSError *error) {
            PPDebug(@"checkUpdateAndDownload failure error=%@", [error description]);
        }];

    }
    return self;
}

- (NSString *)baseDir
{
    return [_smartData currentDataPath];
}


- (PBDrawBg *)pbDrawBgWithId:(NSString *)drawBgId
{
    for (PBDrawBgGroup *bgGroup in _drawBgGroupList) {
        for (PBDrawBg *bg in bgGroup.drawBgsList) {
            if ([bg.bgId isEqual:drawBgId]) {
                return bg;
            }
        }
    }
    return nil;
}

+ (void )imageForRemoteURL:(NSString *)url success:(SDWebImageSuccessBlock)success failure:(SDWebImageFailureBlock)failure
{
    NSURL *URL = [NSURL URLWithString:url];
    [[SDWebImageManager sharedManager] downloadWithURL:URL delegate:URL options:0 success:success failure:failure];
}


- (NSArray *)pbDrawBgGroupList
{
    return _drawBgGroupList;
}

+ (void)createTestData:(NSUInteger)number
{
    
    
    NSString *dataPath = @"/Users/qqn_pipi/tool/draw_bg/dbg.txt";
    NSString *string = [NSString stringWithContentsOfFile:dataPath encoding:NSUTF8StringEncoding error:nil];
    PPDebug(@"<createTestData> string = %@",string);
    NSArray *groupList = [string componentsSeparatedByString:@"\n\n"];
    
    PBDrawBgMeta_Builder *drawBgMeta = [[[PBDrawBgMeta_Builder alloc] init] autorelease];
    NSInteger i = 1;
    NSInteger start = 1;
    NSMutableArray *tempList = [NSMutableArray array];
    for (NSString *group in groupList) {

        PBDrawBgGroup_Builder *gb = [[[PBDrawBgGroup_Builder alloc] init] autorelease];

        
        NSArray *list = [group componentsSeparatedByString:@"\n"];
        
        // group id
        NSInteger gid = [[list objectAtIndex:0] integerValue];
        [gb setGroupId:gid];
        
        
        ////// name
        NSArray *names = [[list objectAtIndex:1] componentsSeparatedByString:@" "];

        PBLocalizeString_Builder *loc1 = [[PBLocalizeString_Builder alloc] init];
        [loc1 setLanguageCode:@"zh_Hans"];
        [loc1 setLocalizedText:[names objectAtIndex:0]];
        [gb addName:[loc1 build]];
        
        PBLocalizeString_Builder *loc2 = [[PBLocalizeString_Builder alloc] init];
        [loc2 setLanguageCode:@"en"];
        [loc2 setLocalizedText:[names objectAtIndex:1]];
        [gb addName:[loc2 build]];
        
        
        //////bg list
        

        for (i = start; i < start + 5; i ++) {
            NSString *bgId = [NSString stringWithFormat:@"%d",i];
            NSString *localUrl = [NSString stringWithFormat:@"%d.jpg",i];
            NSString *remoteUrl = @"http://58.215.160.100:8080/app_res/smart_data/draw_bg/";
            remoteUrl = [remoteUrl stringByAppendingPathComponent:localUrl];

            PBDrawBg_Builder *builder = [[[PBDrawBg_Builder alloc] init] autorelease];
            [builder setBgId:bgId];
            [builder setLocalUrl:localUrl];
            [builder setRemoteUrl:remoteUrl];
            [gb addDrawBgs:[builder build]];
        }
        
//        [tempList addObject:[gb build]];
        [tempList insertObject:[gb build] atIndex:0];

        start += 10;
    }
    [drawBgMeta addAllDrawBgGroup:tempList];
//    NSInteger count = [tempList count];
//    while (--count >= 0) {
//        PBDrawBgGroup *group = [tempList objectAtIndex:count];
//        [drawBgMeta addDrawBgGroup:group];
//    }
    
    NSData *data = [[drawBgMeta build] data];
    PPDebug(@"<Write Data>, data length = %d",[data length]);
    [data writeToFile:@"/Users/qqn_pipi/tool/draw_bg/meta.pb" atomically:YES];
//    [DrawBgManager scaleImages];
}


+ (void)scaleImages
{
    
    NSString *dir = @"/Users/qqn_pipi/tool/draw_bg";
    NSArray *list = [FileUtil fileNameListBelowDir:dir suffix:SUFFIX];
    
    for (NSString *name in list) {
        NSString *path = [dir stringByAppendingPathComponent:name];
        UIImage *image = [UIImage imageWithContentsOfFile:path];
        image = [image imageByScalingAndCroppingForSize:CGSizeMake(70, 70)];
        NSString *temp = [name substringToIndex:[name length] - 4];
        temp = [NSString stringWithFormat:@"%@_m.jpg",temp];
        path = [dir stringByAppendingPathComponent:temp];
        [[image data] writeToFile:path atomically:YES];
    }
}

@end



@implementation PBDrawBg(Ext)



- (NSString *)localThumbUrl
{

    NSRange range = [self.localUrl rangeOfString:SUFFIX];
    if (range.location == NSNotFound) {
        return nil;
    }
    NSString *url = [self.localUrl substringToIndex:range.location];
    url = [NSString stringWithFormat:@"%@%@",url,THUMB_SUFFIX];
    return url;
}

- (UIImage *)localThumb
{
    NSString *dir = [[DrawBgManager defaultManager] baseDir];
    
    NSString *filePath = [dir stringByAppendingPathComponent:self.localThumbUrl];
    
    if (filePath) {
        return [UIImage imageWithContentsOfFile:filePath];
    }
    return nil;

}

- (UIImage *)localImage
{
    NSString *dir = [[DrawBgManager defaultManager] baseDir];
    NSString *filePath = [dir stringByAppendingPathComponent:self.localUrl];
    if (filePath) {
        return [UIImage imageWithContentsOfFile:filePath];
    }
    return nil;
}

- (NSURL *)remoteURL
{
    return [NSURL URLWithString:self.remoteUrl];
}

- (int)type
{
    return self.showStyle;
}

@end