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

{
    NSMutableArray* _wallServiceArray;
    BOOL _isQueryingScore;
}


+ (GameAdWallService*)defaultService;

@property (nonatomic, retain) CommonAdWallService* limeiWallService ;
@property (nonatomic, retain) CommonAdWallService* wanpuWallService ;

- (CommonAdWallService*)wallServiceByType:(PBRewardWallType)type
                            forceShowWall:(BOOL)forceShowWall;

- (void)queryWallScore;

- (void)showWall:(UIViewController*)superController
        wallType:(PBRewardWallType)wallType
   forceShowWall:(BOOL)forceShowWall;

- (void)showInsertWall:(UIViewController*)superController
              wallType:(PBRewardWallType)wallType;

@end
