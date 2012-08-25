
#import "GameApp.h"
#import "DrawGameApp.h"
#import "DrawGameProApp.h"
#import "DiceGameApp.h"

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
    else if ([bundleId isEqualToString:DICE_APP_BUNDLE_ID]){
        currentApp = [[DiceGameApp alloc] init];
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