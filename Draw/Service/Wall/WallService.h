//
//  WallService.h
//  Draw
//
//  Created by 王 小涛 on 13-1-30.
//
//

#import <Foundation/Foundation.h>
#import "Draw.pb.h"

@interface WallService : NSObject

+ (WallService *)sharedWallService;

- (void)createWall:(PBWall *)wall;

@end
