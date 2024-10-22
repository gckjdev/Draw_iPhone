//
//  DrawGameProApp.m
//  Draw
//
//  Created by  on 12-8-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DrawGameProApp.h"
#import "MobClickUtils.h"
#import "HomeController.h"
#import "IAPProductService.h"

@implementation DrawGameProApp

- (NSString*)appId
{
    return DRAW_PRO_APP_ID;
}

- (BOOL)disableAd
{
    return YES;
}

- (NSString*)removeAdProductId
{
    return [MobClickUtils getStringValueByKey:@"AD_IAP_ID" defaultValue:@"com.orange.drawpro.removead"];
}

- (BOOL)hasAllColorGroups
{
    return NO;
}

- (UIColor *)homeMenuColor
{
    return [UIColor colorWithRed:61.0/255.0 green:43.0/255.0 blue:23.0/255.0 alpha:1];
}

- (BOOL)canSubmitDraw
{
    return YES;
}

- (BOOL)hasBGOffscreen
{
    return NO;
}

- (BOOL)canGift
{
    return YES;
}

- (PPViewController *)homeController;
{
    return [[[HomeController alloc] init] autorelease];
}

- (BOOL)forceSaveDraft
{
    return NO;
}

- (void)HandleWithDidFinishLaunching
{
    
}

- (void)HandleWithDidBecomeActive
{
    
}

- (void)createConfigData
{
    
}

- (BOOL)showPaintCategory
{
    return YES;
}

- (NSString*)getDefaultSNSSubject
{
    return NSLS(@"kSNSSubject");
}

- (NSString*)appItuneLink
{
    return NSLS(@"kDrawAppLink");
}
- (NSString*)appLinkUmengKey
{
    return @"DRAW_APP_LINK";
}

- (BOOL)forceChineseOpus
{
    return NO;
}
- (BOOL)disableEnglishGuess
{
    return NO;
}
- (void)createIAPTestDataFile
{
    [IAPProductService createDrawIngotTestDataFile];
}

- (BOOL)showLocateButton
{
    return NO;
}

- (int)photoUsage
{
    return PBPhotoUsageForDraw;
}
- (NSString*)keywordSmartDataCn
{
    return @"keywords.txt";
}
- (NSString*)keywordSmartDataEn
{
    return @"keywords_en.txt";
}
- (NSString*)photoTagsCn
{
    return @"photo_tags.txt";
}
- (NSString*)photoTagsEn
{
    return @"photo_tags_en.txt";
}

- (UIImage *)getGiftToSbImage{
    
    return nil;
}
@end
