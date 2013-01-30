//
//  WallOpus.m
//  Draw
//
//  Created by 王 小涛 on 13-1-30.
//
//

#import "WallOpus.h"

@interface WallOpus()

@property (assign, nonatomic, readwrite) int frameIdOnWall;

@end

@implementation WallOpus

- (void)dealloc
{
    [_opus release];
    [super dealloc];
}

- (id)initWithPBWallOpus:(PBWallOpus *)pbWallOpus
{
    if (self = [super init]) {
        self.frameIdOnWall = pbWallOpus.frameIdOnWall;
        self.opus = [[[DrawFeed alloc] initWithPBFeed:pbWallOpus.opus] autorelease];
    }
    
    return self;
}

+ (WallOpus *)fromPBWallOpus:(PBWallOpus *)pbWallOpus
{
    return [[[WallOpus alloc] initWithPBWallOpus:pbWallOpus] autorelease];
}

- (id)initWithFrameIdOnWall:(int)frameIdOnWall opus:(DrawFeed *)opus
{
    if (self = [super init]) {
        self.frameIdOnWall = frameIdOnWall;
        self.opus = opus;
    }
    
    return self;
}

@end
