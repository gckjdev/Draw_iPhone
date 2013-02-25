//
//  ProtocolUtil.m
//  Draw
//
//  Created by 王 小涛 on 13-1-29.
//
//

#import "ProtocolUtil.h"
#import "FrameManager.h"

@implementation ProtocolUtil


+ (PBRect *)pbRectWithX:(int)x y:(int)y width:(int)width height:(int)height
{
    PBRect_Builder *builder = [[[PBRect_Builder alloc] init] autorelease];
    [builder setX:x];
    [builder setY:y];
    [builder setWidth:width];
    [builder setHeight:height];
    return [builder build];
}

+ (PBWallOpus *)pbWallOpusWithIdOnWall:(int)idOnWall frame:(PBFrame *)frame
{
    PBWallOpus_Builder *builder = [[[PBWallOpus_Builder alloc] init] autorelease];
    [builder setIdOnWall:idOnWall];
    
    if (frame == nil) {
        [builder setFrame:[self blankFrame]];
    }else{
        [builder setFrame:frame];
    }
    
    return [builder build];
}


+ (PBFrame *)pbFrameWithFrameId:(int)frameId
                           type:(int)type
                       imageUrl:(NSString *)imageUrl
                 opusIphoneRect:(PBRect *)opusIphoneRect
                   opusIpadRect:(PBRect *)opusIpadRect
                          price:(int)price
{
    PBFrame_Builder *builder = [[[PBFrame_Builder alloc] init] autorelease];
    
    [builder setFrameId:frameId];
    [builder setType:type];
    [builder setImageUrl:imageUrl];
    [builder setOpusIphoneRect:opusIpadRect];
    [builder setOpusIpadRect:opusIpadRect];
    [builder setPrice:price];
    return [builder build];
}

+ (PBLayout *)pbLayoutWithLayoutId:(int)layoutId
                              name:(NSString *)name
                       displayMode:(int)displayMode
                        wallOpuses:(NSArray *)wallOpuses
                           bgImage:(NSString *)bgImage
                             price:(int)price
{
    PBLayout_Builder *builder = [[[PBLayout_Builder alloc] init] autorelease];
    [builder setLayoutId:layoutId];
    [builder setName:name];
    [builder setDisplayMode:displayMode];
    [builder addAllWallOpuses:wallOpuses];
    [builder setImageUrl:bgImage];
    [builder setPrice:price];
    return [builder build];
}

+ (PBLayout *)createTestData1
{
    PBWallOpus *wallOpus1 = [self pbWallOpusWithIdOnWall:0 frame:[[FrameManager sharedFrameManager] frameWithFrameId:301]];
    PBWallOpus *wallOpus2 = [self pbWallOpusWithIdOnWall:1 frame:[[FrameManager sharedFrameManager] frameWithFrameId:302]];
    PBWallOpus *wallOpus3 = [self pbWallOpusWithIdOnWall:2 frame:[[FrameManager sharedFrameManager] frameWithFrameId:303]];
    PBWallOpus *wallOpus4 = [self pbWallOpusWithIdOnWall:3 frame:[[FrameManager sharedFrameManager] frameWithFrameId:304]];
    PBWallOpus *wallOpus5 = [self pbWallOpusWithIdOnWall:4 frame:[[FrameManager sharedFrameManager] frameWithFrameId:305]];
    PBWallOpus *wallOpus6 = [self pbWallOpusWithIdOnWall:5 frame:[[FrameManager sharedFrameManager] frameWithFrameId:304]];
    PBWallOpus *wallOpus7 = [self pbWallOpusWithIdOnWall:6 frame:[[FrameManager sharedFrameManager] frameWithFrameId:303]];
    PBWallOpus *wallOpus8 = [self pbWallOpusWithIdOnWall:7 frame:[[FrameManager sharedFrameManager] frameWithFrameId:302]];
    PBWallOpus *wallOpus9 = [self pbWallOpusWithIdOnWall:8 frame:[[FrameManager sharedFrameManager] frameWithFrameId:301]];

    NSArray *wallOpuses = [NSArray arrayWithObjects:wallOpus1, wallOpus2, wallOpus3, wallOpus4, wallOpus5, wallOpus6, wallOpus7, wallOpus8, wallOpus9, nil];
    
    PBLayout *layout1 = [self pbLayoutWithLayoutId:1000 name:@"默认布局" displayMode:0  wallOpuses:wallOpuses bgImage:@"default_layout.png" price:1000];
    
    return layout1;
}

+ (PBLayout *)createTestData
{
    PBWallOpus *wallOpus1 = [self pbWallOpusWithIdOnWall:0 frame:[[FrameManager sharedFrameManager] frameWithFrameId:300]];
    PBWallOpus *wallOpus2 = [self pbWallOpusWithIdOnWall:1 frame:[[FrameManager sharedFrameManager] frameWithFrameId:301]];
    PBWallOpus *wallOpus3 = [self pbWallOpusWithIdOnWall:2 frame:[[FrameManager sharedFrameManager] frameWithFrameId:302]];
    PBWallOpus *wallOpus4 = [self pbWallOpusWithIdOnWall:3 frame:[[FrameManager sharedFrameManager] frameWithFrameId:303]];
    PBWallOpus *wallOpus5 = [self pbWallOpusWithIdOnWall:4 frame:[[FrameManager sharedFrameManager] frameWithFrameId:304]];
    PBWallOpus *wallOpus6 = [self pbWallOpusWithIdOnWall:5 frame:[[FrameManager sharedFrameManager] frameWithFrameId:305]];
    PBWallOpus *wallOpus7 = [self pbWallOpusWithIdOnWall:6 frame:[[FrameManager sharedFrameManager] frameWithFrameId:304]];
    PBWallOpus *wallOpus8 = [self pbWallOpusWithIdOnWall:7 frame:[[FrameManager sharedFrameManager] frameWithFrameId:303]];
    PBWallOpus *wallOpus9 = [self pbWallOpusWithIdOnWall:8 frame:[[FrameManager sharedFrameManager] frameWithFrameId:301]];
    
    NSArray *wallOpuses = [NSArray arrayWithObjects:wallOpus1, wallOpus2, wallOpus3, wallOpus4, wallOpus5, wallOpus6, wallOpus7, wallOpus8, wallOpus9, nil];
    
    PBLayout *layout1 = [self pbLayoutWithLayoutId:1000 name:@"默认布局" displayMode:4  wallOpuses:wallOpuses bgImage:@"default_layout.png" price:1000];
    
    return layout1;
}

+ (void)createFramesTestData
{
    PBFrame_Builder *builder1 = [[[PBFrame_Builder alloc] init] autorelease];
    [builder1 setFrameId:301];
    [builder1 setType:1];
    [builder1 setImageUrl:@"http://58.215.160.100:8080/app_res/test/frame_301.jpg"];
    [builder1 setOpusIphoneRect:[self pbRectWithX:80 y:113 width:120 height:95]];
    [builder1 setPrice:200];
    PBFrame *frame1 = [builder1 build];
    
    PBFrame_Builder *builder2 = [[[PBFrame_Builder alloc] init] autorelease];
    [builder2 setFrameId:302];
    [builder2 setType:1];
    [builder2 setImageUrl:@"http://58.215.160.100:8080/app_res/test/frame_302.jpg"];
    [builder2 setOpusIphoneRect:[self pbRectWithX:80 y:113 width:120 height:95]];
    [builder2 setPrice:200];
    PBFrame *frame2 = [builder2 build];
    
    PBFrame_Builder *builder3 = [[[PBFrame_Builder alloc] init] autorelease];
    [builder3 setFrameId:303];
    [builder3 setType:1];
    [builder3 setImageUrl:@"http://58.215.160.100:8080/app_res/test/frame_303.jpg"];
    [builder3 setOpusIphoneRect:[self pbRectWithX:80 y:113 width:120 height:95]];
    [builder3 setPrice:200];
    PBFrame *frame3 = [builder3 build];
    
    PBFrame_Builder *builder4 = [[[PBFrame_Builder alloc] init] autorelease];
    [builder4 setFrameId:304];
    [builder4 setType:1];
    [builder4 setImageUrl:@"http://58.215.160.100:8080/app_res/test/frame_304.jpg"];
    [builder4 setPrice:200];
    [builder4 setOpusIphoneRect:[self pbRectWithX:80 y:113 width:120 height:95]];
    PBFrame *frame4 = [builder4 build];
    
    PBFrame_Builder *builder5 = [[[PBFrame_Builder alloc] init] autorelease];
    [builder5 setFrameId:305];
    [builder5 setType:1];
    [builder5 setImageUrl:@"http://58.215.160.100:8080/app_res/test/frame_305.jpg"];
    [builder5 setPrice:200];
    [builder5 setOpusIphoneRect:[self pbRectWithX:80 y:113 width:120 height:95]];
    PBFrame *frame5 = [builder5 build];
    
    PBFrame_Builder *builder6 = [[[PBFrame_Builder alloc] init] autorelease];
    [builder6 setFrameId:300];
    [builder6 setType:0];
    [builder6 setImageUrl:@"blank frame.jpg"];
    [builder6 setPrice:200];
    [builder6 setOpusIphoneRect:[self pbRectWithX:80 y:113 width:120 height:95]];
    PBFrame *frame6 = [builder6 build];
    
    PBFrameList_Builder *builder = [[[PBFrameList_Builder alloc] init] autorelease];
    [builder addAllFrames:[NSArray arrayWithObjects:frame1, frame2, frame3, frame4, frame5, frame6, nil]];
    [[[builder build] data] writeToFile:@"/Users/Linruin/frames.pb" atomically:YES];
}


+ (PBFrame *)blankFrame
{
    PBFrame_Builder *builder = [[[PBFrame_Builder alloc] init] autorelease];
    [builder setFrameId:300];
    [builder setType:0];
    [builder setImageUrl:nil];
    [builder setPrice:200];
    [builder setOpusIphoneRect:[self pbRectWithX:80 y:113 width:120 height:95]];
    PBFrame *frame6 = [builder build];
    
    return frame6;
}


@end
