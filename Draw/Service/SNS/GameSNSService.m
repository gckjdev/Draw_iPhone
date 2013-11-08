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
#import "GTMBase64.h"
#import <ShareSDK/ShareSDK.h>

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
        [ShareSDK registerApp:[PPConfigManager getShareSDKAppId]];
        
        //添加新浪微博应用
        [ShareSDK connectSinaWeiboWithAppKey:[GameApp sinaAppKey]       //  @"3201194191"
                                   appSecret:[GameApp sinaAppSecret]    //  @"0334252914651e8f76bad63337b3b78f"
                                 redirectUri:[GameApp sinaAppRedirectURI]]; // @"http://appgo.cn"];
        
        //添加腾讯微博应用
        [ShareSDK connectTencentWeiboWithAppKey:[GameApp qqAppKey]          //@"801307650"
                                      appSecret:[GameApp qqAppSecret] // @"ae36f4ee3946e1cbb98d6965b0b2ff5c"
                                    redirectUri:[GameApp qqAppRedirectURI]]; // @"http://www.sharesdk.cn"];
        
        //添加QQ空间应用
        [ShareSDK connectQZoneWithAppKey:[GameApp qqSpaceAppId]     //@"100371282"
                               appSecret:[GameApp qqSpaceAppKey]];  // @"aed9b0303e3ed1e27bae87c33761161d"];
        
        //添加Facebook应用
        [ShareSDK connectFacebookWithAppKey:[GameApp facebookAppKey]   //@"107704292745179"
                                  appSecret:[GameApp facebookAppSecret]]; // @"38053202e1a5fe26c80c753071f0b573"];
        
        
        [ShareSDK connectWeChatWithAppId:[GameApp weixinId] // @"wx6dd7a9b94f3dd72a"        //此参数为申请的微信AppID
                               wechatCls:[WXApi class]];
        
        //添加QQ应用
//        [ShareSDK connectQQWithQZoneAppKey:@"100371282"                 //该参数填入申请的QQ AppId
//                         qqApiInterfaceCls:[QQApiInterface class]
//                           tencentOAuthCls:[TencentOAuth class]];
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
    
//    id<ISSCredential> credential = [ShareSDK getCredentialWithType:shareType];    //传入获取授权信息的类型
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
    
    id<ISSCredential> credential = [ShareSDK getCredentialWithType:shareType];    //传入获取授权信息的类型
    id<ISSOAuth2Credential> cred = (id<ISSOAuth2Credential>)credential;           //转换为OAuth2授权凭证
    PPDebug(@"<isExpired> shareType=%d, accessToken = %@, expiresIn = %@",
            shareType, [cred accessToken], [cred expiresIn]);
    
    if (cred == nil){
        return YES;
    }
    else if ([[cred expiresIn] timeIntervalSinceNow] <= 0){
        return YES;
    }
    else{
        return NO;
    }    
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
                            
                            POSTMSG(NSLS(@"kAuthorizeSuccess"));
                            PPDebug(@"autheticate shareType(%d) success", shareType);
                        }
                        else if (state == SSAuthStateFail)
                        {
                            POSTMSG(NSLS(@"kAuthorizeFailure"));
                            PPDebug(@"autheticate shareType(%d) failure, error=%@", shareType, [error errorDescription]);
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
                          result:^(SSResponseState state, id<ISSUserInfo> userInfo, id<ICMErrorInfo> error) {               //返回回调
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
        
        POSTMSG(msg);
    }
}

- (void)handlePublishWeiboSuccess:(ShareType)shareType
                            state:(SSPublishContentState)state
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
        POSTMSG(failureMessage);
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
    ShareType shareType = [GameSNSService shareSDKType:snsType];
    if (shareType == ShareTypeAny){
        return;
    }
    
    PPDebug(@"<publishWeibo> sns(%d) text(%@) image(%@)", snsType, text, imagePath);
    
    //创建分享内容
    id<ISSContent> publishContent = [ShareSDK content:text
                                       defaultContent:@""
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:nil
                                                  url:nil
                                          description:nil
                                            mediaType:SSPublishContentMediaTypeText];
    
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
                             result:^(ShareType type, SSPublishContentState state, id<ISSStatusInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 
                                 
                                 [self handlePublishWeiboSuccess:shareType
                                                           state:state
                                                           error:error
                                              needUpdateUserInfo:needUpdateUserInfo
                                                      awardCoins:awardCoins
                                                  successMessage:successMessage
                                                  failureMessage:failureMessage];
                                 
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
    
    //创建分享内容
    id<ISSContent> publishContent = [ShareSDK content:text
                                       defaultContent:@""
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:nil
                                                  url:nil
                                          description:nil
                                            mediaType:SSPublishContentMediaTypeText];
    
    BOOL needUpdateUserInfo = [self isExpired:snsType];
    
    //显示分享菜单
    [ShareSDK shareContent:publishContent
                      type:shareType
               authOptions:nil
              shareOptions:nil
             statusBarTips:YES
                    result:^(ShareType type, SSPublishContentState state, id<ISSStatusInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                        
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
    [self publishWeibo:snsType text:text imageFilePath:nil inView:view awardCoins:awardCoins successMessage:successMessage failureMessage:failureMessage];
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
    id<ISSCredential> newCredential = [ShareSDK credentialWithData:credentialData type:shareType];
    
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
            return @"";
    }
    
    if ([weiboNick length] > 0){
        return [NSString stringWithFormat:@"@%@", weiboNick];
    }
    else{
        return [UIUtils getAppName];
    }

}

- (void)cleanSNSInfo:(NSArray*)snsCredentials
{
//    for (PBSNSUserCredential* credential in snsCredentials){
//        
//        PPDebug(@"<cleanSNSInfo> remove SNS credential, type(%d), credential(%@)", credential.type, credential.credential);
//        
//        if ([credential.credential length] == 0){
//            continue;
//        }
//        
//        // clear local data in Share SDK
//        ShareType shareType = [GameSNSService shareSDKType:credential.type];
//        if (shareType == ShareTypeAny){
//            continue;
//        }
//        
//        
//    }

    NSArray* shareTypes = @[ @(ShareTypeSinaWeibo), @(ShareTypeTencentWeibo), @(ShareTypeFacebook), @(ShareTypeQQSpace), @(ShareTypeTwitter)];
    for (NSNumber* shareType in shareTypes){
        [ShareSDK setCredential:nil type:[shareType intValue]];
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
    id<ISSCredential> credential = [ShareSDK getCredentialWithType:shareType];      //传入获取授权信息的类型
    // store creditial data locally and send to server
    NSData *credentialData = [ShareSDK dataWithCredential:credential];
    NSString* credentialString = [GTMBase64 stringByEncodingData:credentialData];
    [[UserService defaultService] updateUserWithSNSUserInfo:shareType
                                           credentialString:credentialString];    
}

- (void)readUserInfoAndUpdateToServer:(ShareType)shareType
{
    id<ISSCredential> credential = [ShareSDK getCredentialWithType:shareType];      //传入获取授权信息的类型
    if (credential == nil){
        return;
    }
    
    id<ISSOAuth2Credential> cred = (id<ISSOAuth2Credential>)credential;             //转换为OAuth2授权凭证
    
    PPDebug(@"<readUserInfoAndUpdateToServer> user access token(%@), expire(%@)", [cred accessToken], [cred expiresIn]);
    PPDebug(@"<readUserInfoAndUpdateToServer> credential(%@), oauth2(%@)", [credential description], [cred description]);
    
    [self uploadUserSNSCredential:shareType];

    // read user information and upload to server
    [ShareSDK getUserInfoWithType:shareType                                     //平台类型
                      authOptions:nil                                           //授权选项
                           result:^(BOOL result, id<ISSUserInfo> userInfo, id<ICMErrorInfo> error) {             //返回回调
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


@end
