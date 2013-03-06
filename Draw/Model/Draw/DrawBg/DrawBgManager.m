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


#define DRAW_BG_ZIP_NAME @"draw_bg.zip"
#define DRAW_BG_VERSION_KEY @"CFDrawBGVersion"
#define DRAW_BG_META_FILE @"meta.pb"

@interface DrawBgManager()
{
    PPSmartUpdateData *_smartData;
    NSArray *_drawBgList;
}

@end

@implementation DrawBgManager

SYNTHESIZE_SINGLETON_FOR_CLASS(DrawBgManager);

- (void)dealloc
{
    PPRelease(_smartData);
    PPRelease(_drawBgList);
    [super dealloc];
}

- (void)updateDrawBgList
{
    if (_drawBgList) {
        PPRelease(_drawBgList);
    }
    NSString *filePath = [[_smartData currentDataPath] stringByAppendingPathComponent:DRAW_BG_META_FILE];
    @try {
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        if (data) {
            _drawBgList = [[[PBDrawBgList parseFromData:data] drawBgsList] retain];
            for (PBDrawBg *drawBg in _drawBgList) {
                PPDebug(@"draw bg = [%@, %@, %@]",drawBg.bgId, drawBg.localUrl, drawBg.remoteUrl);        
            }
        }
    }
    @catch (NSException *exception) {
        _drawBgList = nil;
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

+ (id)defaultManager
{
    return [DrawBgManager defaultService];
}

- (NSString *)baseDir
{
    return [_smartData currentDataPath];
}

- (PBDrawBg *)pbDrawBgWithId:(NSString *)drawBgId
{
    for (PBDrawBg *bg in _drawBgList) {
        if ([bg.bgId isEqualToString:drawBgId]) {
            return bg;
        }
    }
    return nil;
}

+ (void )imageForRemoteURL:(NSString *)url success:(SDWebImageSuccessBlock)success failure:(SDWebImageFailureBlock)failure
{
    NSURL *URL = [NSURL URLWithString:url];
    [[SDWebImageManager sharedManager] downloadWithURL:URL delegate:URL options:0 success:success failure:failure];
}


- (NSArray *)pbDrawBgList
{
    return _drawBgList;
}

+ (void)createTestData:(NSUInteger)number
{
    PBDrawBgList_Builder *lBuilder = [[[PBDrawBgList_Builder alloc] init] autorelease];
    for (NSInteger i = 1; i <= number; ++i) {
        NSString *bgId = [NSString stringWithFormat:@"%d",i];
        NSString *localUrl = [NSString stringWithFormat:@"%d.jpg",i];
        NSString *remoteUrl = @"http://58.215.160.100:8080/app_res/smart_data/draw_bg/";
        remoteUrl = [remoteUrl stringByAppendingPathComponent:localUrl];

        PBDrawBg_Builder *builder = [[[PBDrawBg_Builder alloc] init] autorelease];
        [builder setBgId:bgId];
        [builder setLocalUrl:localUrl];
        [builder setRemoteUrl:remoteUrl];
        PBDrawBg *drawBg = [builder build];
        [lBuilder addDrawBgs:drawBg];
        PPDebug(@"draw bg = [%@, %@, %@]",drawBg.bgId, drawBg.localUrl, drawBg.remoteUrl);        
    }
    PBDrawBgList *list = [lBuilder build];
    NSData *data = [list data];
    PPDebug(@"<Write Data>, data length = %d",[data length]);
    [data writeToFile:@"/Users/qqn_pipi/tool/draw_bg/meta.pb" atomically:YES];
}

@end



@implementation PBDrawBg(Ext)

- (UIImage *)localImage
{
    NSString *dir = [[DrawBgManager defaultManager] baseDir];
    NSString *filePath = [dir stringByAppendingPathComponent:self.localUrl];
    if (filePath) {
        return [UIImage imageWithContentsOfFile:filePath];
    }
    return nil;
}

@end