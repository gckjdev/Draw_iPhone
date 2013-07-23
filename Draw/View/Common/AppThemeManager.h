//
//  AppThemeManager.h
//  Draw
//
//  Created by 王 小涛 on 13-7-22.
//
//

#import <Foundation/Foundation.h>
#import "AppThemeConstants.h"

@interface AppThemeManager : NSObject

@property (assign) NSInteger currentThemeIndex;
@property(nonatomic,retain) NSDictionary *themeDictionary;
@property(nonatomic,copy) NSString *currentTheme;

+(AppThemeManager*)sharedThemeManager;
+ (AppThemeType)appThemeType;
+ (void)setAppThemeType:(AppThemeType)type;


@end
