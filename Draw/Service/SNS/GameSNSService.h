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

- (void)publishWeibo:(PPSNSType)snsType text:(NSString*)text imageFilePath:(NSString*)imageFilePath inView:(UIView*)view;
- (void)publishWeibo:(PPSNSType)snsType text:(NSString*)text imageFilePath:(NSString*)imagePath;
- (void)publishWeibo:(PPSNSType)snsType text:(NSString*)text;
- (void)publishWeiboToAll:(NSString*)text;
- (void)saveSNSInfo:(PPSNSType)snsType;
+ (NSString*)snsOfficialNick:(PPSNSType)type;

@end
