
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
        return [[DrawGameApp alloc] init];
    }
    else if ([bundleId isEqualToString:DRAW_APP_PRO_BUNDLE_ID]){
        return [[DrawGameProApp alloc] init];
    }
    else if ([bundleId isEqualToString:DICE_APP_BUNDLE_ID]){
        return [[DiceGameApp alloc] init];
    }

    PPDebug(@"<Warning> !!!!!!! GameApp Not Found by Bundle Id(%@) !!!!!!!!!", bundleId);
    return nil;
}