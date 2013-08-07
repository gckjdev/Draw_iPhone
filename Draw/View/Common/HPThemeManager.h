//
//  HPThemeManager.h
//  HPThemeManager
//
//  Created by Evangel on 11-6-16.
//  Copyright 2011  __HP__. All rights reserved.
//

#define UIThemeImageNamed(x) ([UIImage imageWithContentsOfFile:[[[HPThemeManager defaultManager] themePath] stringByAppendingPathComponent:x]])

@interface HPThemeManager : NSObject 

@property (copy, nonatomic) NSString *currentTheme;
@property (retain, nonatomic) NSDictionary *themeDictionary;

+ (HPThemeManager *)defaultManager;
- (NSString *)themePath;

@end