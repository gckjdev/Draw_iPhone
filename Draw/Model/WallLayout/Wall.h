////
////  Wall.h
////  Draw
////
////  Created by 王 小涛 on 13-1-25.
////
////
//
//#import <Foundation/Foundation.h>
//#import "Layout.h"
//#import "DrawFeed.h"
//
//@interface WallOpus : NSObject
//
//@property (retain, nonatomic) DrawFeed *drawFeed;
//@property (assign, nonatomic) int frameId;
//
//+ (WallOpus *)wallOpusFromPBWallOpus:(PBWallOpus*)pbWallOpus;
//+ (WallOpus *)wallOpusWithFrameId:(int)frameId drawFeed:(DrawFeed *)drawFeed;
//
//@end
//
//
//@interface Wall : NSObject
//
//@property (copy, nonatomic, readonly) NSString *wallId;
//@property (assign, nonatomic, readonly) int wallType;
//@property (copy, nonatomic, readonly) NSString *userId;
//@property (copy, nonatomic) NSString *wallName;
//@property (retain, nonatomic) Layout *layout;
//@property (retain, nonatomic) NSMutableArray *wallOpuses;
//@property (copy, nonatomic) NSString *musicUrl;
//
//+ (Wall*)wallFromPBWall:(PBWall*)pbWall;
//
//+ (Wall*)wallWithWallId:(NSString *)wallId
//               wallType:(int)wallType
//                 userId:(NSString *)userId
//               wallName:(NSString *)wallName
//                 layout:(Layout *)layout
//             wallOpuses:(NSArray *)wallOpuses
//               musicUrl:(NSString *)musicUrl;
//
//
//- (WallOpus *)wallOpusWithFrameId:(int)frameId;
//- (int)frameIdWithOpusId:(NSString *)opusId;
//
//@end
