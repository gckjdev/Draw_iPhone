//
//  ProtocolUtil.m
//  Draw
//
//  Created by 王 小涛 on 13-1-29.
//
//

#import "ProtocolUtil.h"

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

+ (PBFrame *)pbFrameWithFrameId:(int)frameId iphoneRect:(PBRect*)iphoneRect ipadRect:(PBRect*)ipadRect opusIphoneRect:(PBRect*)opusIphoneRect opusIpadRect:(PBRect*)opusIpadRect idOnWall:(int)idOnWall
{
    PBFrame_Builder *builder = [[[PBFrame_Builder alloc] init] autorelease];
    [builder setFrameId:frameId];
    [builder setIPhoneRect:iphoneRect];
    [builder setIPadRect:ipadRect];
    [builder setOpusIphoneRect:opusIphoneRect];
    [builder setOpusIpadRect:ipadRect];
    [builder setIdOnWall:idOnWall];
    return [builder build];
}

+ (PBLayout *)pbLayoutWithLayoutId:(int)layoutId name:(NSString *)name displayMode:(int)displayMode coverFlowType:(int)coverFlowType frames:(NSArray *)frames bgImage:(NSString *)bgImage iphoneRect:(PBRect *)iphoneRect ipadRect:(PBRect*)ipadRect price:(int)price 
{
    PBLayout_Builder *builder = [[[PBLayout_Builder alloc] init] autorelease];
    [builder setLayoutId:layoutId];
    [builder setName:name];
    [builder setDisplayMode:displayMode];
    [builder setCoverFlowType:coverFlowType];
    [builder addAllFrames:frames];
    [builder setBgImage:bgImage];
    [builder setIPhoneRect:iphoneRect];
    [builder setIPadRect:ipadRect];
    [builder setPrice:price];
    return [builder build];
}

+ (PBLayout *)createTestData1
{
    PBFrame *frame1 = [self pbFrameWithFrameId:304 iphoneRect:[self pbRectWithX:110 y:40 width:110 height:110] ipadRect:nil opusIphoneRect:[self pbRectWithX:15 y:15 width:80 height:80] opusIpadRect:nil idOnWall:0];
    
//    PBFrame *frame2 = [self pbFrameWithFrameId:304 iphoneRect:[self pbRectWithX:170 y:40 width:110 height:110] ipadRect:nil opusIphoneRect:[self pbRectWithX:15 y:15 width:80 height:80] opusIpadRect:nil idOnWall:1];
    
    PBFrame *frame3 = [self pbFrameWithFrameId:304 iphoneRect:[self pbRectWithX:40 y:170 width:110 height:110] ipadRect:nil opusIphoneRect:[self pbRectWithX:15 y:15 width:80 height:80] opusIpadRect:nil idOnWall:2];
    
    PBFrame *frame4 = [self pbFrameWithFrameId:304 iphoneRect:[self pbRectWithX:170 y:170 width:110 height:110] ipadRect:nil opusIphoneRect:[self pbRectWithX:15 y:15 width:80 height:80] opusIpadRect:nil idOnWall:3];
    
    NSArray *frames = [NSArray arrayWithObjects:frame1, frame3, frame4, nil];
    
    PBLayout *layout1 = [self pbLayoutWithLayoutId:1000 name:@"默认布局" displayMode:0 coverFlowType:0 frames:frames bgImage:@"default_layout.png" iphoneRect:[self pbRectWithX:0 y:0 width:320 height:480] ipadRect:[self pbRectWithX:2 y:2 width:768 height:1024] price:1000];
    
    return layout1;
}

+ (PBLayout *)createTestData
{
    PBFrame *frame1 = [self pbFrameWithFrameId:301 iphoneRect:[self pbRectWithX:40 y:40 width:110 height:110] ipadRect:nil opusIphoneRect:[self pbRectWithX:15 y:15 width:80 height:80] opusIpadRect:nil idOnWall:0];
    
    PBFrame *frame2 = [self pbFrameWithFrameId:302 iphoneRect:[self pbRectWithX:170 y:40 width:110 height:110] ipadRect:nil opusIphoneRect:[self pbRectWithX:15 y:15 width:80 height:80] opusIpadRect:nil idOnWall:1];
    
    PBFrame *frame3 = [self pbFrameWithFrameId:303 iphoneRect:[self pbRectWithX:40 y:170 width:110 height:110] ipadRect:nil opusIphoneRect:[self pbRectWithX:15 y:15 width:80 height:80] opusIpadRect:nil idOnWall:2];
    
    PBFrame *frame4 = [self pbFrameWithFrameId:304 iphoneRect:[self pbRectWithX:170 y:170 width:110 height:110] ipadRect:nil opusIphoneRect:[self pbRectWithX:15 y:15 width:80 height:80] opusIpadRect:nil idOnWall:3];
    
    PBFrame *frame5 = [self pbFrameWithFrameId:304 iphoneRect:[self pbRectWithX:170 y:170 width:110 height:110] ipadRect:nil opusIphoneRect:[self pbRectWithX:15 y:15 width:80 height:80] opusIpadRect:nil idOnWall:4];
    
    PBFrame *frame6 = [self pbFrameWithFrameId:304 iphoneRect:[self pbRectWithX:170 y:170 width:110 height:110] ipadRect:nil opusIphoneRect:[self pbRectWithX:15 y:15 width:80 height:80] opusIpadRect:nil idOnWall:5];
    
    PBFrame *frame7 = [self pbFrameWithFrameId:304 iphoneRect:[self pbRectWithX:170 y:170 width:110 height:110] ipadRect:nil opusIphoneRect:[self pbRectWithX:15 y:15 width:80 height:80] opusIpadRect:nil idOnWall:6];
    
    PBFrame *frame8 = [self pbFrameWithFrameId:304 iphoneRect:[self pbRectWithX:170 y:170 width:110 height:110] ipadRect:nil opusIphoneRect:[self pbRectWithX:15 y:15 width:80 height:80] opusIpadRect:nil idOnWall:7];

    
    PBFrame *frame9 = [self pbFrameWithFrameId:304 iphoneRect:[self pbRectWithX:170 y:170 width:110 height:110] ipadRect:nil opusIphoneRect:[self pbRectWithX:15 y:15 width:80 height:80] opusIpadRect:nil idOnWall:8];

    
    NSArray *frames = [NSArray arrayWithObjects:frame1, frame2, frame3, frame4, frame5, frame6, frame7, frame8, frame9, nil];
    
    PBLayout *layout1 = [self pbLayoutWithLayoutId:1000 name:@"默认布局" displayMode:1 coverFlowType:0 frames:frames bgImage:@"default_layout.png" iphoneRect:[self pbRectWithX:0 y:0 width:320 height:480] ipadRect:[self pbRectWithX:2 y:2 width:768 height:1024] price:1000];
    
    return layout1;
}

+ (void)createFramesTestData
{
    PBFrame_Builder *builder1 = [[[PBFrame_Builder alloc] init] autorelease];
    [builder1 setFrameId:301];
    [builder1 setFrameType:1];
    [builder1 setThumbImage:@"thumb_image/frame_thumb_301.jpg"];
    [builder1 setImage:@"image/frame_301.jpg"];
    [builder1 setIPhoneRect:[self pbRectWithX:0 y:0 width:110 height:110]];
    [builder1 setOpusIphoneRect:[self pbRectWithX:0 y:0 width:80 height:80]];
    [builder1 setPrice:200];
    PBFrame *frame1 = [builder1 build];
    
    PBFrame_Builder *builder2 = [[[PBFrame_Builder alloc] init] autorelease];
    [builder2 setFrameId:302];
    [builder2 setFrameType:1];
    [builder2 setThumbImage:@"thumb_image/frame_thumb_302.jpg"];
    [builder2 setImage:@"image/frame_302.jpg"];
    [builder2 setIPhoneRect:[self pbRectWithX:0 y:0 width:110 height:110]];
    [builder2 setOpusIphoneRect:[self pbRectWithX:10 y:10 width:80 height:80]];
    [builder2 setPrice:200];
    PBFrame *frame2 = [builder2 build];
    
    PBFrame_Builder *builder3 = [[[PBFrame_Builder alloc] init] autorelease];
    [builder3 setFrameId:303];
    [builder3 setFrameType:1];
    [builder3 setThumbImage:@"thumb_image/frame_thumb_303.jpg"];
    [builder3 setImage:@"image/frame_303.jpg"];
    [builder3 setIPhoneRect:[self pbRectWithX:0 y:0 width:110 height:110]];
    [builder3 setOpusIphoneRect:[self pbRectWithX:15 y:15 width:80 height:80]];
    [builder3 setPrice:200];
    PBFrame *frame3 = [builder3 build];
    
    PBFrame_Builder *builder4 = [[[PBFrame_Builder alloc] init] autorelease];
    [builder4 setFrameId:304];
    [builder4 setFrameType:1];
    [builder4 setThumbImage:@"thumb_image/frame_thumb_304.jpg"];
    [builder4 setImage:@"image/frame_304.jpg"];
    [builder4 setPrice:200];
    [builder4 setIPhoneRect:[self pbRectWithX:0 y:0 width:110 height:110]];
    [builder4 setOpusIphoneRect:[self pbRectWithX:20 y:20 width:80 height:80]];
    PBFrame *frame4 = [builder4 build];
    
    PBFrame_Builder *builder5 = [[[PBFrame_Builder alloc] init] autorelease];
    [builder5 setFrameId:305];
    [builder5 setFrameType:1];
    [builder5 setThumbImage:@"thumb_image/frame_thumb_305.jpg"];
    [builder5 setImage:@"image/frame_305.jpg"];
    [builder5 setPrice:200];
    [builder5 setIPhoneRect:[self pbRectWithX:0 y:0 width:110 height:110]];
    [builder5 setOpusIphoneRect:[self pbRectWithX:25 y:25 width:80 height:80]];
    PBFrame *frame5 = [builder5 build];
    
    PBFrameList_Builder *builder = [[[PBFrameList_Builder alloc] init] autorelease];
    [builder addAllFrames:[NSArray arrayWithObjects:frame1, frame2, frame3, frame4, frame5, nil]];
    [[[builder build] data] writeToFile:@"/Users/Linruin/gitdata/frames.pb" atomically:YES];
}


@end
