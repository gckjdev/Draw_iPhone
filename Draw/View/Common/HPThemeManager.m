//
//  HPThemeManager.m
//  HPThemeManager
//
//  Created by Evangel on 11-6-16.
//  Copyright 2011  __HP__. All rights reserved.
//

#import "HPThemeManager.h"
#import "SynthesizeSingleton.h"
#import "GameApp.h"

#define CURRENT_THEME @"CURRENT_THEME"

NSString *const kThemeDidChangeNotification = @"kThemeDidChangeNotification";

@implementation HPThemeManager

SYNTHESIZE_SINGLETON_FOR_CLASS(HPThemeManager);

- (void)dealloc
{
    [_currentTheme release];
    [_themeDictionary release];
    [super dealloc];
}

- (id)init
{
    if(self = [super init])
    {
        NSString *themeFile = [[GameApp gameId] stringByAppendingString:@"-Themes"];
        NSString *path = [[NSBundle mainBundle] pathForResource:themeFile ofType:@"plist"];
        _themeDictionary = [[NSDictionary alloc] initWithContentsOfFile:path];
        
        self.currentTheme = [self getCurrentTheme]; //default theme
        if (![[_themeDictionary allKeys] containsObject:_currentTheme]) {
            self.currentTheme = [[_themeDictionary allKeys] objectAtIndex:0];
        }
    }
    
    return self;
}

- (void)setCurrentTheme:(NSString *)currentTheme{
    
    if ([_currentTheme isEqualToString:currentTheme]) {
        return;
    }
    
    [_currentTheme release];
    _currentTheme = nil;
    _currentTheme = [currentTheme copy];

    [self saveCurrentTheme];
}


- (NSString *)getCurrentTheme{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *theme = [userDefaults stringForKey:CURRENT_THEME];

    return theme;
}

- (void)saveCurrentTheme{
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setValue:_currentTheme forKey:CURRENT_THEME];
    [userDefaults synchronize];
}

- (NSString *)themePath{
    
    NSString *bundlePath = [_themeDictionary objectForKey:_currentTheme];
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:bundlePath];
    return path;
}

@end
