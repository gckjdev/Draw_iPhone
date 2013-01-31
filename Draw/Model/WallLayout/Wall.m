//
//  Wall.m
//  Draw
//
//  Created by 王 小涛 on 13-1-25.
//
//

#import "Wall.h"
#import "UserManager.h"
#import "FrameManager.h"

@interface Wall ()
{
    NSMutableArray *_wallOpuses;
}

@property (retain, nonatomic) PBWall *pbWall;

@end

@implementation Wall

- (void)dealloc
{
    [_pbWall release];
    [_wallOpuses release];
    [super dealloc];
}

- (id)initWithPBWall:(PBWall *)pbWall
{
    if (self = [super init]) {
        self.pbWall = pbWall;
        
        
        _wallOpuses = [[NSMutableArray array] retain];
        for (PBWallOpus *wallOpus in self.pbWall.wallOpusesList) {
            [_wallOpuses addObject:[WallOpus fromPBWallOpus:wallOpus]];
        }
    }
    
    return self;
}

- (id)initWithName:(NSString *)name
            layout:(PBLayout *)layout
            opuses:(NSArray*)opuses
          musicUrl:(NSString *)musicUrl
{
    if (self = [super init]) {
        PBWall_Builder *builder = [[[PBWall_Builder alloc] init] autorelease];
        [builder setWallId:nil];
        [builder setWallName:name];
        [builder setWallType:PBWallTypeOpuses];
        [builder setUserId:[[UserManager defaultManager] userId]];
        [builder setLayout:layout];
        [builder setMusicUrl:musicUrl];
        self.pbWall = [builder build];

        _wallOpuses = [[NSMutableArray array] retain];
        for (int index=0; index<[layout.framesList count] && index<[opuses count]; index++) {
            PBFrame *frame = [layout.framesList objectAtIndex:index];
            int frameIdOnWall = [frame idOnWall];
            WallOpus *wallOpus = [[[WallOpus alloc] initWithFrameIdOnWall:frameIdOnWall opus:[opuses objectAtIndex:index]] autorelease];
            [_wallOpuses addObject:wallOpus];
        }
    }
    
    return self;
}

- (NSArray *)wallOpuses
{
    return _wallOpuses;
}

- (void)setLayout:(PBLayout *)layout
{
   self.pbWall = [[[PBWall builderWithPrototype:_pbWall] setLayout:layout] build];
}

- (void)setWallName:(NSString *)wallName
{
    self.pbWall = [[[PBWall builderWithPrototype:_pbWall] setWallName:wallName] build];
}

- (WallOpus *)wallOpusWithFrameIdOnWall:(int)frameIdOnWall
{
    for (WallOpus *wallOpus in self.wallOpuses) {
        if (wallOpus.frameIdOnWall == frameIdOnWall) {
            return wallOpus;
        }
    }
    
    return nil;
}

- (void)replaceWallOpus:(int)frameIdOnWall withOpus:(DrawFeed *)opus
{
    WallOpus *wallOpus = [self wallOpusWithFrameIdOnWall:frameIdOnWall];
    wallOpus.opus = opus;
}

- (PBFrame *)frameWithFrameIdOnWall:(int)frameIdOnWall
{
    for (PBFrame *frame in self.pbWall.layout.framesList) {
        if (frame.idOnWall == frameIdOnWall) {
            return frame;
        }
    }
    
    return nil;
}

- (void)replaceWallOpus:(int)frameIdOnWall withFrame:(PBFrame *)frameReplaced
{
    NSMutableArray *frameArr = [NSMutableArray arrayWithArray:self.pbWall.layout.framesList];
    PBFrame *frame = [self frameWithFrameIdOnWall:frameIdOnWall];
    [frameArr removeObject:frame];

    PBFrame_Builder *frameBuilder = [PBFrame builderWithPrototype:frameReplaced];
    [frameBuilder setIPhoneRect:frame.iPhoneRect];
    [frameBuilder setIPadRect:frame.iPadRect];
    [frameBuilder setOpusIphoneRect:frame.opusIphoneRect];
    [frameBuilder setOpusIpadRect:frame.opusIpadRect];
    [frameBuilder setIdOnWall:frameIdOnWall];
    [frameArr addObject:[frameBuilder build]];

    PBLayout *layout = [[[[PBLayout builderWithPrototype:self.pbWall.layout] clearFramesList] addAllFrames:frameArr] build];
    [self setLayout:layout];
}

//- (void)replaceFrame:(int)frameId withFrame:(PBFrame *)frameReplaced
//{
//    NSMutableArray *frameArr = [NSMutableArray arrayWithArray:self.pbWall.layout.framesList];
//    PBFrame *frame = [self frameWithFrameId:frameId];
//    [frameArr removeObject:frame];
//    
//    PBFrame_Builder *frameBuilder = [PBFrame builderWithPrototype:frameReplaced];
//    [frameBuilder setIPhoneRect:frame.iPhoneRect];
//    [frameBuilder setIPadRect:frame.iPadRect];
//    [frameBuilder setOpusIphoneRect:frame.opusIphoneRect];
//    [frameBuilder setOpusIpadRect:frame.opusIpadRect];
//    [frameArr addObject:[frameBuilder build]];
//    
//    PBLayout *layout = [[[[PBLayout builderWithPrototype:self.pbWall.layout] clearFramesList] addAllFrames:frameArr] build];
//    [self setLayout:layout];
//    
//    
//    DrawFeed *opus = [[self opusInFrame:frameId] retain];
//    if (opus == nil) {
//        return;
//    }
//    
//    [self.wallOpusDic removeObjectForKey:@(frameId)];
//    [self.wallOpusDic setObject:opus forKey:@(frameReplaced.frameId)];
//    [opus release];
//}

//- (DrawFeed *)opusInFrame:(int)frameId
//{
//    return [_wallOpusDic objectForKey:@(frameId)];
//}
//
//- (int)frameIdWithOpus:(NSString *)opusId
//{
//    for (NSNumber *key in _wallOpusDic) {
//        if ([[[_wallOpusDic objectForKey:key] feedId] isEqualToString:opusId]) {
//            return key.intValue;
//        }
//    }
//    
//    return 0;
//}

- (PBWall *)toPBWall
{
    PBWall_Builder *builder = [[[PBWall_Builder alloc] init] autorelease];
    [builder setWallId:self.pbWall.wallId];
    [builder setWallType:self.pbWall.wallType];
    [builder setUserId:self.pbWall.userId];
    [builder setWallName:self.pbWall.wallName];
    [builder setLayout:self.pbWall.layout];
    [builder setMusicUrl:self.pbWall.musicUrl];
    
    NSMutableArray *pbWallOpuses = [NSMutableArray array];
    for (WallOpus *wallOpus in _wallOpuses) {
        [pbWallOpuses addObject:[wallOpus toPBWallOpus]];
    }
    
    [builder addAllWallOpuses:pbWallOpuses];
    
    return [builder build];
}

@end
