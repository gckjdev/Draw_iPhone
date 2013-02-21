//
//  Wall.h
//  Draw
//
//  Created by 王 小涛 on 13-1-25.
//
//

#import <Foundation/Foundation.h>
#import "DrawFeed.h"

#define DISPLAY_MODE_PLANE 0    
#define DISPLAY_MODE_SOLID 1

@interface Wall : NSObject

@property (retain, nonatomic, readonly) PBWall *pbWall;

- (id)initWithPBWall:(PBWall *)pbWall;

- (id)initWithName:(NSString *)name
            layout:(PBLayout *)layout
            opuses:(NSArray*)opuses
          musicUrl:(NSString *)musicUrl;

- (PBWallOpus *)wallOpusWithIdOnWall:(int)idOnWall;

- (void)replaceWallOpus:(int)idOnWall withOpus:(DrawFeed *)newOpus;
- (void)replaceWallOpus:(int)idOnWall withFrame:(PBFrame *)newFrame;

- (PBFrame *)frameInWallOpus:(int)idOnWall;
- (void)setLayout:(PBLayout *)layout;

- (void)setWallId:(NSString *)wallId;

- (PBWall *)toPBWall;

- (void)setBgImage:(NSString *)image;

@end
