
//  SingApp.m
//  Draw
//
//  Created by 王 小涛 on 13-5-21.
//
//

#import "SingApp.h"
#import "SingController.h"
#import "SingImageManager.h"
#import "SingHomeController.h"
#import "ShareImageManager.h"

@implementation SingApp

- (PPViewController *)homeController{
    return [[[SingHomeController alloc] init] autorelease];
}

- (NSString*)umengId{
    return @"51b698e556240b357101820c";
}

- (void)createConfigData{

}

- (NSString*)gameId{
    return SING_GAME_ID;
}

- (void)HandleWithDidFinishLaunching
{
    
}

- (void)HandleWithDidBecomeActive
{
    
}

- (BOOL)supportWeixin{
    return YES;
}

- (BOOL)isAutoRegister
{
    return NO;
}

- (NSString*)appId
{
    return SING_APP_ID;
}

- (NSString*)sinaAppKey{
    return @"xxxxx";
}

- (NSString*)sinaAppSecret{
    return @"xxxxx";
}

- (NSString*)sinaAppRedirectURI{
    return @"xxxxx";
}

- (NSString*)sinaWeiboId
{
    return @"xxxxx";

}

- (NSString*)qqAppKey
{
    return @"xxxxx";
}

- (NSString*)qqAppSecret
{
    return @"xxxxx";
}

- (NSString*)qqAppRedirectURI
{
    return @"xxxxx";
}

- (NSString*)qqWeiboId
{
    return @"xxxxx";
}

- (NSString*)facebookAppKey
{
    return @"xxxxx";
}

- (NSString*)facebookAppSecret
{
    return @"xxxxx";
}

- (NSString*)lmwallId
{
    return @"";
}

- (NSString*)youmiWallId
{
    return @""; // TODO
}

- (NSString*)youmiWallSecret
{
    return @""; // TODO
}

- (NSString*)aderWallId
{
    return @"";
}

- (NSString*)domodWallId
{
    return @"";
}

- (NSString*)tapjoyWallId
{
    return @"";//TODO
}

- (NSString*)tapjoyWallSecret
{
    return @"";//TODO
}

- (BOOL)disableAd{
    return NO;
}

- (NSString *)getInputDialogXibName{
    return @"SingInputDialog";
}

- (NSString *)iapResourceFileName{
    return @"";
}

- (BOOL)showLocateButton
{
    return NO;
}

- (NSString*)homeHeaderViewId
{
    return @"SingHomeHeaderPanel";
}

- (NSString*)getBackgroundMusicName
{
    return @"";
}

- (UIColor *)homeMenuColor
{
    return [UIColor whiteColor];
}

- (NSString *)popupMessageDialogBackgroundImage
{
    return @"common_dialog_bg@2x.png";
}

- (UIColor*)popupMessageDialogFontColor
{
    return [UIColor colorWithRed:62/255.0 green:43/255.0 blue:23/255.0 alpha:1];;
}

- (id<ImageManagerProtocol>)getImageManager
{
    return [ShareImageManager defaultManager];
}

- (NSString*)background
{
    return DRAW_BACKGROUND;
}

- (int)photoUsage
{
    return PBPhotoUsageForPs;
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

@end
