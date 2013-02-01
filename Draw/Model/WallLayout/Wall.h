//
//  Wall.h
//  Draw
//
//  Created by 王 小涛 on 13-1-25.
//
//

#import <Foundation/Foundation.h>
#import "DrawFeed.h"
#import "WallOpus.h"

@interface Wall : NSObject

@property (retain, nonatomic, readonly) PBWall *pbWall;

- (id)initWithPBWall:(PBWall *)pbWall;
- (id)initWithName:(NSString *)name
            layout:(PBLayout *)layout
            opuses:(NSArray*)opuses
          musicUrl:(NSString *)musicUrl;

- (NSArray *)wallOpuses;

- (WallOpus *)wallOpusWithFrameIdOnWall:(int)frameIdOnWall;

- (void)replaceWallOpus:(int)frameIdOnWall withOpus:(DrawFeed *)opus;
- (void)replaceWallOpus:(int)frameIdOnWall withFrame:(PBFrame *)frame;

- (PBFrame *)frameWithFrameIdOnWall:(int)frameIdOnWall;
- (void)setLayout:(PBLayout *)layout;
- (void)setWallId:(NSString *)wallId;

- (PBWall *)toPBWall;

- (void)setBgImage:(NSString *)image;

@end
