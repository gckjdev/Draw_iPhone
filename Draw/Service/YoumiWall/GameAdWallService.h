//
//  GameAdWallService.h
//  Draw
//
//  Created by qqn_pipi on 13-3-16.
//
//

#import <Foundation/Foundation.h>
#import "CommonAdWallService.h"
#import "Config.pb.h"

@interface GameAdWallService : NSObject

+ (GameAdWallService*)defaultService;

@property (nonatomic, retain) CommonAdWallService* limeiWallService;

- (CommonAdWallService*)wallServiceByType:(PBRewardWallType)type;

@end
