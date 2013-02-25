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
#import "ProtocolUtil.h"

@interface Wall ()

@property (retain, nonatomic) PBWall *pbWall;

@end

@implementation Wall

- (void)dealloc
{
    [_pbWall release];
    [super dealloc];
}

- (id)initWithPBWall:(PBWall *)pbWall
{
    if (self = [super init]) {
        self.pbWall = pbWall;
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
        [builder setName:name];
        [builder setType:PBWallTypeOpuses];
        [builder setUserId:[[UserManager defaultManager] userId]];
        [builder setContent:layout];
        [builder setMusicUrl:musicUrl];
        
        self.pbWall = [builder build];
        
        for (int index=0; index<[layout.wallOpusesList count] && index<[opuses count]; index++) {
            [self replaceWallOpus:[[layout.wallOpusesList objectAtIndex:index] idOnWall] withOpus:[opuses objectAtIndex:index]];
        }
    }
    
    return self;
}

- (void)setWallId:(NSString *)wallId
{
    self.pbWall = [[[PBWall builderWithPrototype:_pbWall] setWallId:wallId] build];
}

- (NSArray *)opusList
{
    NSMutableArray *arr = [NSMutableArray array];
    for (PBWallOpus *wallOpus in _pbWall.content.wallOpusesList) {
        if (wallOpus.opus != nil) {
            [arr addObject:wallOpus.opus];
        }
    }
    
    return arr;
}

- (void)setLayout:(PBLayout *)layout
{
   self.pbWall = [[[PBWall builderWithPrototype:_pbWall] setContent:layout] build];
}

- (void)setDisplayMode:(int)displayMode
{
    PBLayout_Builder *builder = [PBLayout builderWithPrototype:_pbWall.content];
    [builder setDisplayMode:displayMode];
    PBLayout *layout = [builder build];
    
    [self setLayout:layout];
}

- (void)setWallName:(NSString *)wallName
{
    self.pbWall = [[[PBWall builderWithPrototype:_pbWall] setName:wallName] build];
}

- (PBWallOpus *)wallOpusWithIdOnWall:(int)idOnWall
{
    for (PBWallOpus *wallOpus in self.pbWall.content.wallOpusesList) {
        if (wallOpus.idOnWall == idOnWall) {
            return wallOpus;
        }
    }
    
    return nil;
}

- (PBFrame *)frameInWallOpus:(int)idOnWall
{
    PBWallOpus *wallOpus = [self wallOpusWithIdOnWall:idOnWall];
    return wallOpus.frame;
}

- (PBFeed *)drawFeedToPBFeed:(DrawFeed *)drawFeed
{
    PBFeed_Builder *feedBuilder = [[[PBFeed_Builder alloc] init] autorelease];
    
    [feedBuilder setFeedId:drawFeed.feedId];
    [feedBuilder setUserId:drawFeed.feedUser.userId];
    [feedBuilder setActionType:drawFeed.actionType];
    [feedBuilder setCreateDate:[[drawFeed createDate] timeIntervalSince1970]];
    
    [feedBuilder setOpusWord:drawFeed.wordText];
    [feedBuilder setOpusImage:drawFeed.drawImageUrl];
    
    PBFeed *feed = [feedBuilder build];
    
    return feed;
}

- (void)replaceWallOpus:(int)idOnWall withFeed:(PBFeed *)newFeed
{
    PBWallOpus *wallOpus = [self wallOpusWithIdOnWall:idOnWall];
    
    PBWallOpus_Builder *builder = [PBWallOpus builderWithPrototype:wallOpus];
    [builder setIdOnWall:idOnWall];
    [builder setOpus:newFeed];
    PBWallOpus *newWallOpus = [builder build];
    
    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.pbWall.content.wallOpusesList];
    [arr removeObject:wallOpus];
    [arr addObject:newWallOpus];
    
    PPDebug(@"content: %@", _pbWall.content);
    PBLayout_Builder *layoutBuilder = [PBLayout builderWithPrototype:_pbWall.content];
    [layoutBuilder clearWallOpusesList];
    [layoutBuilder addAllWallOpuses:arr];
    PBLayout *content = [layoutBuilder build];
    
    self.pbWall = [[[PBWall builderWithPrototype:_pbWall] setContent:content] build];
}

- (void)replaceWallOpus:(int)idOnWall withOpus:(DrawFeed *)newOpus
{
    [self replaceWallOpus:idOnWall withFeed:[self drawFeedToPBFeed:newOpus]];
}

- (void)replaceWallOpus:(int)idOnWall withFrame:(PBFrame *)newFrame
{
    PBWallOpus *wallOpus = [self wallOpusWithIdOnWall:idOnWall];
    if (wallOpus == nil) {
        return;
    }
        
    PBWallOpus_Builder *builder = [PBWallOpus builderWithPrototype:wallOpus];
    [builder setFrame:newFrame];
    PBWallOpus *newWallOpus = [builder build];
    
    NSMutableArray *arr = [NSMutableArray arrayWithArray:self.pbWall.content.wallOpusesList];
    [arr removeObject:wallOpus];
    [arr addObject:newWallOpus];
    
    PBLayout *content = [[[[PBLayout builderWithPrototype:_pbWall.content] clearWallOpusesList] addAllWallOpuses:arr] build];
    
    
    self.pbWall = [[[PBWall builderWithPrototype:_pbWall] setContent:content] build];
}

- (PBWall *)toPBWall
{    
    PBWall_Builder *builder = [[[PBWall_Builder alloc] init] autorelease];
    [builder setWallId:_pbWall.wallId];
    [builder setType:_pbWall.type];
    [builder setUserId:_pbWall.userId];
    [builder setName:_pbWall.name];
    [builder setContent:[self contentWithoutOpusDetailInfo]];
    [builder setMusicUrl:self.pbWall.musicUrl];
    
    return [builder build];
}

- (PBFeed *)simpleFeedWithPBFeed:(PBFeed *)feed
{
    PBFeed_Builder *feedBuilder = [[[PBFeed_Builder alloc] init] autorelease];
    [feedBuilder setFeedId:feed.feedId];
    [feedBuilder setOpusImage:feed.opusImage];
    [feedBuilder setUserId:feed.userId];
    [feedBuilder setActionType:feed.actionType];
    [feedBuilder setCreateDate:feed.createDate];
    
    PBFeed *newOpus = [feedBuilder build];
    
    return newOpus;
}

- (PBLayout *)contentWithoutOpusDetailInfo
{
    NSMutableArray *wallOpusList = [NSMutableArray array];
    for (PBWallOpus *wallOpus in _pbWall.content.wallOpusesList) {

        if (wallOpus.opus == nil) {
            [wallOpusList addObject:wallOpus];
        }else{
            PBWallOpus_Builder *wallOpusBuilder = [PBWallOpus builderWithPrototype:wallOpus];
            PBWallOpus *newWallOpus = [[wallOpusBuilder setOpus:[self simpleFeedWithPBFeed:wallOpus.opus]] build];
            [wallOpusList addObject:newWallOpus];
        }
    }
    
    PBLayout_Builder *layoutBuilder = [PBLayout builderWithPrototype:_pbWall.content];
    [[layoutBuilder clearWallOpusesList] addAllWallOpuses:wallOpusList];
    PBLayout *newContent = [layoutBuilder build];
    
    return newContent;
}


- (void)setBgImage:(NSString *)image;
{
    [self setLayout:[[[PBLayout builderWithPrototype:self.pbWall.content] setImageUrl:image] build]];
}

@end
