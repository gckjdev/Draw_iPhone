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
//#import "WanpuAdWallService.h"
#import "YoumiAdWallService.h"
#import "AderAdWallService.h"
#import "UserManager.h"
#import "ConfigManager.h"
#import "AccountService.h"
#import "CommonMessageCenter.h"
#import "DomobAdWallService.h"
#import "TapjoyAdWallService.h"

@implementation GameAdWallService

SYNTHESIZE_SINGLETON_FOR_CLASS(GameAdWallService)


- (id)init
{
    self = [super init];
    
    _wallServiceArray = [[NSMutableArray alloc] init];
    
    [self createWall:PBRewardWallTypeLimei forceCreate:NO];
//    [self createWall:PBRewardWallTypeWanpu forceCreate:NO];
    [self createWall:PBRewardWallTypeYoumi forceCreate:NO];
    [self createWall:PBRewardWallTypeAder forceCreate:NO];
    
    return self;
}

- (CommonAdWallService*)createWall:(int)type forceCreate:(BOOL)forceCreate
{
    switch (type){
        
        case PBRewardWallTypeLimei:
            if (forceCreate == YES || [ConfigManager isEnableLimeiWall]){
                CommonAdWallService* wallService = [self createLimeiWall];
                if (wallService)
                    [_wallServiceArray addObject:wallService];
                
                return wallService;
            }
            break;
            
        case PBRewardWallTypeWanpu:
            if ([ConfigManager isEnableWanpuWall]){
//                CommonAdWallService* wallService = [self createWanpuWall];
//                if (wallService)
//                    [_wallServiceArray addObject:wallService];
//
//                return wallService;
            }
            
        case PBRewardWallTypeYoumi:
            if ([ConfigManager isEnableYoumiWall]){
                CommonAdWallService* wallService = [self createYoumiWall];
                if (wallService)
                    [_wallServiceArray addObject:wallService];
                
                return wallService;
            }
            
        case PBRewardWallTypeAder:
            if ([ConfigManager isEnableAderWall]){
                CommonAdWallService* wallService = [self createAderWall];
                if (wallService)
                    [_wallServiceArray addObject:wallService];
                
                return wallService;
            }
        case PBRewardWallTypeDomod:
            if ([ConfigManager isEnableDomodWall]){
                CommonAdWallService* wallService = [self createDomodWall];
                if (wallService)
                    [_wallServiceArray addObject:wallService];
                
                return wallService;
            }
        case PBRewardWallTypeTapjoy:
            if ([ConfigManager isEnableTapjoyWall]){
                CommonAdWallService* wallService = [self createTapjoyWall];
                if (wallService)
                    [_wallServiceArray addObject:wallService];
                
                return wallService;
            }
        default:
            break;
    }
    
    return nil;
}

- (void)dealloc
{
    PPRelease(_wallServiceArray);
    [super dealloc];
}

- (CommonAdWallService*)createLimeiWall
{
    NSString* limeiAdId = [GameApp lmwallId];
    NSString* userId = [[UserManager defaultManager] userId];
    
    return [[[LimeiAdWallService alloc] initWithUserId:userId
                                              adUnitId:limeiAdId
                                          adUnitSecret:nil
                                                  type:PBRewardWallTypeLimei] autorelease];
}

//- (CommonAdWallService*)createWanpuWall
//{
//    NSString* adUnitId = [GameApp wanpuAdPublisherId];
//    NSString* userId = [[UserManager defaultManager] userId];
//    
//    return [[[WanpuAdWallService alloc] initWithUserId:userId
//                                              adUnitId:adUnitId
//                                          adUnitSecret:nil
//                                                  type:PBRewardWallTypeWanpu] autorelease];
//}

- (CommonAdWallService*)createYoumiWall
{
    NSString* adUnitId = [GameApp youmiWallId];
    NSString* adSecret = [GameApp youmiWallSecret];
    NSString* userId = [[UserManager defaultManager] userId];
    
    return [[[YoumiAdWallService alloc] initWithUserId:userId
                                              adUnitId:adUnitId
                                          adUnitSecret:adSecret
                                                  type:PBRewardWallTypeYoumi] autorelease];
}


- (CommonAdWallService*)createAderWall
{
    NSString* adUnitId = [GameApp aderWallId];
    NSString* userId = [[UserManager defaultManager] userId];
    
    return [[[AderAdWallService alloc] initWithUserId:userId
                                              adUnitId:adUnitId
                                          adUnitSecret:nil
                                                 type:PBRewardWallTypeAder] autorelease];
}

- (CommonAdWallService*)createDomodWall
{
    NSString* adUnitId = [GameApp domodWallId];
    NSString* userId = [[UserManager defaultManager] userId];
    
    return [[[DomobAdWallService alloc] initWithUserId:userId
                                             adUnitId:adUnitId
                                         adUnitSecret:nil
                                                 type:PBRewardWallTypeDomod] autorelease];
}

- (CommonAdWallService*)createTapjoyWall
{
    NSString* adUnitId = @"13b0ae6a-8516-4405-9dcf-fe4e526486b2";
    NSString* secret = @"XHdOwPa8de7p4aseeYP0";
    NSString* userId = [[UserManager defaultManager] userId];
    
    return [[[TapjoyAdWallService alloc] initWithUserId:userId
                                              adUnitId:adUnitId
                                          adUnitSecret:secret
                                                  type:PBRewardWallTypeTapjoy] autorelease];
}

- (CommonAdWallService*)wallServiceByType:(PBRewardWallType)type forceShowWall:(BOOL)forceShowWall
{
    for (CommonAdWallService* wallService in _wallServiceArray){
        if (wallService.type == type){
            return wallService;
        }
    }
    
    // not found
    if (forceShowWall){
        return [self createWall:type forceCreate:YES];
    }
    
    return nil;
}

- (void)queryWallScore
{
    NSString* userId = [[UserManager defaultManager] userId];
    if ([userId length] == 0)
        return;
    
    if ([ConfigManager wallEnabled] == NO){
        return;
    }
    
    AdWallCompleteHandler handler = ^(int resultCode, int score) {
        
        if (score > 0){
            BOOL awardIngot = ([GameApp wallRewardCurrencyType] == PBGameCurrencyIngot);
            NSString* message = nil;
            if (awardIngot){
                [[AccountService defaultService] chargeIngot:score source:LmAppReward];
                message = [NSString stringWithFormat:NSLS(@"kWallRewardIngotMessage"), score];
            }
            else{
                [[AccountService defaultService] chargeCoin:score source:LmAppReward];
                message = [NSString stringWithFormat:NSLS(@"kWallRewardCoinMessage"), score];
            }
            
            [[CommonMessageCenter defaultCenter] postMessageWithText:message delayTime:2];
        }
    };
    
    for (CommonAdWallService* wallService in _wallServiceArray){
        [wallService queryScore:userId completeHandler:handler];
    }
    
}

- (void)showWall:(UIViewController*)superController wallType:(PBRewardWallType)wallType forceShowWall:(BOOL)forceShowWall
{
    NSString* userId = [[UserManager defaultManager] userId];
    if ([userId length] == 0)
        return;
    
    [[self wallServiceByType:wallType forceShowWall:forceShowWall] show:superController userId:userId];
}

@end
