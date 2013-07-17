//
//  CommonHelpManager
//  Draw
//
//  Created by 小涛 王 on 12-8-25.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonHelpManager : NSObject

+ (CommonHelpManager*)defaultManager;

- (void)unzipHelpFiles;

- (NSString *)gameRulesHtmlFilePath;
- (NSString *)itemsUsageHtmlFilePath;

@end
