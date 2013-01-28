////
////  Wall.m
////  Draw
////
////  Created by 王 小涛 on 13-1-25.
////
////
//
//#import "Wall.h"
//
//@implementation WallOpus
//
//- (void)dealloc
//{
//    [_drawFeed release];
//    [super dealloc];
//}
//
//- (id)initWithPBWallOpus:(PBWallOpus *)pbWallOpus
//{
//    if (self = [super init]) {
//        self.drawFeed = [[DrawFeed alloc] initWithPBFeed:pbWallOpus.opus];
//        self.frameId = pbWallOpus.frameId;
//    }
//    
//    return self;
//}
//
//- (id)initWithOpusWithFrameId:(int)frameId drawFeed:(DrawFeed *)drawFeed
//{
//    if (self = [super init]) {
//        self.drawFeed = drawFeed;
//        self.frameId = frameId;
//    }
//    
//    return self;
//}
//
//+ (WallOpus *)wallOpusFromPBWallOpus:(PBWallOpus *)pbWallOpus
//{
//    return [[[WallOpus alloc] initWithPBWallOpus:pbWallOpus] autorelease];
//}
//
//+ (WallOpus *)wallOpusWithFrameId:(int)frameId drawFeed:(DrawFeed *)drawFeed
//{
//    return [[[WallOpus alloc] initWithOpusWithFrameId:frameId drawFeed:drawFeed] autorelease];
//}
//
//@end
//
//@interface Wall ()
//
//@property (copy, nonatomic, readwrite) NSString *wallId;
//@property (assign, nonatomic, readwrite) int wallType;
//@property (copy, nonatomic, readwrite) NSString *userId;
//
//@end
//
//@implementation Wall
//
//- (void)dealloc
//{
//    [_wallId release];
//    [_userId release];
//    [_wallName release];
//    [_layout release];
//    [_wallOpuses release];
//    [_musicUrl release];
//    [super dealloc];
//}
//
//- (id)initWithPBWall:(PBWall *)pbWall
//{
//    if (self = [super init]) {
//        self.wallId = pbWall.wallId;
//        self.wallType = pbWall.type;
//        self.userId = pbWall.userId;
//        self.wallName = pbWall.wallName;
//        self.layout = [Layout layoutFromPBLayout:pbWall.layout];
//        self.wallOpuses = [NSMutableArray array];
//        
//        for (PBWallOpus *pbWallOpus in pbWall.opusesList) {
//            [self.wallOpuses addObject:[WallOpus wallOpusFromPBWallOpus:pbWallOpus]];
//        }
//        
//        self.musicUrl = pbWall.musicUrl;
//    }
//    
//    return self;
//}
//
//- (id)initWithWallId:(NSString *)wallId
//            wallType:(int)wallType
//              userId:(NSString *)userId
//            wallName:(NSString *)wallName
//              layout:(Layout *)layout
//          wallOpuses:(NSArray *)wallOpuses
//            musicUrl:(NSString *)musicUrl
//{
//    if (self = [super init]) {
//        self.wallId = wallId;
//        self.wallType = wallType;
//        self.userId = userId;
//        self.wallName = wallName;
//        self.layout = layout;
//        self.wallOpuses = [NSMutableArray arrayWithArray:wallOpuses];
//        self.musicUrl = musicUrl;
//    }
//    
//    return self;
//}
//
//+ (Wall*)wallFromPBWall:(PBWall*)pbWall
//{
//    return [[[Wall alloc] initWithPBWall:pbWall] autorelease];
//}
//
//+ (Wall*)wallWithWallId:(NSString *)wallId
//               wallType:(int)wallType
//                 userId:(NSString *)userId
//               wallName:(NSString *)wallName
//                 layout:(Layout *)layout
//             wallOpuses:(NSArray *)wallOpuses
//               musicUrl:(NSString *)musicUrl
//{
//    return [[Wall alloc] initWithWallId:wallId
//                               wallType:wallType
//                                 userId:userId
//                               wallName:wallName
//                                 layout:layout
//                             wallOpuses:wallOpuses
//                               musicUrl:musicUrl];
//}
//
//- (WallOpus *)wallOpusWithFrameId:(int)frameId
//{
//    for (WallOpus *wallOpus in self.wallOpuses) {
//        if (wallOpus.frameId == frameId) {
//            return wallOpus;
//        }
//    }
//    
//    return nil;
//}
//
//- (int)frameIdWithOpusId:(NSString *)opusId
//{
//    for (WallOpus *wallOpus in self.wallOpuses) {
//        if ([wallOpus.drawFeed.feedId isEqualToString:opusId]) {
//            return wallOpus.frameId;
//        }
//    }
//    
//    return 0;
//}
//
//@end
