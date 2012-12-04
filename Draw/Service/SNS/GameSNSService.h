//
//  GameSNSService.h
//  Draw
//
//  Created by qqn_pipi on 12-11-22.
//
//

#import <Foundation/Foundation.h>
#import "PPSNSConstants.h"

@interface GameSNSService : NSObject

+ (void)askFollow:(PPSNSType)snsType snsWeiboId:(NSString*)weiboId;
+ (void)askFollowOfficialWeibo:(PPSNSType)snsType;

@end
