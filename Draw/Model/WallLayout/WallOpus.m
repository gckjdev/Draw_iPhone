////
////  WallOpus.m
////  Draw
////
////  Created by 王 小涛 on 13-1-30.
////
////
//
//#import "WallOpus.h"
//
//@interface WallOpus()
//
//@property (assign, nonatomic, readwrite) int frameIdOnWall;
//
//@end
//
//@implementation WallOpus
//
//- (void)dealloc
//{
//    [_opus release];
//    [super dealloc];
//}
//
//- (id)initWithPBWallOpus:(PBWallOpus *)pbWallOpus
//{
//    if (self = [super init]) {
//
//        self.frameIdOnWall = pbWallOpus.frameIdOnWall;
//        self.opus = [[[DrawFeed alloc] initWithPBFeed:pbWallOpus.opus] autorelease];
//    }
//    
//    return self;
//}
//
//+ (WallOpus *)fromPBWallOpus:(PBWallOpus *)pbWallOpus
//{
//    return [[[WallOpus alloc] initWithPBWallOpus:pbWallOpus] autorelease];
//}
//
//- (id)initWithFrameIdOnWall:(int)frameIdOnWall opus:(DrawFeed *)opus
//{
//    if (self = [super init]) {
//        self.frameIdOnWall = frameIdOnWall;
//        self.opus = opus;
//    }
//    
//    return self;
//}
//
//- (PBWallOpus *)toPBWallOpus
//{
////    required string feedId = 1;
////    required string userId = 2;
////    required int32  actionType = 3;
////    required int32  createDate = 4;
//    
//    PBFeed_Builder *feedBuilder = [[[PBFeed_Builder alloc] init] autorelease];
//    [feedBuilder setFeedId:_opus.feedId];
//    [feedBuilder setOpusImage:_opus.drawImageUrl];
//    [feedBuilder setUserId:@""];
//    [feedBuilder setActionType:0];
//    [feedBuilder setCreateDate:0];
//    PBFeed *feed = [feedBuilder build];
//    
//    PBWallOpus_Builder *builder = [[[PBWallOpus_Builder alloc] init] autorelease];
//    [builder setFrameIdOnWall:_frameIdOnWall];
//    [builder setOpus:feed];
//    return [builder build];
//}
//
//
//@end
