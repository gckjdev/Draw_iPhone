//
//  WallOpus.h
//  Draw
//
//  Created by 王 小涛 on 13-1-30.
//
//

#import <Foundation/Foundation.h>
#import "DrawFeed.h"
#import "Draw.pb.h"

@interface WallOpus : NSObject

@property (assign, nonatomic, readonly) int frameIdOnWall;
@property (retain, nonatomic) DrawFeed *opus;

+ (WallOpus *)fromPBWallOpus:(PBWallOpus *)pbWallOpus;
- (id)initWithFrameIdOnWall:(int)frameIdOnWall opus:(DrawFeed *)opus;


- (PBWallOpus *)toPBWallOpus;

@end
