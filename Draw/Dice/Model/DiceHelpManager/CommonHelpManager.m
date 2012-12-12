//
//  CommonHelpManager.m
//  Draw
//
//  Created by 小涛 王 on 12-8-25.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "CommonHelpManager.h"
#import "FileUtil.h"
#import "SSZipArchive.h"

#define FILENAME_OF_HELP_ZIP                @"help.zip"

#define ZHS_HTML_FILE_NAME_GAME_RULES @"help/gameRules_zhs.html"
#define ZHT_HTML_FILE_NAME_GAME_RULES @"help/gameRules_zht.html"
#define EN_HTML_FILE_NAME_GAME_RULES  @"help/gameRules_en.html"

#define ZHS_HTML_FILE_NAME_ITMES_USAGE @"help/itemsUsage_zhs.html"
#define ZHT_HTML_FILE_NAME_ITMES_USAGE @"help/itemsUsage_zht.html"
#define EN_HTML_FILE_NAME_ITMES_USAGE  @"help/itemsUsage_en.html"

static CommonHelpManager* _shareManager;


@implementation CommonHelpManager


+ (CommonHelpManager*)defaultManager
{
    if (_shareManager == nil) {
        _shareManager = [[CommonHelpManager alloc] init];
    }
    return _shareManager;
}

- (void)unzipHelpFiles
{
    [FileUtil unzipFile:FILENAME_OF_HELP_ZIP];
}

- (NSString *)gameRulesHtmlFilePath
{    
    NSString *fileName = nil;
    if ([LocaleUtils isChinese]) {
        if ([LocaleUtils isTraditionalChinese]) {
            fileName = ZHT_HTML_FILE_NAME_GAME_RULES;
        }else {
            fileName = ZHS_HTML_FILE_NAME_GAME_RULES;
        }
    }else {
        fileName = EN_HTML_FILE_NAME_GAME_RULES;
    }
    
//    return [[FileUtil getAppHomeDir] stringByAppendingPathComponent:fileName];
    return [[FileUtil getAppCacheDir] stringByAppendingPathComponent:fileName];
}

- (NSString *)itemsUsageHtmlFilePath
{
    NSString *fileName = nil;
    if ([LocaleUtils isChinese]) {
        if ([LocaleUtils isTraditionalChinese]) {
            fileName = ZHT_HTML_FILE_NAME_ITMES_USAGE;
        }else {
            fileName = ZHS_HTML_FILE_NAME_ITMES_USAGE;
        }
    }else {
        fileName = EN_HTML_FILE_NAME_ITMES_USAGE;
    }
    
//    return [[FileUtil getAppHomeDir] stringByAppendingPathComponent:fileName];
    return [[FileUtil getAppCacheDir] stringByAppendingPathComponent:fileName];
    
}



@end
