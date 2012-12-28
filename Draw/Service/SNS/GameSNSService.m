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
#import "PPViewController.h"
#import "UserService.h"
#import "UserManager.h"

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

//+ (void)bindSNS:(int)snsType viewController:(PPViewController<UserServiceDelegate>*)viewController
//{
//    PPSNSCommonService* service = [[PPSNSIntegerationService defaultService] snsServiceByType:snsType];
//    NSString* name = [service snsName];
//    
//    [service logout];
//    
//    [service login:^(NSDictionary *userInfo) {
//        PPDebug(@"%@ Login Success", name);
//        
//        [viewController showActivityWithText:NSLS(@"Loading")];
//        
//        [service readMyUserInfo:^(NSDictionary *userInfo) {
//            [viewController hideActivity];
//            PPDebug(@"%@ readMyUserInfo Success, userInfo=%@", name, [userInfo description]);
//            UserManager* userManager = [UserManager defaultManager];
//            [[UserService defaultService] updateUserWithSNSUserInfo:[userManager userId]
//                                                           userInfo:userInfo
//                                                     viewController:viewController];
//            
//            // ask follow official weibo account here
//            [GameSNSService askFollow:snsType snsWeiboId:[service officialWeiboId]];
//            
//        } failureBlock:^(NSError *error) {
//            [viewController hideActivity];
//            PPDebug(@"%@ readMyUserInfo Failure", name);
//        }];
//        
//    } failureBlock:^(NSError *error) {
//        PPDebug(@"%@ Login Failure", name);
//    }];
//}

@end
