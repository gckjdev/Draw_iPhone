
#import "GameApp.h"
#import "DrawGameApp.h"
#import "DrawGameProApp.h"
#import "DiceGameApp.h"
#import "ZJHGameApp.h"
#import "LearnDrawApp.h"
#import "PureDrawApp.h"
#import "PureDrawFreeApp.h"
#import "PhotoDrawApp.h"
#import "PhotoDrawFreeApp.h"
#import "DreamAvatarApp.h"
#import "DreamAvatarFreeApp.h"
#import "DreamLockscreenApp.h"
#import "DreamLockscreenFreeApp.h"
#import "LittleGeeDrawApp.h"
#import "CallTrackApp.h"
#import "SecureSmsApp.h"
//#import "SingApp.h"

static NSObject<GameAppProtocol>* currentApp;

NSObject<ContentGameAppProtocol>* getContentGameApp()
{
    NSObject<GameAppProtocol>* app = getGameApp();
    if ([app conformsToProtocol:@protocol(ContentGameAppProtocol)]){
        return (NSObject<ContentGameAppProtocol>*)app;
    }
    else{
        PPDebug(@"WANRING, get content game app but app is not content game!!!");
        return nil;
    }
}

NSObject<GameAppProtocol>* appWithName(NSString *name){
    Class class = NSClassFromString(name);
    currentApp = [[[class class] alloc] init];
    
    return currentApp;
}


NSObject<GameAppProtocol>* getGameApp()
{
    if (currentApp != nil)
        return currentApp;
    
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];  
    NSString *bundleId = [infoDict objectForKey:@"CFBundleIdentifier"];
    
    if ([bundleId isEqualToString:DRAW_APP_BUNDLE_ID]){
        currentApp = appWithName(@"DrawGameApp");
    }
    else if ([bundleId isEqualToString:DRAW_APP_PRO_BUNDLE_ID]){
        currentApp = appWithName(@"DrawGameProApp");
    }
    else if ([bundleId isEqualToString:DICE_APP_BUNDLE_ID] || [bundleId isEqualToString:OLD_DICE_APP_BUNDLE_ID]){
        currentApp = appWithName(@"DiceGameApp");
    }   
    else if ([bundleId isEqualToString:ZJH_APP_BUNDLE_ID]){
        currentApp = appWithName(@"ZJHGameApp");
    }
    else if ([bundleId isEqualToString:LEARNDRAW_APP_BUNDLE_ID]){
        currentApp = appWithName(@"LearnDrawApp");
    }
    else if ([bundleId isEqualToString:PUREDRAW_APP_BUNDLE_ID]){
        currentApp = appWithName(@"PureDrawApp");
    }
    else if ([bundleId isEqualToString:PUREDRAWFREE_APP_BUNDLE_ID]){
        currentApp = appWithName(@"PureDrawFreeApp");
    }
    else if ([bundleId isEqualToString:PHOTODRAW_APP_BUNDLE_ID]){
        currentApp = appWithName(@"PhotoDrawApp");
    }
    else if ([bundleId isEqualToString:PHOTODRAWFREE_APP_BUNDLE_ID]){
        currentApp = appWithName(@"PhotoDrawFreeApp");
    }
    else if ([bundleId isEqualToString:DREAMAVATAR_APP_BUNDLE_ID]){
        currentApp = appWithName(@"DreamAvatarApp");
    }
    else if ([bundleId isEqualToString:DREAMAVATARFREE_APP_BUNDLE_ID]){
        currentApp = appWithName(@"DreamAvatarFreeApp");
    }
    else if ([bundleId isEqualToString:DREAMLOCKSCREEN_APP_BUNDLE_ID]){
        currentApp = appWithName(@"DreamLockscreenApp");
    }
    else if ([bundleId isEqualToString:DREAMLOCKSCREENFREE_APP_BUNDLE_ID]){
        currentApp = appWithName(@"DreamLockscreenFreeApp");
    }
    else if ([bundleId isEqualToString:LITTLE_GEE_APP_BUNDLE_ID]) {
        currentApp = appWithName(@"LittleGeeDrawApp");
    } else if ([bundleId isEqualToString:CALL_TRACK_APP_BUNDLE_ID]) {
        currentApp = appWithName(@"CallTrackApp");
    } else if ([bundleId isEqualToString:SECURE_SMS_APP_BUNDLE_ID]) {
        currentApp = appWithName(@"SecureSmsApp");
    }
    else if ([bundleId isEqualToString:SING_APP_BUNDLE_ID]) {
        currentApp = appWithName(@"SingApp");
    }
    
    else{
        PPDebug(@"<Warning> !!!!!!! GameApp Not Found by Bundle Id(%@) !!!!!!!!!", bundleId);
    }
    
    return currentApp;
}


BOOL isDrawApp()
{
    return ([[GameApp gameId] isEqualToString:DRAW_GAME_ID]);
}

BOOL isDiceApp()
{
    return ([[GameApp gameId] isEqualToString:DICE_GAME_ID]);    
}

BOOL isZhajinhuaApp()
{
    return ([[GameApp gameId] isEqualToString:ZHAJINHUA_GAME_ID]);
}

extern BOOL isSimpleDrawApp()
{
    return (isLearnDrawApp() ||
            isPureDrawApp() ||
            isPureDrawFreeApp() ||
            isPhotoDrawApp() ||
            isPhotoDrawFreeApp() ||
            isDreamAvatarApp() ||
            isDreamAvatarFreeApp() ||
            isDreamLockscreenApp() ||
            isDreamLockscreenApp() ||
            isDreamLockscreenFreeApp());
}

extern BOOL isLearnDrawApp()
{
    return ([[GameApp gameId] isEqualToString:LEARN_DRAW_GAME_ID]);
}

extern BOOL isPureDrawApp()
{
    return ([[GameApp appId] isEqualToString:PURE_DRAW_APP_ID]);
}

extern BOOL isPureDrawFreeApp()
{
    return ([[GameApp appId] isEqualToString:PURE_DRAW_FREE_APP_ID]);
}

extern BOOL isPhotoDrawApp()
{
    return ([[GameApp appId] isEqualToString:PHOTO_DRAW_APP_ID]);
}

extern BOOL isPhotoDrawFreeApp()
{
    return ([[GameApp appId] isEqualToString:PHOTO_DRAW_FREE_APP_ID]);
}

extern BOOL isDreamAvatarApp()
{
    return ([[ContentGameApp appId] isEqualToString:DREAM_AVATAR_APP_ID]);
}

extern BOOL isDreamAvatarFreeApp()
{
    return ([[ContentGameApp appId] isEqualToString:DREAM_AVATAR_FREE_APP_ID]);
}

extern BOOL isDreamLockscreenApp()
{
    return ([[ContentGameApp appId] isEqualToString:DREAM_LOCKSCREEN_APP_ID]);
}

extern BOOL isDreamLockscreenFreeApp()
{
    return ([[ContentGameApp appId] isEqualToString:DREAM_LOCKSCREEN_FREE_APP_ID]);
}

extern BOOL isLittleGeeAPP()
{
    return ([[GameApp appId] isEqualToString:LITTLE_GEE_APP_ID]);
}

extern BOOL isSecureSmsAPP()
{
    return ([[GameApp appId] isEqualToString:SECURE_SMS_APP_ID]);
}

extern BOOL isCallTrackAPP()
{
    return ([[GameApp appId] isEqualToString:CALL_TRACK_APP_ID]);
}

GameAppType gameAppType()
{
    if ([[GameApp gameId] isEqualToString:DRAW_GAME_ID]) {
        return GameAppTypeDraw;
    } 
    if ([[GameApp gameId] isEqualToString:DICE_GAME_ID]) {
        return GameAppTypeDice;
    } 
    if ([[GameApp gameId] isEqualToString:ZHAJINHUA_GAME_ID]) {
        return GameAppTypeZJH;
    }
    if ([[GameApp gameId] isEqualToString:CANDY_GAME_ID]) {
        return GameAppTypeCandy;
    }
    if ([[GameApp gameId] isEqualToString:LEARN_DRAW_GAME_ID]) {
        return GameAppTypeLearnDraw;
    }
    if ([[GameApp gameId] isEqualToString:PHOTO_DRAW_GAME_ID]) {
        return GameAppTypePureDraw;
    }
    if ([[GameApp appId] isEqualToString:PURE_DRAW_FREE_APP_ID]) {
        return GameAppTypePureDrawFree;
    }
    if ([[GameApp gameId] isEqualToString:PHOTO_DRAW_GAME_ID]) {
        return GameAppTypePhotoDraw;
    }
    if ([[GameApp appId] isEqualToString:PHOTO_DRAW_FREE_APP_ID]) {
        return GameAppTypePhotoDrawFree;
    }
    if ([[GameApp appId] isEqualToString:LITTLE_GEE_APP_ID]) {
        return GameAppTypeLittleGee;
    }
    return GameAppTypeUnknow;
}
