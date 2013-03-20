//
//  GameAdWallService.m
//  Draw
//
//  Created by qqn_pipi on 13-3-16.
//
//

#import "GameAdWallService.h"
#import "SynthesizeSingleton.h"
#import "LimeiAdWallService.h"
#import "WanpuAdWallService.h"
#import "UserManager.h"
#import "ConfigManager.h"
#import "AccountService.h"
#import "CommonMessageCenter.h"

@implementation GameAdWallService

SYNTHESIZE_SINGLETON_FOR_CLASS(GameAdWallService)


- (id)init
{
    self = [super init];
    
    if ([ConfigManager isEnableLimeiWall]){
        [self createLimeiWall];
    }

    if ([ConfigManager isEnableWanpuWall]){
        [self createWanpuWall];
    }    
    
    return self;
}

- (void)createLimeiWall
{
    NSString* limeiAdId = [GameApp lmwallId];
    NSString* userId = [[UserManager defaultManager] userId];
    
    self.limeiWallService = [[[LimeiAdWallService alloc] initWithUserId:userId adUnitId:limeiAdId] autorelease];
}


- (void)createWanpuWall
{
    NSString* adUnitId = [GameApp wanpuAdPublisherId];
    NSString* userId = [[UserManager defaultManager] userId];
    
    self.wanpuWallService = [[[WanpuAdWallService alloc] initWithUserId:userId adUnitId:adUnitId] autorelease];
}

- (CommonAdWallService*)wallServiceByType:(PBRewardWallType)type forceShowWall:(BOOL)forceShowWall
{
    switch (type) {
            
        case PBRewardWallTypeWanpu:
            if (forceShowWall && self.wanpuWallService == nil){
                [self createWanpuWall];
            }
            
            return self.wanpuWallService;
            
            break;
            
        case PBRewardWallTypeLimei:
        default:
            
            if (forceShowWall && self.limeiWallService == nil){
                [self createLimeiWall];
            }
            
            return self.limeiWallService;
            

    }
    
    return nil;
}

- (void)queryWallScore
{
    NSString* userId = [[UserManager defaultManager] userId];
    if ([userId length] == 0)
        return;
    
    AdWallCompleteHandler handler = ^(int resultCode, int score) {
        
        BOOL awardIngot = ([GameApp wallRewardCoinType] == PBGameCurrencyIngot);
        NSString* message = nil;
        if (awardIngot){
            [[AccountService defaultService] chargeAccount:score source:LmAppReward];
            message = [NSString stringWithFormat:NSLS(@"kWallRewardCoinMessage"), score];
        }
        else{
            [[AccountService defaultService] chargeIngot:score source:LmAppReward];
            message = [NSString stringWithFormat:NSLS(@"kWallRewardIngotMessage"), score];
        }
        
        [[CommonMessageCenter defaultCenter] postMessageWithText:message delayTime:0];
    };
    
    [self.limeiWallService queryScore:userId completeHandler:handler];
    
}

- (void)showWall:(UIViewController*)superController wallType:(PBRewardWallType)wallType forceShowWall:(BOOL)forceShowWall
{
    NSString* userId = [[UserManager defaultManager] userId];
    if ([userId length] == 0)
        return;
    
    [[self wallServiceByType:wallType forceShowWall:forceShowWall] show:superController userId:userId];
}

@end
