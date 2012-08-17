//
//  DiceFontManager.m
//  Draw
//
//  Created by 小涛 王 on 12-8-8.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceFontManager.h"
#import "FontManager.h"
#import "DeviceDetection.h"
#import "FileUtil.h"
#import "LogUtil.h"
#import "SSZipArchive.h"

#define FONT_DIR        @"font"
#define FONT_NAME       @"diceFont"
#define FONT_ZIP_NAME   @"diceFont.zip"

static DiceFontManager *_defaultManager = nil;

@interface DiceFontManager()

@property (retain, nonatomic) NSString *fontName;

@end

@implementation DiceFontManager

@synthesize fontName = _fontName;

+ (NSString *)fontDir
{
    return [[FileUtil getAppHomeDir] stringByAppendingPathComponent:FONT_DIR];
}

+ (NSString *)fontPath
{
    return [[DiceFontManager fontDir] stringByAppendingPathComponent:FONT_NAME];    
}

+ (BOOL)isExistsFontFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:[DiceFontManager fontPath]];
}

+ (void)unZipFiles
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    if (queue == NULL) {
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    }
    
    if (queue == NULL) {
        PPDebug(@"error:<DiceFontManager> fail to get queue");
        return;
    }
    
    dispatch_async(queue, ^{
        
        if ([DiceFontManager isExistsFontFile]){
            PPDebug(@"<DiceFontManager>: font file is exists");
            return;
        }
            
        
        PPDebug(@"start to unzip the font package");
        //creat dir
        NSString *dir = [DiceFontManager fontDir];
        BOOL flag = [FileUtil createDir:dir];
        
        if (!flag) {
            PPDebug(@"<DiceFontManager>:unZipFiles fail, due to failing to creating dir");
            return;
        }
        
        PPDebug(@"font dir = %@", dir);
        
        //copy the zip file to the dir
        flag = [FileUtil copyFileFromBundleToAppDir:FONT_ZIP_NAME appDir:dir overwrite:YES];
        if (!flag) {
            PPDebug(@"<DiceFontManager>:unZipFiles fail, due to failing to copy font zip package to distination dir");
        }
        
        //unzip to dir
        NSString *zipPath = [dir stringByAppendingPathComponent:FONT_ZIP_NAME];
        PPDebug(@"distination path = %@", zipPath);
        flag = [SSZipArchive unzipFileAtPath:zipPath toDestination:dir];
        if (!flag) {
            PPDebug(@"<DiceFontManager>:unZipFiles fail, due to failing to unzip package to distination dir");
            return;            
        }else {
            PPDebug(@"<DiceFontManager>:unZipFiles successfully");
        }
        [FileUtil removeFile:zipPath];
    });
    
}

- (void)dealloc
{
    [_fontName release];
    [super dealloc];
}

+ (DiceFontManager*)defaultManager
{
    if (_defaultManager == nil){
        _defaultManager = [[DiceFontManager alloc] init];
    }

    return _defaultManager;
}

- (id)init
{
    if (self = [super init]) {
        
//        if ([DeviceDetection isOS5]) {
//            self.fontName = HKGIRL_FONT;
//            [[FontManager sharedManager] loadFont:_fontName];
//        }else {
//            self.fontName = @"";
//        }
        
        [[FontManager sharedManager] loadFontFromPath:[DiceFontManager fontPath]];
        self.fontName = FONT_NAME;
    }
    
    return self;
}

- (NSString *)fontName
{
    return _fontName;
}

@end
