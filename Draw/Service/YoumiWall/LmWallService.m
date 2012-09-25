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
#import "ConfigManager.h"

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
    [AdService defaultService]; // Call This To Init WANPU SDK

    // init WANPU SDK Wall Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getUpdatedPoints:) name:WAPS_GET_POINTS_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getUpdatedPointsFailed:) name:WAPS_GET_POINTS_FAILED object:nil];
    
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
     
    if ([ConfigManager wallType] == WallTypeLimei){
        NSString* userId = [[UserManager defaultManager] userId];
        PPDebug(@"<LmmobAdWallSDK> UserQueryScore");    
        [self.adWallView immobViewQueryScoreWithAdUnitID:[GameApp lmwallId] WithAccountID:userId];
    }
    else{
        PPDebug(@"<WanpuWall> getPoints");    
        [AppConnect getPoints];        
    }
}

- (void)show:(UIViewController*)viewController
{        
    switch ([ConfigManager wallType]) {
        case WallTypeLimei:
        {
            [MobClick event:@"SHOW_LM_WALL"];    
            _viewController = viewController;
            [self.adWallView immobViewRequest];         
            
        }
            break;
            
        case WallTypeWanpu:
        default:
        {
            [MobClick event:@"SHOW_WP_WALL"];    
            [AppConnect showOffers];            
        }
            break;
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

- (void)handleScoreAdded:(int)score
{
    // charge account
    [[AccountService defaultService] chargeAccount:score source:LmAppReward];
    
    NSString* userId = [[UserManager defaultManager] userId];
    
    if ([ConfigManager wallType] == WallTypeLimei){
        [self.adWallView immobViewReduceScore:score WithAdUnitID:[GameApp lmwallId] WithAccountID:userId];
    }
    else{
        [AppConnect spendPoints:score];
    }
    
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
- (void) immobViewDidReceiveAd{
    PPDebug(@"<immobViewDidReceiveAd>");
    if ([self.adWallView isAdReady]){
        [_viewController.view addSubview:self.adWallView];
        [self.adWallView immobViewDisplay];
    }    
}

- (void) immobViewQueryScore:(NSUInteger)score WithMessage:(NSString *)returnMessage
{
    PPDebug(@"<LmmobAdWallSDK> UserQueryScore, score=%d, message=%@", score, returnMessage);
    
    if (score <= 0.0f)
        return;
    
    [self handleScoreAdded:score];
}

- (void) immobViewReduceScore:(BOOL)status WithMessage:(NSString *)message
{
    PPDebug(@"<ReduceScore> status=%d, message=%@", status, message);
}

- (void) immobView: (immobView*) immobView didFailReceiveimmobViewWithError: (NSInteger) errorCode{
    PPDebug(@"<didFailReceiveimmobViewWithError> errorCode:%i",errorCode);
}

- (void) onDismissScreen:(immobView *)immobView{
    PPDebug(@"<onDismissScreen> immobView");
    _viewController = nil;
}

#pragma mark - Wap Pu Wall For Query Points
//获取积分成功处理方法:
-(void)getUpdatedPoints:(NSNotification*)notifyObj{
    WapsUserPoints *userPoints = notifyObj.object;
    NSString *pointsName=[userPoints getPointsName];
    int pointsValue=[userPoints getPointsValue];
    
    PPDebug(@"Wappu SDK <getUpdatedPoints> success, name=%@, points=%d", 
            pointsName, pointsValue);
    if (pointsValue <= 0)
        return;

    [self handleScoreAdded:pointsValue];
}
//获取积分失败处理方法:
-(void)getUpdatedPointsFailed:(NSNotification*)notifyObj{
    PPDebug(@"Wappu SDK <getUpdatedPoints> failure, info=%@", [notifyObj.object description]);
}

@end
