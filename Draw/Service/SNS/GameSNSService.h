//
//  GameSNSService.h
//  Draw
//
//  Created by qqn_pipi on 12-11-22.
//
//

#import <Foundation/Foundation.h>
#import "PPSNSConstants.h"

@class PPSNSCommonService;

typedef void(^ShareSNSResultBlock) (int resultCode);

@interface GameSNSService : NSObject

//+ (void)askFollow:(PPSNSType)snsType snsWeiboId:(NSString*)weiboId;
//+ (void)askFollowOfficialWeibo:(PPSNSType)snsType;
//+ (NSString*)snsOfficialNick:(int)type;
//+ (void)updateFollowOfficialWeibo:(PPSNSCommonService*)snsService;
//+ (BOOL)hasFollowOfficialWeibo:(PPSNSCommonService*)snsService;
//+ (void)askRebindQQ:(UIViewController*)viewController;
//+ (void)askRebindSina:(UIViewController*)viewController;
//+ (void)askRebindFacebook:(UIViewController*)viewController;

+ (GameSNSService*)defaultService;

- (BOOL)isAuthenticated:(PPSNSType)snsType;
- (BOOL)isExpired:(PPSNSType)snsType;
- (void)autheticate:(PPSNSType)snsType;
- (void)cancelAuthentication:(PPSNSType)snsType;
- (void)followUser:(PPSNSType)snsType weiboId:(NSString*)weiboId weiboName:(NSString*)weiboName;

- (void)publishWeibo:(PPSNSType)snsType
                text:(NSString*)text
       imageFilePath:(NSString*)imagePath
              inView:(UIView*)view
          awardCoins:(int)awardCoins
      successMessage:(NSString*)successMessage
      failureMessage:(NSString*)failureMessage
              taskId:(int)taskId;

- (void)publishWeibo:(PPSNSType)snsType
                text:(NSString*)text
       imageFilePath:(NSString*)imageFilePath
              inView:(UIView*)view
          awardCoins:(int)awardCoins
      successMessage:(NSString*)successMessage
      failureMessage:(NSString*)failureMessage;

- (void)publishWeiboAtBackground:(PPSNSType)snsType
                            text:(NSString*)text
                   imageFilePath:(NSString*)imagePath
                      awardCoins:(int)awardCoins
                  successMessage:(NSString*)successMessage
                  failureMessage:(NSString*)failureMessage;

- (void)publishWeibo:(PPSNSType)snsType
                text:(NSString*)text
       imageFilePath:(NSString*)imagePath
            audioURL:(NSString*)audioURL
               title:(NSString*)title
              inView:(UIView*)view
          awardCoins:(int)awardCoins
      successMessage:(NSString*)successMessage
      failureMessage:(NSString*)failureMessage;

- (void)publishWeibo:(PPSNSType)snsType
                text:(NSString*)text
              inView:(UIView*)view
          awardCoins:(int)awardCoins
      successMessage:(NSString*)successMessage
      failureMessage:(NSString*)failureMessage;
//- (void)publishWeiboToAll:(NSString*)text;
//- (void)saveSNSInfo:(PPSNSType)snsType credentialString:(NSString*)credentialString;

- (void)publishWeibo:(PPSNSType)snsType
                text:(NSString*)text
       imageFilePath:(NSString*)imagePath
            audioURL:(NSString*)audioURL
               title:(NSString*)title
              inView:(UIView*)view
          awardCoins:(int)awardCoins
      successMessage:(NSString*)successMessage
      failureMessage:(NSString*)failureMessage
              taskId:(int)taskId;

- (void)saveSNSInfo:(NSArray*)snsCredentials;
- (void)cleanAllSNSInfo;
- (void)cleanSNSInfo:(ShareType)shareType;

- (void)askRebindQQ:(UIViewController*)viewController;
- (void)askRebindSina:(UIViewController*)viewController;
- (void)askRebindFacebook:(UIViewController*)viewController;

+ (NSString*)snsOfficialNick:(PPSNSType)type;

- (BOOL)handleOpenURL:(NSURL *)url;
- (BOOL)handleOpenURL:(NSURL *)url
    sourceApplication:(NSString *)sourceApplication
           annotation:(id)annotation;


- (void)loginBySNS:(PPSNSType)snsType
       resultBlock:(ShareSNSResultBlock)resultBlock
  PPViewController:(PPViewController*)viewController;

@end
