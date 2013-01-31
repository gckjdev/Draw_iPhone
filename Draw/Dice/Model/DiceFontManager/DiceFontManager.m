//
//  DiceFontManager.m
//  Draw
//
//  Created by 小涛 王 on 12-8-8.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceFontManager.h"
#import "DeviceDetection.h"
#import "FileUtil.h"
#import "LogUtil.h"
#import "SSZipArchive.h"

#define FONT_ZIP_NAME   @"font.zip"
#define FONT_DIR        @"font"


static DiceFontManager *_defaultManager = nil;

@interface DiceFontManager()

@property (retain, nonatomic) NSString *fontName;

@end

@implementation DiceFontManager

@synthesize fontName = _fontName;

+ (NSString *)fontDir
{
    return [[FileUtil getAppCacheDir] stringByAppendingPathComponent:FONT_DIR];
//    return [[FileUtil getAppHomeDir] stringByAppendingPathComponent:FONT_DIR];
}

+ (NSString *)fontPath
{
    return [[DiceFontManager fontDir] stringByAppendingPathComponent:FONT_NAME];    
}

+ (void)unZipFiles
{
    [FileUtil unzipFile:FONT_ZIP_NAME];
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
        
//        [[FontManager sharedManager] loadFontFromPath:[DiceFontManager fontPath]];
        self.fontName = FONT_NAME;
    }
    
    return self;
}

- (NSString *)fontName
{
    return _fontName;
}

@end
