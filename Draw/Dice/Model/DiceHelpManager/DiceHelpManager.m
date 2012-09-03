//
//  DiceHelpManager.m
//  Draw
//
//  Created by 小涛 王 on 12-8-25.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import "DiceHelpManager.h"
#import "FileUtil.h"
#import "SSZipArchive.h"

#define FILENAME_OF_HELP_ZIP                @"help.zip"

#define ZHS_HTML_FILE_NAME_GAME_RULES @"help/dice/gameRules_zhs.html"
#define ZHT_HTML_FILE_NAME_GAME_RULES @"help/dice/gameRules_zht.html"
#define EN_HTML_FILE_NAME_GAME_RULES  @"help/dice/gameRules_en.html"

#define ZHS_HTML_FILE_NAME_ITMES_USAGE @"help/dice/itemsUsage_zhs.html"
#define ZHT_HTML_FILE_NAME_ITMES_USAGE @"help/dice/itemsUsage_zht.html"
#define EN_HTML_FILE_NAME_ITMES_USAGE  @"help/dice/itemsUsage_en.html"

static DiceHelpManager* _shareManager;


@implementation DiceHelpManager


+ (DiceHelpManager*)defaultManager
{
    if (_shareManager == nil) {
        _shareManager = [[DiceHelpManager alloc] init];
    }
    return _shareManager;
}

- (BOOL)isExistsFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager fileExistsAtPath:[self gameRulesHtmlFilePath]];
}

- (void)copyFileFromBndleToAppDir
{
    // copy file from bundle to zip dir
    [FileUtil copyFileFromBundleToAppDir:FILENAME_OF_HELP_ZIP
                                  appDir:[FileUtil getAppHomeDir]
                               overwrite:NO];
}

- (void)unzipHelpFiles
{
    if ([self isExistsFile]) {
        return;
    }
    
    [self copyFileFromBndleToAppDir];
    
    NSString *helpZipFilePath = [[FileUtil getAppHomeDir] stringByAppendingPathComponent:FILENAME_OF_HELP_ZIP];
    
    PPDebug(@"<DiceHelpManager> start unzip");
    
    if ([SSZipArchive unzipFileAtPath:helpZipFilePath 
                        toDestination:[FileUtil getAppHomeDir] 
                            overwrite:YES 
                             password:nil 
                                error:nil]) {
        PPDebug(@"<DiceHelpManager> unzip successfully");
    } else {
        PPDebug(@"<DiceHelpManager> unzip fail");
    }
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
    
    return [[FileUtil getAppHomeDir] stringByAppendingPathComponent:fileName];
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
    
    return [[FileUtil getAppHomeDir] stringByAppendingPathComponent:fileName]; 
}



@end
