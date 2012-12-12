//
//  DiceFontManager.h
//  Draw
//
//  Created by 小涛 王 on 12-8-8.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FONT_NAME       @"diceFont"

@interface DiceFontManager : NSObject

+ (NSString *)fontDir;
+ (NSString *)fontPath;
+ (void)unZipFiles;


+ (DiceFontManager*)defaultManager;

- (NSString *)fontName;

@end
