//
//  GameSNSService.m
//  Draw
//
//  Created by qqn_pipi on 12-11-22.
//
//

#import "GameSNSService.h"
//#import "PPSNSIntegerationService.h"
//#import "PPSNSCommonService.h"
#import "AccountService.h"
#import "Account.h"
#import "PPConfigManager.h"
#import "PPViewController.h"
#import "UserService.h"
#import "UserManager.h"
#import "CommonDialog.h"
#import "SNSUtils.h"
#import "CommonMessageCenter.h"
#import "WXApi.h"
#import <TencentOpenAPI/QQApi.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "GTMBase64.h"
#import <ShareSDK/ShareSDK.h>
#import "WeiboApi.h"
#import "TaskManager.h"
//#import "ZeroQianManager.h"

GameSNSService* _defaultSNSService;

@implementation GameSNSService

+ (GameSNSService*)defaultService
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultSNSService = [[GameSNSService alloc] init];
    });
    
    return _defaultSNSService;
}

- (id)init
{
    self = [super init];
    if (self){
        
        PPDebug(@"before registerApp");
        [ShareSDK registerApp:[PPConfigManager getShareSDKAppId]];
        PPDebug(@"after registerApp");
        
        //添加新浪微博应用
        [ShareSDK connectSinaWeiboWithAppKey:[GameApp sinaAppKey]       //  @"3201194191"
                                   appSecret:[GameApp sinaAppSecret]    //  @"0334252914651e8f76bad63337b3b78f"
                                 redirectUri:[GameApp sinaAppRedirectURI]]; // @"http://appgo.cn"];
        
        PPDebug(@"end registerApp SINA Weibo");
        
        //添加腾讯微博应用
        [ShareSDK connectTencentWeiboWithAppKey:[GameApp qqAppKey]          //@"801307650"
                                      appSecret:[GameApp qqAppSecret]       // @"ae36f4ee3946e1cbb98d6965b0b2ff5c"
                                    redirectUri:[GameApp qqAppRedirectURI]  // @"http://www.sharesdk.cn"];
                                       wbApiCls:[WeiboApi class]];
        
        PPDebug(@"end registerApp QQ Weibo");

        //添加Facebook应用
        [ShareSDK connectFacebookWithAppKey:[GameApp facebookAppKey]   //@"107704292745179"
                                  appSecret:[GameApp facebookAppSecret]]; // @"38053202e1a5fe26c80c753071f0b573"];
        

        PPDebug(@"end registerApp Facebook");
        
        [ShareSDK connectWeChatWithAppId:[GameApp weixinId] // @"wx6dd7a9b94f3dd72a"        //此参数为申请的微信AppID
                               wechatCls:[WXApi class]];

        PPDebug(@"end registerApp WeChat");
        
//        if ([DeviceDetection isOS6] == NO){
//            //添加QQ应用(QQ空间)
//            [ShareSDK connectQQWithQZoneAppKey:[GameApp qqSpaceAppId]                //该参数填入申请的QQ AppId
//                             qqApiInterfaceCls:[QQApiInterface class]
//                               tencentOAuthCls:[TencentOAuth class]];
//
//            //添加QQ应用(QQ空间)
//            [ShareSDK connectQZoneWithAppKey:[GameApp qqSpaceAppId]                //该参数填入申请的QQ AppId
//                                   appSecret:[GameApp qqSpaceAppKey]];
//
//            PPDebug(@"end registerApp QZone");
//        }
        
        PPDebug(@"end registerApp all");
        
        // clear SNS local data if expired
        [self cleanSNSInfoIfExpired:ShareTypeSinaWeibo];
        [self cleanSNSInfoIfExpired:ShareTypeTencentWeibo];
        [self cleanSNSInfoIfExpired:ShareTypeFacebook];
        
        PPDebug(@"end clean expire all");
        
    }
    
    return self;
}

//+ (void)askFollowOfficialWeibo:(PPSNSType)snsType
//{
//    PPSNSCommonService* snsService = [[PPSNSIntegerationService defaultService] snsServiceByType:snsType];
//    [snsService askFollowWithTitle:[GameApp askFollowTitle]
//                    displayMessage:[GameApp askFollowMessage]
//                           weiboId:[snsService officialWeiboId]
//                      successBlock:^(NSDictionary *userInfo) {
//                          
//                          NSString* followKey = [NSString stringWithFormat:@"FOLLOW_SNS_%@_KEY", [snsService snsName]];
//                          
//                          
//                          NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
//                          BOOL key = [userDefaults boolForKey:followKey];
//                          
//                          if (key == NO){
//                              PPDebug(@"follow user %@ and reward success", snsService.officialWeiboId);
//                              [[AccountService defaultService] chargeCoin:[PPConfigManager getFollowReward] source:FollowReward];
//                              [userDefaults setBool:YES forKey:followKey];
//                              [userDefaults synchronize];
//                          }
//                          else{
//                              PPDebug(@"follow user %@ but already reward", snsService.officialWeiboId);
//                          }
//                          
//                      } failureBlock:^(NSError *error) {
//                          
//                          PPDebug(@"askFollowOfficialWeibo but follow user failure, error=%@", [error description]);
//                      }];
//    
//}
//
//+ (NSString*)followKey:(PPSNSCommonService*)snsService
//{
//    NSString* key = [NSString stringWithFormat:@"FOLLOW_SNS_%@_KEY", [snsService snsName]];
//    return key;
//}
//
//+ (BOOL)hasFollowOfficialWeibo:(PPSNSCommonService*)snsService
//{
//    NSString* followKey = [self followKey:snsService];
//    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
//    BOOL value = [userDefaults boolForKey:followKey];
//    return value;
//}
//
//+ (void)updateFollowOfficialWeibo:(PPSNSCommonService*)snsService
//{
//    NSString* followKey = [self followKey:snsService];
//    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
//    [[AccountService defaultService] chargeCoin:[PPConfigManager getFollowReward] source:FollowReward];
//    [userDefaults setBool:YES forKey:followKey];
//    [userDefaults synchronize];
//    return;
//}
//
//+ (void)askFollow:(PPSNSType)snsType snsWeiboId:(NSString*)weiboId
//{
//    PPSNSCommonService* snsService = [[PPSNSIntegerationService defaultService] snsServiceByType:snsType];
//    if ([snsService supportFollow] == NO)
//        return;
//    
//    [snsService askFollowWithTitle:[GameApp askFollowTitle]
//                    displayMessage:[GameApp askFollowMessage]
//                           weiboId:weiboId
//                      successBlock:^(NSDictionary *userInfo) {
//
//        if ([self hasFollowOfficialWeibo:snsService] == NO){
//            PPDebug(@"follow user %@ and reward success", weiboId);
//            [self updateFollowOfficialWeibo:snsService];
//        }
//        else{
//            PPDebug(@"follow user %@ but already reward", weiboId);
//        }
//        
//    } failureBlock:^(NSError *error) {
//        
//        PPDebug(@"askFollow but follow user %@ failure, error=%@", weiboId, [error description]);
//    }];
//    
//}
//
//+ (NSString*)snsOfficialNick:(int)type
//{
//    PPSNSCommonService* snsService = [[PPSNSIntegerationService defaultService] snsServiceByType:type];
//    if (snsService == nil)
//        return @"";
//    
//    return [NSString stringWithFormat:@"@%@", [snsService officialWeiboId]];
//}
//

- (void)askRebindQQ:(UIViewController*)viewController
{
    
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kMessage")
                                                       message:NSLS(@"kRebindQQ")
                                                         style:CommonDialogStyleDoubleButton];
     [dialog setClickOkBlock:^(UILabel *label){
         
         [self autheticate:TYPE_QQ];
         
//          [SNSUtils bindSNS:TYPE_QQ succ:^(NSDictionary *userInfo) {
//              [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kBindQQWeibo") delayTime:1 isHappy:YES];
//          } failure:^{
//              //
//          }];
     }];
    
    [dialog showInView:viewController.view];
}

- (void)askRebindSina:(UIViewController*)viewController
{
    
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kMessage")
                                                       message:NSLS(@"kRebindSina")
                                                         style:CommonDialogStyleDoubleButton];
     [dialog setClickOkBlock:^(UILabel *label){
         
         [self autheticate:TYPE_SINA];
         
//          [SNSUtils bindSNS:TYPE_SINA succ:^(NSDictionary *userInfo){
//              [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kBindSinaWeibo") delayTime:1 isHappy:YES];
//          } failure:^{
//              //
//          }];
     }];
    
    [dialog showInView:viewController.view];
}

- (void)askRebindFacebook:(UIViewController*)viewController
{
    CommonDialog *dialog = [CommonDialog createDialogWithTitle:NSLS(@"kMessage")
                                                       message:NSLS(@"kRebindFacebook")
                                                         style:CommonDialogStyleDoubleButton];
    [dialog setClickOkBlock:^(UILabel *label){
        
        [self autheticate:TYPE_FACEBOOK];
        
//        [SNSUtils bindSNS:TYPE_FACEBOOK succ:^(NSDictionary *userInfo){
//          [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kBindFacebook") delayTime:1 isHappy:YES];
//        } failure:^{
//          
//        }];
    }];
    
    [dialog showInView:viewController.view];
}

+ (ShareType)shareSDKType:(PPSNSType)snsType
{
    switch (snsType) {
            
            
        case TYPE_SINA:
            return ShareTypeSinaWeibo;

        case TYPE_QQ:
            return ShareTypeTencentWeibo;

        case TYPE_FACEBOOK:
            return ShareTypeFacebook;
            
        case TYPE_WEIXIN_SESSION:
            return ShareTypeWeixiSession;

        case TYPE_WEIXIN_TIMELINE:
            return ShareTypeWeixiTimeline;
            
        case TYPE_QQSPACE:
            return ShareTypeQQSpace;            
            
        default:
            PPDebug(@"Warning!!!!!!!!!!! Share SDK Type not match for snsType(%d)", snsType);
            return ShareTypeAny;
    }
}

- (BOOL)isAuthenticated:(PPSNSType)snsType
{
    ShareType shareType = [GameSNSService shareSDKType:snsType];
    if (shareType == ShareTypeAny){
        return NO;
    }
    
    return [ShareSDK hasAuthorizedWithType:shareType];
    
//    id<ISSPlatformCredential> credential = [ShareSDK getCredentialWithType:shareType];    //传入获取授权信息的类型
//    id<ISSOAuth2Credential> cred = (id<ISSOAuth2Credential>)credential;           //转换为OAuth2授权凭证
//    PPDebug(@"<isAuthenticated> shareType=%d, accessToken = %@, expiresIn = %@",
//            shareType, [cred accessToken], [cred expiresIn]);
//    
//    if (cred == nil){
//        return NO;
//    }
//    else{
//        return YES;
//    }
}

- (BOOL)isExpired:(PPSNSType)snsType
{
    ShareType shareType = [GameSNSService shareSDKType:snsType];
    if (shareType == ShareTypeAny){
        return NO;
    }
    
    if ([self isAuthenticated:snsType] == NO){
        return YES;
    }
    
    id<ISSPlatformCredential> credential = [ShareSDK getCredentialWithType:shareType];    //传入获取授权信息的类型
    id<ISSPlatformCredential> cred = (id<ISSPlatformCredential>)credential;           //转换为OAuth2授权凭证
    PPDebug(@"<isExpired> shareType=%d, accessToken = %@, expiresIn = %@, available=%d", shareType, [cred token], [cred expired], [cred available]);

    return [cred available] == NO;
    
//    if (cred == nil){
//        return YES;
//    }
//    else if ([[cred expired] timeIntervalSinceNow] <= 0){
//        return YES;
//    }
//    else{
//        return NO;
//    }    
}

- (void)autheticate:(PPSNSType)snsType
{
    ShareType shareType = [GameSNSService shareSDKType:snsType];
    if (shareType == ShareTypeAny){
        return;
    }
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];  // _appDelegate.viewDelegate]; TODO check
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:[GameSNSService snsOfficialNick:snsType]],
                                    SHARE_TYPE_NUMBER(shareType),
                                    nil]];
    
    [ShareSDK authWithType:shareType                                            //需要授权的平台类型
                   options:authOptions                                          //授权选项，包括视图定制，自动授权
                    result:^(SSAuthState state, id<ICMErrorInfo> error) {       //授权返回后的回调方法
                        if (state == SSAuthStateSuccess)
                        {
                            // TODO save user weibo bind info, get user infomation here and upload user information to server
                            [self readUserInfoAndUpdateToServer:shareType];

                            CLEARMSG;
                            POSTMSG2(NSLS(@"kAuthorizeSuccess"), 2);
                            PPDebug(@"autheticate shareType(%d) success", shareType);
                            
                            
                        }
                        else if (state == SSAuthStateFail)
                        {
                            CLEARMSG;
                            POSTMSG(NSLS(@"kAuthorizeFailure"));
                            PPDebug(@"autheticate shareType(%d) failure, error=%@", shareType, [error errorDescription]);
                        }
                        else if (state == SSAuthStateBegan){
                            POSTMSG2(NSLS(@"kAuthorizeOngoing"), 200);
                            PPDebug(@"autheticate shareType(%d) began", shareType);
                        }
                        else if (state == SSAuthStateCancel){
                            CLEARMSG;
                            POSTMSG2(NSLS(@"kAuthorizeCancel"), 2);
                            PPDebug(@"autheticate shareType(%d) cancel", shareType);
                        }
                        else{
                            PPDebug(@"autheticate shareType(%d) unknown state(%d), error=%@", shareType, state, [error errorDescription]);
                        }
                    }];
}

- (void)cancelAuthentication:(PPSNSType)snsType
{
    ShareType shareType = [GameSNSService shareSDKType:snsType];
    if (shareType == ShareTypeAny){
        return;
    }

    [ShareSDK cancelAuthWithType:shareType];
}

- (void)followUser:(PPSNSType)snsType weiboId:(NSString*)weiboId weiboName:(NSString*)weiboName
{
    ShareType shareType = [GameSNSService shareSDKType:snsType];
    if (shareType == ShareTypeAny){
        return;
    }
    
    SSUserFieldType fieldType = SSUserFieldTypeUid;
    NSString* field = weiboId;
    if ([weiboId length] == 0 && [weiboName length] > 0){
        fieldType = SSUserFieldTypeName;
        field = weiboName;
    }
    
    if ([field length] == 0){
        PPDebug(@"<followUser> but field(%@) is nil", field);
        return;
    }
    
    PPDebug(@"<followUser> field(%@) type(%d) shareType(%d) weiboId(%@) weiboNick(%@)", field, fieldType, shareType, weiboId, weiboName);
    
    BOOL needUpdateUserInfo = [self isExpired:snsType];
    

    
    //关注用户
    [ShareSDK followUserWithType:shareType              //平台类型
                           field:field                  //关注用户的名称或ID
                       fieldType:fieldType              //字段类型，用于指定第二个参数是名称还是ID
                     authOptions:nil                    //授权选项
                    viewDelegate:nil                    //授权视图委托
                          result:^(SSResponseState state, id<ISSPlatformUser> userInfo, id<ICMErrorInfo> error) {               //返回回调
                              if (state == SSResponseStateSuccess)
                              {
                                  // TODO save user weibo bind info, get user infomation here and upload user information to server
                                  if (needUpdateUserInfo){
                                      [self readUserInfoAndUpdateToServer:shareType];
                                  }
                                  
                                  POSTMSG(NSLS(@"kFollowSuccess"));
                              }
                              else if (state == SSResponseStateFail)
                              {
                                  POSTMSG(NSLS(@"kFollowFailure"));
                                  PPDebug(@"follow user failure, code=%d, error=%@", [error errorCode], error.errorDescription);
                                  
                              }
                          }];
}

- (void)postWeiboSuccessMessage:(NSString*)successMessage awardCoins:(int)awardCoins
{
    NSString* msg = nil;
    if ([successMessage length] > 0){
        
        if (awardCoins > 0){
            NSString* awardMsg = [NSString stringWithFormat:NSLS(@"kPublishWeiboAwardInfo"), awardCoins];
            msg = [NSString stringWithFormat:@"%@, %@", successMessage, awardMsg];
        }
        else{
            msg = successMessage;
        }
        
        POSTMSG2(msg, 2.5);
    }
}

- (void)handlePublishWeiboSuccess:(ShareType)shareType
                            state:(SSResponseState)state
                            error:(id<ICMErrorInfo>)error
               needUpdateUserInfo:(BOOL)needUpdateUserInfo
                       awardCoins:(int)awardCoins
                   successMessage:(NSString*)successMessage
                   failureMessage:(NSString*)failureMessage
{
    if (state == SSPublishContentStateSuccess)
    {
        PPDebug(@"publish weibo success");
        
        // TODO save user weibo bind info, get user infomation here and upload user information to server
        if (needUpdateUserInfo){
            [self readUserInfoAndUpdateToServer:shareType];
        }
        
        [[AccountService defaultService] chargeCoin:awardCoins source:ShareWeiboReward];
        
        [self postWeiboSuccessMessage:successMessage awardCoins:awardCoins];
        
    }
    else if (state == SSPublishContentStateFail)
    {
//        NSString* msg = failureMessage;
//        if ([error.errorDescription length] > 0){
//            msg = [NSString stringWithFormat:@"%@, %@", failureMessage, error.errorDescription];
//        }
        POSTMSG2(failureMessage, 2.5);
        PPDebug(@"publish weibo failure, code=%d, error=%@", [error errorCode], error.errorDescription);
    }
}

- (void)publishWeibo:(PPSNSType)snsType
                text:(NSString*)text
       imageFilePath:(NSString*)imagePath
              inView:(UIView*)view
          awardCoins:(int)awardCoins
      successMessage:(NSString*)successMessage
      failureMessage:(NSString*)failureMessage
{
    [self publishWeibo:snsType
                  text:text
         imageFilePath:imagePath
                inView:view
            awardCoins:awardCoins
        successMessage:successMessage
        failureMessage:failureMessage
                taskId:0];
}

- (void)publishWeibo:(PPSNSType)snsType
                text:(NSString*)text
       imageFilePath:(NSString*)imagePath
              inView:(UIView*)view
          awardCoins:(int)awardCoins
      successMessage:(NSString*)successMessage
      failureMessage:(NSString*)failureMessage
              taskId:(int)taskId
{
    [self publishWeibo:snsType
                  text:text
         imageFilePath:imagePath
              audioURL:nil
                 title:@""
                inView:view
            awardCoins:awardCoins
        successMessage:successMessage
        failureMessage:failureMessage
                taskId:taskId];
}

- (void)publishWeibo:(PPSNSType)snsType
                text:(NSString*)text
       imageFilePath:(NSString*)imagePath
            audioURL:(NSString*)audioURL
               title:(NSString*)title
              inView:(UIView*)view
          awardCoins:(int)awardCoins
      successMessage:(NSString*)successMessage
      failureMessage:(NSString*)failureMessage
{
    [self publishWeibo:snsType
                  text:text
         imageFilePath:imagePath
              audioURL:audioURL
                 title:title
                inView:view
            awardCoins:awardCoins
        successMessage:successMessage
        failureMessage:failureMessage
                taskId:0];

}

- (void)publishWeibo:(PPSNSType)snsType
                text:(NSString*)text
       imageFilePath:(NSString*)imagePath
            audioURL:(NSString*)audioURL
               title:(NSString*)title
              inView:(UIView*)view
          awardCoins:(int)awardCoins
      successMessage:(NSString*)successMessage
      failureMessage:(NSString*)failureMessage
              taskId:(int)taskId

{
    ShareType shareType = [GameSNSService shareSDKType:snsType];
    if (shareType == ShareTypeAny){
        return;
    }
    
    PPDebug(@"<publishWeibo> sns(%d) text(%@) image(%@) audio(%@)", snsType, text, imagePath, audioURL);
    
    SSPublishContentMediaType mediaType = SSPublishContentMediaTypeText;    
    if ([audioURL length] > 0){
        mediaType = SSPublishContentMediaTypeMusic;        
        if ([title length] == 0){
            title = text;
        }
    }
    else{
        if ([[imagePath pathExtension] isEqualToString:@"gif"] ||
            [[imagePath pathExtension] isEqualToString:@"GIF"]){
            mediaType = SSPublishContentMediaTypeGif;
        }
        else{
            mediaType = ([imagePath length] > 0) ? SSPublishContentMediaTypeImage : SSPublishContentMediaTypeText;
        }
    }
    
    //创建分享内容
    id<ISSContent> publishContent = [ShareSDK content:text
                                       defaultContent:@""
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:title
                                                  url:audioURL
                                          description:nil
                                            mediaType:mediaType];
    
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithView:view arrowDirect:UIPopoverArrowDirectionUp];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];  // _appDelegate.viewDelegate]; TODO check
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:[GameSNSService snsOfficialNick:snsType]],
                                    SHARE_TYPE_NUMBER(shareType),
                                    nil]];
    
    NSArray *oneKeyShareList = [ShareSDK getShareListWithType:shareType, nil];
    
    BOOL needUpdateUserInfo = [self isExpired:snsType];
    
    //显示分享菜单
    [ShareSDK showShareViewWithType:shareType
                          container:container
                            content:publishContent
                      statusBarTips:YES
                        authOptions:authOptions
                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                           oneKeyShareList:oneKeyShareList //[NSArray defaultOneKeyShareList]
                                                            qqButtonHidden:YES
                                                     wxSessionButtonHidden:YES
                                                    wxTimelineButtonHidden:YES
                                                      showKeyboardOnAppear:NO
                                                         shareViewDelegate:nil //_appDelegate.viewDelegate TODO check
                                                       friendsViewDelegate:nil //_appDelegate.viewDelegate TODO check
                                                     picViewerViewDelegate:nil]
                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 
                                 
                                 [self handlePublishWeiboSuccess:shareType
                                                           state:state
                                                           error:error
                                              needUpdateUserInfo:needUpdateUserInfo
                                                      awardCoins:awardCoins
                                                  successMessage:successMessage
                                                  failureMessage:failureMessage];
                                 
                                 if (state == SSPublishContentStateSuccess){
                                     [[TaskManager defaultManager] completeTask:taskId isAward:YES clearBadge:YES];
                                     
                                     if (awardCoins > 0){
//                                         [[ZeroQianManager defaultManager] awardForShare];
                                     }
                                 }
                                 
//                                 if (state == SSPublishContentStateSuccess)
//                                 {
//                                     PPDebug(@"publish weibo success");
//                                     
//                                     // TODO save user weibo bind info, get user infomation here and upload user information to server
//                                     if (needUpdateUserInfo){
//                                         [self readUserInfoAndUpdateToServer:shareType];
//                                     }
//                                     
//                                     [[AccountService defaultService] chargeCoin:awardCoins source:ShareWeiboReward];
//                                     
//                                     [self postWeiboSuccessMessage:successMessage awardCoins:awardCoins];
//                                     
//                                 }
//                                 else if (state == SSPublishContentStateFail)
//                                 {
//                                     POSTMSG(failureMessage);
//                                     PPDebug(@"publish weibo failure, code=%d, error=%@", [error errorCode], error.errorDescription);
//                                 }
                             }];
    
}

- (void)publishWeiboAtBackground:(PPSNSType)snsType
                            text:(NSString*)text
                   imageFilePath:(NSString*)imagePath
                      awardCoins:(int)awardCoins
                  successMessage:(NSString*)successMessage
                  failureMessage:(NSString*)failureMessage

{
    ShareType shareType = [GameSNSService shareSDKType:snsType];
    if (shareType == ShareTypeAny){
        return;
    }
    
    PPDebug(@"<publishWeiboAtBackground> sns(%d) text(%@) image(%@)", snsType, text, imagePath);
    SSPublishContentMediaType mediaType = ([imagePath length] > 0) ? SSPublishContentMediaTypeImage : SSPublishContentMediaTypeText;
    
    //创建分享内容
    id<ISSContent> publishContent = [ShareSDK content:text
                                       defaultContent:@""
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:nil
                                                  url:nil
                                          description:nil
                                            mediaType:mediaType];
    
    BOOL needUpdateUserInfo = [self isExpired:snsType];
    
    //显示分享菜单
    [ShareSDK shareContent:publishContent
                      type:shareType
               authOptions:nil
              shareOptions:nil
             statusBarTips:YES
                    result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                        
                        [self handlePublishWeiboSuccess:shareType
                                                  state:state
                                                  error:error
                                     needUpdateUserInfo:needUpdateUserInfo
                                             awardCoins:awardCoins
                                         successMessage:successMessage
                                         failureMessage:failureMessage];

                        
//                        if (state == SSPublishContentStateSuccess)
//                        {
//                            PPDebug(@"publish weibo success");
//
//                            // TODO save user weibo bind info, get user infomation here and upload user information to server
//                            if (needUpdateUserInfo){
//                                [self readUserInfoAndUpdateToServer:shareType];
//                            }
//                            
//                            // award
//                            [[AccountService defaultService] chargeCoin:awardCoins source:ShareWeiboReward];
//                            
//                            // post message
//                            [self postWeiboSuccessMessage:successMessage awardCoins:awardCoins];
//
//                        }
//                        else if (state == SSPublishContentStateFail)
//                        {
//                            POSTMSG(failureMessage);
//                            PPDebug(@"publish weibo failure, code=%d, error=%@", [error errorCode], error.errorDescription);
//                        }
                        
                    }];
}

- (void)publishWeibo:(PPSNSType)snsType
                text:(NSString*)text
              inView:(UIView*)view
          awardCoins:(int)awardCoins
      successMessage:(NSString*)successMessage
      failureMessage:(NSString*)failureMessage


{
    [self publishWeibo:snsType
                  text:text
         imageFilePath:nil
                inView:view
            awardCoins:awardCoins
        successMessage:successMessage
        failureMessage:failureMessage];
}

- (void)publishWeiboToAll:(NSString*)text
{
    
}

- (void)setAccessTokenClickHandler:(UIButton *)sender
{

}

- (void)saveSNSInfoIntoShareSDK:(PPSNSType)snsType credentialString:(NSString*)credentialString
{
    PPDebug(@"<saveSNSInfoIntoShareSDK> type(%d) credential(%@)", snsType, credentialString);    
    
    ShareType shareType = [GameSNSService shareSDKType:snsType];
    if (shareType == ShareTypeAny){
        return;
    }
    
    if ([credentialString length] == 0){
        return;
    }
    
    NSData* credentialData = [GTMBase64 decodeString:credentialString];
    if (credentialData == nil){
        return;
    }
        
    //将授权数据转换为新的授权凭证
    id<ISSPlatformCredential> newCredential = [ShareSDK credentialWithData:credentialData type:shareType];
    
    //设置使用新的授权凭证
    [ShareSDK setCredential:newCredential type:shareType];
}

+ (NSString*)snsOfficialNick:(PPSNSType)type
{
    NSString* weiboNick = @"";
    switch (type){
        case TYPE_SINA:
            weiboNick = [GameApp sinaWeiboId];
            break;
        case TYPE_QQ:
            weiboNick = [GameApp qqWeiboId];
            break;
            
        default:
            return [UIUtils getAppName];
    }
    
    if ([weiboNick length] > 0){
        return [NSString stringWithFormat:@"@%@", weiboNick];
    }
    else{
        return [UIUtils getAppName];
    }

}

- (void)cleanAllSNSInfo
{
    NSArray* shareTypes = @[ @(ShareTypeSinaWeibo), @(ShareTypeTencentWeibo),
                             @(ShareTypeFacebook), @(ShareTypeQQSpace), @(ShareTypeTwitter),
                             @(ShareTypeQQ)];
    
    for (NSNumber* shareType in shareTypes){
        [ShareSDK setCredential:nil type:[shareType intValue]];
    }
}

- (void)cleanSNSInfo:(ShareType)shareType
{
    [ShareSDK setCredential:nil type:shareType];
}

- (void)cleanSNSInfoIfExpired:(ShareType)shareType
{
    id<ISSPlatformCredential> credential = [ShareSDK getCredentialWithType:shareType];      //传入获取授权信息的类型
    if (credential == nil){
        return;
    }

    if ([credential available] == NO || [ShareSDK hasAuthorizedWithType:shareType] == NO){
        PPDebug(@"<cleanSNSInfoIfExpired> shareType=%d", shareType);
        [ShareSDK setCredential:nil type:shareType];
    }
}


- (void)saveSNSInfo:(NSArray*)snsCredentials
{
    if ([snsCredentials count] == 0){
        return;
    }
    
    for (PBSNSUserCredential* credential in snsCredentials){
        
        PPDebug(@"<saveSNSInfo> restore SNS credential, type(%d), credential(%@)", credential.type, credential.credential);
        
        if ([credential.credential length] == 0){
            continue;
        }
        
        // store into local PB user
        [[UserManager defaultManager] saveSNSCredential:credential.type credential:credential.credential];
        
        // set in Share SDK
        [self saveSNSInfoIntoShareSDK:credential.type credentialString:credential.credential];
    }
}

- (void)uploadUserSNSCredential:(ShareType)shareType
{
    id<ISSPlatformCredential> credential = [ShareSDK getCredentialWithType:shareType];      //传入获取授权信息的类型
    // store creditial data locally and send to server
    NSData *credentialData = [ShareSDK dataWithCredential:credential];
    NSString* credentialString = [GTMBase64 stringByEncodingData:credentialData];
    [[UserService defaultService] updateUserWithSNSUserInfo:shareType
                                           credentialString:credentialString];    
}

- (void)readUserInfoAndUpdateToServer:(ShareType)shareType
{
    id<ISSPlatformCredential> credential = [ShareSDK getCredentialWithType:shareType];      //传入获取授权信息的类型
    if (credential == nil){
        return;
    }
    
    id<ISSPlatformCredential> cred = (id<ISSPlatformCredential>)credential;             //转换为OAuth2授权凭证
    
    PPDebug(@"<readUserInfoAndUpdateToServer> user access token(%@), expire(%@)", [cred token], [cred expired]);
    PPDebug(@"<readUserInfoAndUpdateToServer> credential(%@), oauth2(%@)", [credential description], [cred description]);
    
    [self uploadUserSNSCredential:shareType];
        
    // complete task
    [[TaskManager defaultManager] completeBindWeiboTask:shareType isAward:NO clearBadge:YES];

    // read user information and upload to server
    [ShareSDK getUserInfoWithType:shareType                                     //平台类型
                      authOptions:nil                                           //授权选项
                           result:^(BOOL result, id<ISSPlatformUser> userInfo, id<ICMErrorInfo> error) {             //返回回调
                               if (result){
                                   PPDebug(@"<getUserInfo> success, userInfo(%@)", [userInfo.sourceData description]);
                                   [[UserService defaultService] updateUserWithSNSUserInfo:[[UserManager defaultManager] userId]                                    
                                                                                 shareType:shareType
                                                                                  userInfo:userInfo
                                                                                accessInfo:cred
                                                                            viewController:nil];
                                   
                                   // upload again here
                                   [self uploadUserSNSCredential:shareType];
                                   
                                   
                               }
                               else{
                                   PPDebug(@"<getUserInfo> error(%d) desc(%@)", error.errorCode, error.errorDescription);
                               }
                           }];
    
    
}

#pragma mark - Handle Open URL

- (BOOL)handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url
                        wxDelegate:self];
}

- (BOOL)handleOpenURL:(NSURL *)url
    sourceApplication:(NSString *)sourceApplication
           annotation:(id)annotation
{
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:self];
}

- (void)readUserInfo:(ShareType)shareType
         resultBlock:(ShareSNSResultBlock)resultBlock
    PPViewController:(PPViewController*)viewController
{
    id<ISSPlatformCredential> credential = [ShareSDK getCredentialWithType:shareType];      //传入获取授权信息的类型
    if (credential == nil){
        EXECUTE_BLOCK(resultBlock, ERROR_SNS_NO_CREDENTIAL);
        return;
    }
    
    id<ISSPlatformCredential> cred = (id<ISSPlatformCredential>)credential;             //转换为OAuth2授权凭证
    
    PPDebug(@"<readUserInfoAndUpdateToServer> user access token(%@), expire(%@)", [cred token], [cred expired]);
    PPDebug(@"<readUserInfoAndUpdateToServer> credential(%@), oauth2(%@)", [credential description], [cred description]);
    
//    [self uploadUserSNSCredential:shareType];
    
    // complete task
    [[TaskManager defaultManager] completeBindWeiboTask:shareType isAward:NO clearBadge:YES];
    
    [viewController showActivityWithText:NSLS(@"kRegisteringUser")];
    
    // read user information and upload to server
    [ShareSDK getUserInfoWithType:shareType                                     //平台类型
                      authOptions:nil                                           //授权选项
                           result:^(BOOL result, id<ISSPlatformUser> userInfo, id<ICMErrorInfo> error) {             //返回回调
                               
                               [viewController hideActivity];
                               
                               if (result){
                                   PPDebug(@"<getUserInfo> success, userInfo(%@)", [userInfo.sourceData description]);
                                   
                                   // Login User By SNS Info
                                   
                                   
                                   /*
                                   [[UserService defaultService] updateUserWithSNSUserInfo:[[UserManager defaultManager] userId]
                                                                                 shareType:shareType
                                                                                  userInfo:userInfo
                                                                                accessInfo:cred
                                                                            viewController:nil];
                                   
                                   // upload again here
                                   [self uploadUserSNSCredential:shareType];
                                    */
                                   
                                   [[UserService defaultService] loginSNSUser:userInfo
                                                                    shareType:shareType
                                                                   accessInfo:cred
                                                                  resultBlock:resultBlock];
                                   
                               }
                               else{
                                   PPDebug(@"<getUserInfo> error(%d) desc(%@)", error.errorCode, error.errorDescription);
                               }
                           }];
    
    
}

- (void)loginBySNS:(PPSNSType)snsType
       resultBlock:(ShareSNSResultBlock)resultBlock
  PPViewController:(PPViewController*)viewController
{

    ShareType shareType = [GameSNSService shareSDKType:snsType];
    if (shareType == ShareTypeAny){
        return;
    }
    
    
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];  // _appDelegate.viewDelegate]; TODO check
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:[GameSNSService snsOfficialNick:snsType]],
                                    SHARE_TYPE_NUMBER(shareType),
                                    nil]];
    
    [ShareSDK authWithType:shareType                                            //需要授权的平台类型
                   options:authOptions                                          //授权选项，包括视图定制，自动授权
                    result:^(SSAuthState state, id<ICMErrorInfo> error) {       //授权返回后的回调方法
                        if (state == SSAuthStateSuccess)
                        {
                            // TODO save user weibo bind info, get user infomation here and upload user information to server
                            [self readUserInfo:shareType
                                   resultBlock:resultBlock
                              PPViewController:viewController];
                            
                            POSTMSG(NSLS(@"kAuthorizeSuccess"));
                            PPDebug(@"autheticate shareType(%d) success", shareType);
                            
                            
                        }
                        else if (state == SSAuthStateFail)
                        {
                            POSTMSG(NSLS(@"kAuthorizeFailure"));
                            PPDebug(@"autheticate shareType(%d) failure, error=%@", shareType, [error errorDescription]);
                        }
                        else{
                            PPDebug(@"autheticate shareType(%d) unknown state, error=%@", shareType, [error errorDescription]);
                        }
                    }];

}

@end
