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
#import "UserManager.h"

//#define IPHONE_WALL_ID     ([GameApp lmWallId])  //@"ed21340370b99ad5bd2a5e304e3ea6c4"

@implementation LmWallService

@synthesize adWallView = _adWallView;

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
//    [[LmmobAdWallSDK defaultSDK] GetAdWallWithEntranceID:IPHONE_WALL_ID AndDelegate:self];

    PPDebug(@"<LmmobAdWallSDK> init with ID %@", [GameApp lmwallId]);

    self.adWallView = [[[immobView alloc] initWithAdUnitID:[GameApp lmwallId]] autorelease];
    
    //此属性针对多账户用户，主要用于区分不同账户下的积分
    if ([[UserManager defaultManager] hasUser]){
        [_adWallView.UserAttribute setObject:[[UserManager defaultManager] userId] 
                                      forKey:@"accountname"];
    }
    _adWallView.delegate=self;
        
}

- (id)init
{
    self = [super init];
    [self prepareWallService];
    return self;
}

- (void)dealloc
{
    PPRelease(_adWallView);
    [super dealloc];
}

- (void)queryScore
{
    if ([[UserManager defaultManager] hasUser] == NO)
        return;
    
//    [[LmmobAdWallSDK defaultSDK] ScoreQuery];
    
    PPDebug(@"<LmmobAdWallSDK> ScoreQuery");    
    NSString* userId = [[UserManager defaultManager] userId];
    [self.adWallView immobViewQueryScoreWithAdUnitID:[GameApp lmwallId] WithAccountID:userId];
}

- (void)show:(UIViewController*)viewController
{        
    [MobClick event:@"SHOW_LM_WALL"];
    
    _viewController = viewController;
    [self.adWallView immobViewRequest];    
    
//    if([[LmmobAdWallSDK defaultSDK] lmmob]){
//        [_viewController presentModalViewController:[[LmmobAdWallSDK defaultSDK] lmmob] animated:YES];
//    }    
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



/**
 *email phone sms等所需要
 *返回当前添加immobView的ViewController
 */
- (UIViewController *)immobViewController{    
    return _viewController;
}

/**
 *根据广告的状态来决定当前广告是否展示到当前界面上 AdReady 
 *YES  当前广告可用
 *NO   当前广告不可用
 */
- (void) immobViewDidReceiveAd:(BOOL)AdReady{
    PPDebug(@"<immobViewDidReceiveAd> AdReady=%d", AdReady);
    if (AdReady){
        [_viewController.view addSubview:self.adWallView];
        [self.adWallView immobViewDisplay];
    }
    
}



///*! 
// @method      LmmobAdWallSDK:DismissAdWall:
// 
// @abstract    广告墙返回按钮的事件
// 
// @param
// sdk          sdk == [LmmobAdWallSDK defaultSDK]
// 
// @param
// result       YES
// */
//-(void)LmmobAdWallSDK:(LmmobAdWallSDK *)sdk DismissAdWall:(BOOL)result
//{
//    PPDebug(@"<LmmobAdWallSDK> DismissAdWall, result=%d", result);
//    if (sdk.lmmob) {
//        [_viewController dismissModalViewControllerAnimated:YES];
//    }
//}


///*! 
// @method      LmmobAdWallSDK:AdWallisON:
// 
// @abstract    [[LmmobAdWallSDK defaultSDK] GetAdWallWithEntranceID:AndDelegate:]方法的回调
// 
// @param
// sdk          sdk == [LmmobAdWallSDK defaultSDK]
// 
// @param
// result         广告墙开关值
// */
//-(void)LmmobAdWallSDK:(LmmobAdWallSDK *)sdk AdWallisON:(BOOL)result
//{
//    PPDebug(@"<LmmobAdWallSDK> AdWallisON, result=%d", result);
//    [[LmmobAdWallSDK defaultSDK] ScoreQuery];
//}


/*! 
 @method      LmmobAdWallSDK:UserScore:ScoreUpdated:
 
 @abstract    [[LmmobAdWallSDK defaultSDK] ScoreSubstract:]的回调
 
 @param
 sdk          sdk == [LmmobAdWallSDK defaultSDK]
 
 @param
 score        用户积分值,double
 result       更新用户积分是否成功
 */
//-(void)LmmobAdWallSDK:(LmmobAdWallSDK *)sdk UserScore:(double)score ScoreUpdated:(BOOL)result

/**
 *查询积分接口回调
 */
- (void) immobViewQueryScore:(NSUInteger)score WithMessage:(NSString *)returnMessage
{
    PPDebug(@"<LmmobAdWallSDK> UserQueryScore, score=%d, message=%@", score, returnMessage);
    
    if (score <= 0.0f)
        return;
    
    // charge account
    [[AccountService defaultService] chargeAccount:score source:LmAppReward];
    
//    [[LmmobAdWallSDK defaultSDK] ScoreSubstract:score];
    [self.adWallView immobViewReducscore:score WithAdUnitID:[GameApp lmwallId]];

    BOOL isForRemoveAd = NO;
    if ([self isWallForRemoveAd]){
        [[AdService defaultService] setAdDisable];
        [self clearWallForRemoveAd];
        isForRemoveAd = YES;
    }
    
    NSString* title;
    NSString* message;
    
    if (isForRemoveAd){
        title = @"广告已移除";
        message = [NSString stringWithFormat:@"成功下载和使用应用，广告已移除，同时您获取了%d金币",(int)score-1] ;        
    }
    else{
        title = @"免费金币";
        message = [NSString stringWithFormat:@"成功下载应用后获取了%d金币",(int)score] ;
    }        
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil 
                                          cancelButtonTitle:@"知道了" 
                                          otherButtonTitles:nil];
    
    [alert show];
    [alert release];
    
    
}

- (void) immobViewReducscore:(BOOL)status WithMessage:(NSString *)message
{
    PPDebug(@"<ReduceScore> status=%d, message=%@", status, message);
}

///*! 
// @method      LmmobAdWallSDK:BannerAdRemoved:
// 
// @abstract    [[LmmobAdWallSDK defaultSDK] RemoveBannerAd]的回调
// 
// @param
// sdk          sdk == [LmmobAdWallSDK defaultSDK]
// 
// @param
// result       Banner广告是否永久移除成功/关闭关联的广告位是否成功
// */
//-(void)LmmobAdWallSDK:(LmmobAdWallSDK *)sdk BannerAdRemoved:(BOOL)result
//{
//    PPDebug(@"<LmmobAdWallSDK> BannerAdRemoved, result=%d", result);
//    
//}
//
///*! 
// @method      LmmobAdWallSDK:didFailedWithNetError:
// 
// @abstract    [[LmmobAdWallSDK defaultSDK] RemoveBannerAd]的回调
// 
// @param
// sdk          sdk == [LmmobAdWallSDK defaultSDK]
// 
// @param
// error        网络错误返回信息
// */
//-(void)LmmobAdWallSDK:(LmmobAdWallSDK *)sdk didFailedWithNetError:(NSError *)error
//{
//    PPDebug(@"<LmmobAdWallSDK> BannerAdRemoved, error=%@", [error description]);    
//}

- (void) immobView: (immobView*) immobView didFailReceiveimmobViewWithError: (NSInteger) errorCode{
    PPDebug(@"<didFailReceiveimmobViewWithError> errorCode:%i",errorCode);
}

- (void) onDismissScreen:(immobView *)immobView{
    PPDebug(@"<onDismissScreen> immobView");
    _viewController = nil;
}

@end
