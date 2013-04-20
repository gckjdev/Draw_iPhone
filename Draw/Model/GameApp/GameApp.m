
#import "GameApp.h"
#import "DrawGameApp.h"
#import "DrawGameProApp.h"
#import "DiceGameApp.h"
#import "ZJHGameApp.h"
#import "LearnDrawApp.h"
#import "PureDrawApp.h"

static NSObject<GameAppProtocol>* currentApp;

NSObject<GameAppProtocol>* getGameApp()
{
    if (currentApp != nil)
        return currentApp;
    
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];  
    NSString *bundleId = [infoDict objectForKey:@"CFBundleIdentifier"];
    
    if ([bundleId isEqualToString:DRAW_APP_BUNDLE_ID]){
        currentApp = [[DrawGameApp alloc] init];        
    }
    else if ([bundleId isEqualToString:DRAW_APP_PRO_BUNDLE_ID]){
        currentApp =  [[DrawGameProApp alloc] init];
    }
    else if ([bundleId isEqualToString:DICE_APP_BUNDLE_ID] || [bundleId isEqualToString:OLD_DICE_APP_BUNDLE_ID]){
        currentApp = [[DiceGameApp alloc] init];
    }   
    else if ([bundleId isEqualToString:ZJH_APP_BUNDLE_ID]){
        currentApp = [[ZJHGameApp alloc] init];
    }
    else if ([bundleId isEqualToString:LEARNDRAW_APP_BUNDLE_ID]){
        currentApp = [[LearnDrawApp alloc] init];
    }
    else if ([bundleId isEqualToString:PUREDRAW_APP_BUNDLE_ID]){
        currentApp = [[PureDrawApp alloc] init];
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
            isPhotoDrawFreeApp());
}

extern BOOL isLearnDrawApp()
{
    return ([[GameApp gameId] isEqualToString:LEARN_DRAW_GAME_ID]);
}

extern BOOL isPureDrawApp()
{
    return ([[GameApp gameId] isEqualToString:PURE_DRAW_GAME_ID]);
}

extern BOOL isPureDrawFreeApp()
{
    return ([[GameApp gameId] isEqualToString:PURE_DRAW_FREE_GAME_ID]);
}

extern BOOL isPhotoDrawApp()
{
    return ([[GameApp gameId] isEqualToString:PHOTO_DRAW_GAME_ID]);
}

extern BOOL isPhotoDrawFreeApp()
{
    return ([[GameApp gameId] isEqualToString:PHOTO_DRAW_FREE_GAME_ID]);
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
    if ([[GameApp gameId] isEqualToString:PURE_DRAW_FREE_GAME_ID]) {
        return GameAppTypePureDrawFree;
    }
    if ([[GameApp gameId] isEqualToString:PHOTO_DRAW_GAME_ID]) {
        return GameAppTypePhotoDraw;
    }
    if ([[GameApp gameId] isEqualToString:PHOTO_DRAW_FREE_GAME_ID]) {
        return GameAppTypePhotoDrawFree;
    }
    return GameAppTypeUnknow;
}
