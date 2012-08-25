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

#define HTML_FILE_NAME_GAME_RULES @"help/dice/gameRules.html"
#define HTML_FILE_NAME_ITMES_USAGE @"help/dice/itemsUsage.html"

static DiceHelpManager* _shareManager;


@implementation DiceHelpManager


+ (DiceHelpManager*)defaultManager
{
    if (_shareManager == nil) {
        _shareManager = [[DiceHelpManager alloc] init];
    }
    return _shareManager;
}

- (id)init
{
    if (self = [super init]) {
        [self loadHelpFiles];
    }
    
    return self;
}

- (void)loadHelpFiles
{
    [self copyFileFromBndleToAppDir];
    
    BOOL overwrite = NO;
    if ([self checkForUpdate]) {
        overwrite = YES;
        [self downloadHelpFiles];
    }
    
    [self unzipHelpFiles:overwrite];
}

- (BOOL)checkForUpdate
{
    return NO;
}

- (void)downloadHelpFiles
{
    return ;
}

- (void)copyFileFromBndleToAppDir
{
    // copy file from bundle to zip dir
    PPDebug(@"copy defalut app.dat from bundle to app dir");
    
    [FileUtil copyFileFromBundleToAppDir:FILENAME_OF_HELP_ZIP
                                  appDir:[FileUtil getAppHomeDir]
                               overwrite:NO];

}

- (void)unzipHelpFiles:(BOOL)overwrite
{
    NSString *helpZipFilePath = [[FileUtil getAppHomeDir] stringByAppendingPathComponent:FILENAME_OF_HELP_ZIP];
    
    [SSZipArchive unzipFileAtPath:helpZipFilePath 
                    toDestination:[FileUtil getAppHomeDir] 
                        overwrite:overwrite 
                         password:nil 
                            error:nil];
}

- (NSString *)gameRulesHtmlFilePath
{
    return [[FileUtil getAppHomeDir] stringByAppendingPathComponent:HTML_FILE_NAME_GAME_RULES];
}

- (NSString *)itemsUsageHtmlFilePath
{
    return [[FileUtil getAppHomeDir] stringByAppendingPathComponent:HTML_FILE_NAME_ITMES_USAGE]; 
}



@end
