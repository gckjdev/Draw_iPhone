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

- (void)didCreateWall:(int)resultCode;

@end


@interface WallService : CommonService

+ (WallService *)sharedWallService;

- (void)createWall:(PBWall *)wall
          delegate:(PPViewController<WallServiceDelegate>*)viewController;

@end
