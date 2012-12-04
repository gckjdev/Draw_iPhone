//
//  GameSNSService.m
//  Draw
//
//  Created by qqn_pipi on 12-11-22.
//
//

#import "GameSNSService.h"
#import "PPSNSIntegerationService.h"
#import "PPSNSCommonService.h"
#import "AccountService.h"
#import "Account.h"
#import "ConfigManager.h"

@implementation GameSNSService

+ (void)askFollowOfficialWeibo:(PPSNSType)snsType
{
    PPSNSCommonService* snsService = [[PPSNSIntegerationService defaultService] snsServiceByType:snsType];
    [snsService askFollowWithTitle:[GameApp askFollowTitle]
                    displayMessage:[GameApp askFollowMessage]
                           weiboId:[snsService officialWeiboId]
                      successBlock:^(NSDictionary *userInfo) {
                          
                          NSString* followKey = [NSString stringWithFormat:@"FOLLOW_SNS_%@_KEY", [snsService snsName]];
                          
                          
                          NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
                          BOOL key = [userDefaults boolForKey:followKey];
                          
                          if (key == NO){
                              PPDebug(@"follow user %@ and reward success", snsService.officialWeiboId);
                              [[AccountService defaultService] chargeAccount:[ConfigManager getFollowReward] source:FollowReward];
                              [userDefaults setBool:YES forKey:followKey];
                              [userDefaults synchronize];
                          }
                          else{
                              PPDebug(@"follow user %@ but already reward", snsService.officialWeiboId);
                          }
                          
                      } failureBlock:^(NSError *error) {
                          
                          PPDebug(@"askFollowOfficialWeibo but follow user failure, error=%@", [error description]);
                      }];
    
}

+ (void)askFollow:(PPSNSType)snsType snsWeiboId:(NSString*)weiboId
{
    PPSNSCommonService* snsService = [[PPSNSIntegerationService defaultService] snsServiceByType:snsType];
    
    [snsService askFollowWithTitle:[GameApp askFollowTitle]
                    displayMessage:[GameApp askFollowMessage]
                           weiboId:weiboId
                      successBlock:^(NSDictionary *userInfo) {

        NSString* followKey = [NSString stringWithFormat:@"FOLLOW_SNS_%@_KEY", [snsService snsName]];
        
                          
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        BOOL key = [userDefaults boolForKey:followKey];
        
        if (key == NO){
            PPDebug(@"follow user %@ and reward success", weiboId);
            [[AccountService defaultService] chargeAccount:[ConfigManager getFollowReward] source:FollowReward];
            [userDefaults setBool:YES forKey:followKey];
            [userDefaults synchronize];
        }
        else{
            PPDebug(@"follow user %@ but already reward", weiboId);
        }
        
    } failureBlock:^(NSError *error) {
        
        PPDebug(@"askFollow but follow user %@ failure, error=%@", weiboId, [error description]);
    }];
    
}

@end
