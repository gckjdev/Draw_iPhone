//
//  WallService.h
//  Draw
//
//  Created by 王 小涛 on 13-1-30.
//
//

#import <Foundation/Foundation.h>
#import "CommonService.h"
#import "Draw.pb.h"
#import "PPViewController.h"

@protocol WallServiceDelegate <NSObject>

- (void)didCreateWall:(int)resultCode wall:(PBWall *)wall;
- (void)didGetWallList:(int)resultCode wallList:(NSArray *)wallList;
- (void)didGetWall:(int)resultCode wall:(PBWall *)wall;


@end


@interface WallService : CommonService

+ (WallService *)sharedWallService;

- (void)createWall:(PBWall *)wall
           bgImage:(UIImage *)bgImage
          delegate:(PPViewController<WallServiceDelegate>*)viewController;

- (void)getWallList:(NSString *)userId
           wallType:(PBWallType)wallType
           delegate:(PPViewController<WallServiceDelegate>*)viewController;


- (void)getWall:(NSString *)userId
         wallId:(NSString *)wallId
       delegate:(PPViewController<WallServiceDelegate>*)viewController;

@end
