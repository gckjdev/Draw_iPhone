//
//  GameAdWallService.m
//  Draw
//
//  Created by qqn_pipi on 13-3-16.
//
//

#import "GameAdWallService.h"
#import "SynthesizeSingleton.h"
#import "LimeiAdWallService.h"
#import "UserManager.h"

@implementation GameAdWallService

SYNTHESIZE_SINGLETON_FOR_CLASS(GameAdWallService)

- (id)init
{
    self = [super init];
    
    
    NSString* limeiAdId = [GameApp lmwallId];
    NSString* userId = [[UserManager defaultManager] userId];
    
    self.limeiWallService = [[[LimeiAdWallService alloc] initWithUserId:userId adUnitId:limeiAdId] autorelease];
    
    return self;
}

/*
小（iPhone） 300*300
标准（iPad） 700*700

横版 700*(432)
竖版 (432)*700

中           1024*1024
 
iPad横       1024*768
iPad竖       768*1024
 
iPhone3竖    320*480
iPhone4竖    640*960
iPhone5竖    640*1136
 
*/

- (CommonAdWallService*)wallServiceByType:(PBRewardWallType)type
{
    switch (type) {
        case PBRewardWallTypeLimei:
            return self.limeiWallService;
            
        default:
            break;
    }
    
    return nil;
}

@end
