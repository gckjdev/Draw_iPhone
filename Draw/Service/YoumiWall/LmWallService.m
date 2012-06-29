//
//  LmWallService.m
//  Draw
//
//  Created by  on 12-6-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "LmWallService.h"
#import "PPDebug.h"
#import "MobClick.h"
#import "AccountService.h"
#import "UIUtils.h"
#import "AdService.h"

#define IPHONE_WALL_ID      @"ed21340370b99ad5bd2a5e304e3ea6c4"

@implementation LmWallService

static LmWallService* _defaultService;

+ (LmWallService*)defaultService
{
    if (_defaultService == nil){
        _defaultService = [[LmWallService alloc] init];
    }
    
    return _defaultService;
}


- (void)prepareWallService
{
    PPDebug(@"<LmmobAdWallSDK> GetAdWallWithEntranceID");
    [[LmmobAdWallSDK defaultSDK] GetAdWallWithEntranceID:IPHONE_WALL_ID AndDelegate:self];
}

- (id)init
{
    self = [super init];
    [self prepareWallService];
    return self;
}

- (void)queryScore
{
    PPDebug(@"<LmmobAdWallSDK> ScoreQuery");    
    [[LmmobAdWallSDK defaultSDK] ScoreQuery];
}

- (void)show:(UIViewController*)viewController
{
    
    
    [MobClick event:@"SHOW_LM_WALL"];
    _viewController = viewController;
    if([[LmmobAdWallSDK defaultSDK] lmmob]){
        [_viewController presentModalViewController:[[LmmobAdWallSDK defaultSDK] lmmob] animated:YES];
    }    
}

- (void)setWallForRemoveAd
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@"1" forKey:@"WALL_FOR_REMOVE_AD"];
    [userDefaults synchronize];    
}

- (void)clearWallForRemoveAd
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:@"WALL_FOR_REMOVE_AD"];
}

- (BOOL)isWallForRemoveAd
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    return ([userDefaults objectForKey:@"WALL_FOR_REMOVE_AD"] != nil);
}

- (void)show:(UIViewController*)viewController isForRemoveAd:(BOOL)isForRemoveAd
{
    [self setWallForRemoveAd];
    [self show:viewController];    
}

/*! 
 @method      LmmobAdWallSDK:DismissAdWall:
 
 @abstract    广告墙返回按钮的事件
 
 @param
 sdk          sdk == [LmmobAdWallSDK defaultSDK]
 
 @param
 result       YES
 */
-(void)LmmobAdWallSDK:(LmmobAdWallSDK *)sdk DismissAdWall:(BOOL)result
{
    PPDebug(@"<LmmobAdWallSDK> DismissAdWall, result=%d", result);
    if (sdk.lmmob) {
        [_viewController dismissModalViewControllerAnimated:YES];
    }
}


/*! 
 @method      LmmobAdWallSDK:AdWallisON:
 
 @abstract    [[LmmobAdWallSDK defaultSDK] GetAdWallWithEntranceID:AndDelegate:]方法的回调
 
 @param
 sdk          sdk == [LmmobAdWallSDK defaultSDK]
 
 @param
 result         广告墙开关值
 */
-(void)LmmobAdWallSDK:(LmmobAdWallSDK *)sdk AdWallisON:(BOOL)result
{
    PPDebug(@"<LmmobAdWallSDK> AdWallisON, result=%d", result);
    [[LmmobAdWallSDK defaultSDK] ScoreQuery];
}


/*! 
 @method      LmmobAdWallSDK:UserScore:ScoreUpdated:
 
 @abstract    [[LmmobAdWallSDK defaultSDK] ScoreSubstract:]的回调
 
 @param
 sdk          sdk == [LmmobAdWallSDK defaultSDK]
 
 @param
 score        用户积分值,double
 result       更新用户积分是否成功
 */
-(void)LmmobAdWallSDK:(LmmobAdWallSDK *)sdk UserScore:(double)score ScoreUpdated:(BOOL)result
{
    PPDebug(@"<LmmobAdWallSDK> UserScore, score=%f, result=%d", score, result);
    
    if (score <= 0.0f)
        return;
    
    // charge account
    [[AccountService defaultService] chargeAccount:score source:LmAppReward];
    
    [[LmmobAdWallSDK defaultSDK] ScoreSubstract:score];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"免费金币"
                                                    message:[NSString stringWithFormat:@"成功下载应用后获取了%d金币",(int)score] 
                                                   delegate:nil 
                                          cancelButtonTitle:@"知道了" 
                                          otherButtonTitles:nil];
    
    [alert show];
    [alert release];
    
    if ([self isWallForRemoveAd]){
        [[AdService defaultService] setAdDisable];
        [self clearWallForRemoveAd];
    }
    
}


/*! 
 @method      LmmobAdWallSDK:BannerAdRemoved:
 
 @abstract    [[LmmobAdWallSDK defaultSDK] RemoveBannerAd]的回调
 
 @param
 sdk          sdk == [LmmobAdWallSDK defaultSDK]
 
 @param
 result       Banner广告是否永久移除成功/关闭关联的广告位是否成功
 */
-(void)LmmobAdWallSDK:(LmmobAdWallSDK *)sdk BannerAdRemoved:(BOOL)result
{
    PPDebug(@"<LmmobAdWallSDK> BannerAdRemoved, result=%d", result);
    
}

/*! 
 @method      LmmobAdWallSDK:didFailedWithNetError:
 
 @abstract    [[LmmobAdWallSDK defaultSDK] RemoveBannerAd]的回调
 
 @param
 sdk          sdk == [LmmobAdWallSDK defaultSDK]
 
 @param
 error        网络错误返回信息
 */
-(void)LmmobAdWallSDK:(LmmobAdWallSDK *)sdk didFailedWithNetError:(NSError *)error
{
    PPDebug(@"<LmmobAdWallSDK> BannerAdRemoved, error=%@", [error description]);    
}


@end
