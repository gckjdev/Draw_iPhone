////
////  Layout.m
////  Draw
////
////  Created by 王 小涛 on 13-1-24.
////
////
//
//#import "Layout.h"
//
//@interface Layout()
//
//@property (assign, nonatomic) int layoutId;
//@property (copy, nonatomic) NSString *name;
//@property (assign, nonatomic) CGRect rect;
//@property (assign, nonatomic) int price;
//
//@end
//
//@implementation Layout
//
//- (void)dealloc
//{
//    [_name release];
//    [_frames release];
//    [_bgImage release];
//    
//    [super dealloc];
//}
//
//- (id)initWithPBLayout:(PBLayout *)pbLayout
//{
//    if (self = [super init]) {
//        self.layoutId = pbLayout.layoutId;
//        self.name = pbLayout.name;
//        self.displayMode = pbLayout.displayMode;
//        self.coverFlowType = pbLayout.coverFlowType;
//        
//        CGRect iphoneRect = CGRectMake(pbLayout.iPhoneRect.x, pbLayout.iPhoneRect.y, pbLayout.iPhoneRect.width, pbLayout.iPhoneRect.height);
//        CGRect ipadRect = CGRectMake(pbLayout.iPadRect.x, pbLayout.iPadRect.y, pbLayout.iPadRect.width, pbLayout.iPadRect.height);
//        self.rect = [DeviceDetection isIPAD] ? ipadRect : iphoneRect;
//        self.frames = [NSMutableArray array];
//        
//        for (PBFrame *pbFrame in pbLayout.framesList) {
//            [self.frames addObject:[Frame frameFromPBFrame:pbFrame]];
//        }
//        
//        self.bgImage = pbLayout.bgImage;
//        self.price = pbLayout.price;
//    }
//    
//    return self;
//}
//
//+ (Layout *)layoutFromPBLayout:(PBLayout *)pbLayout
//{
//    return [[[Layout alloc] initWithPBLayout:pbLayout] autorelease];
//}
//
//- (Frame *)frameWithFrameId:(int)frameId
//{
//    for (Frame *frame in _frames) {
//        if (frame.frameId == frameId) {
//            return frame;
//        }
//    }
//    return nil;
//}
//
//- (void)changeFrame:(int)frameId withFrame:(Frame *)frame
//{
//    [_frames removeObject:[self frameWithFrameId:frameId]];
//    [_frames addObject:frame];
//}
//
//
//
//
//@end
//
//
//
////@implementation PBLayout (Mutable)
////
////- (void)setBgImage:(NSString *)bgImage1
////{
////    self.bgImage = bgImage1;
////}
////
////@end
