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

+ (void)askFollow:(PPSNSType)snsType snsWeiboId:(NSString*)weiboId;
+ (void)askFollowOfficialWeibo:(PPSNSType)snsType;
+ (NSString*)snsOfficialNick:(int)type;
+ (void)updateFollowOfficialWeibo:(PPSNSCommonService*)snsService;
+ (BOOL)hasFollowOfficialWeibo:(PPSNSCommonService*)snsService;

@end
