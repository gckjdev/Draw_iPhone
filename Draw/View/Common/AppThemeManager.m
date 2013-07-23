//
//  AppThemeManager.m
//  Draw
//
//  Created by 王 小涛 on 13-7-22.
//
//

#import "AppThemeManager.h"

#define APP_THEME_TYPE @"AppThemeType"

@implementation AppThemeManager

+ (AppThemeType)appThemeType{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    int appTheme = [userDefaults integerForKey:APP_THEME_TYPE];
    return appTheme;
}

+ (void)setAppThemeType:(AppThemeType)type{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:type forKey:APP_THEME_TYPE];
    [userDefaults synchronize];
}

@end
