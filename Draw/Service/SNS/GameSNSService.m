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
#import "CommonDialog.h"
#import "SNSUtils.h"
#import "CommonMessageCenter.h"

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
                              [[AccountService defaultService] chargeCoin:[ConfigManager getFollowReward] source:FollowReward];
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

+ (NSString*)followKey:(PPSNSCommonService*)snsService
{
    NSString* key = [NSString stringWithFormat:@"FOLLOW_SNS_%@_KEY", [snsService snsName]];
    return key;
}

+ (BOOL)hasFollowOfficialWeibo:(PPSNSCommonService*)snsService
{
    NSString* followKey = [self followKey:snsService];
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL value = [userDefaults boolForKey:followKey];
    return value;
}

+ (void)updateFollowOfficialWeibo:(PPSNSCommonService*)snsService
{
    NSString* followKey = [self followKey:snsService];
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [[AccountService defaultService] chargeCoin:[ConfigManager getFollowReward] source:FollowReward];
    [userDefaults setBool:YES forKey:followKey];
    [userDefaults synchronize];
    return;
}

+ (void)askFollow:(PPSNSType)snsType snsWeiboId:(NSString*)weiboId
{
    PPSNSCommonService* snsService = [[PPSNSIntegerationService defaultService] snsServiceByType:snsType];
    if ([snsService supportFollow] == NO)
        return;
    
    [snsService askFollowWithTitle:[GameApp askFollowTitle]
                    displayMessage:[GameApp askFollowMessage]
                           weiboId:weiboId
                      successBlock:^(NSDictionary *userInfo) {

        if ([self hasFollowOfficialWeibo:snsService] == NO){
            PPDebug(@"follow user %@ and reward success", weiboId);
            [self updateFollowOfficialWeibo:snsService];
        }
        else{
            PPDebug(@"follow user %@ but already reward", weiboId);
        }
        
    } failureBlock:^(NSError *error) {
        
        PPDebug(@"askFollow but follow user %@ failure, error=%@", weiboId, [error description]);
    }];
    
}

+ (NSString*)snsOfficialNick:(int)type
{
    PPSNSCommonService* snsService = [[PPSNSIntegerationService defaultService] snsServiceByType:type];
    if (snsService == nil)
        return @"";
    
    return [NSString stringWithFormat:@"@%@", [snsService officialWeiboId]];
}

+ (void)askRebindQQ:(UIViewController*)viewController
{
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kMessage") message:NSLS(@"kRebindQQ") style:CommonDialogStyleDoubleButton delegate:nil clickOkBlock:^{
        [SNSUtils bindSNS:TYPE_QQ succ:^(NSDictionary *userInfo) {
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kBindQQWeibo") delayTime:1 isHappy:YES];
        } failure:^{
            //
        }];
    } clickCancelBlock:^{
        //
    }];
    [dialog showInView:viewController.view];
}

+ (void)askRebindSina:(UIViewController*)viewController
{
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kMessage") message:NSLS(@"kRebindSina") style:CommonDialogStyleDoubleButton delegate:nil clickOkBlock:^{
        [SNSUtils bindSNS:TYPE_SINA succ:^(NSDictionary *userInfo){
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kBindSinaWeibo") delayTime:1 isHappy:YES];
        } failure:^{
            //
        }];
    } clickCancelBlock:^{
        //
    }];
    [dialog showInView:viewController.view];
}

+ (void)askRebindFacebook:(UIViewController*)viewController
{
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kMessage") message:NSLS(@"kRebindFacebook") style:CommonDialogStyleDoubleButton delegate:nil clickOkBlock:^{
        [SNSUtils bindSNS:TYPE_FACEBOOK succ:^(NSDictionary *userInfo){
            [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kBindFacebook") delayTime:1 isHappy:YES];
        } failure:^{
            
        }];
    } clickCancelBlock:^{
        //
    }];
    [dialog showInView:viewController.view];
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
