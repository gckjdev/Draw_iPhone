////
////  Frame.m
////  Draw
////
////  Created by 王 小涛 on 13-1-25.
////
////
//
//#import "Frame.h"
//
//@interface Frame ()
//@property (assign, nonatomic, readwrite) int frameId;
//@property (assign, nonatomic, readwrite) int type;
//@property (copy, nonatomic, readwrite) NSString *image;
//@property (assign, nonatomic, readwrite) CGRect rect;
//@property (assign, nonatomic, readwrite) CGRect opusRect;
//
//@end
//
//@implementation Frame
//
//- (void)dealloc
//{
//    [_image release];
//    [super dealloc];
//}
//
//- (id)initWithPBFrame:(PBFrame*)pbFrame
//{
//    if (self = [super init]) {
//        self.frameId = pbFrame.frameId;
//        self.type = pbFrame.type;
//        self.image = pbFrame.image;
//        
//        CGRect iphoneRect = CGRectMake(pbFrame.iPhoneRect.x, pbFrame.iPhoneRect.y, pbFrame.iPhoneRect.width, pbFrame.iPhoneRect.height);
//        CGRect ipadRect = CGRectMake(pbFrame.iPadRect.x, pbFrame.iPadRect.y, pbFrame.iPadRect.width, pbFrame.iPadRect.height);
//        self.rect = [DeviceDetection isIPAD] ? ipadRect :iphoneRect;
//
//        CGRect opusIphoneRect = CGRectMake(pbFrame.opusIphoneRect.x, pbFrame.opusIphoneRect.y, pbFrame.opusIphoneRect.width, pbFrame.opusIphoneRect.height);
//        CGRect opusIpadRect = CGRectMake(pbFrame.opusIpadRect.x, pbFrame.opusIpadRect.y, pbFrame.opusIpadRect.width, pbFrame.opusIpadRect.height);
//        self.opusRect = [DeviceDetection isIPAD] ? opusIpadRect : opusIphoneRect;
//        
//        
//    }
//    
//    return self;
//}
//
//
//+ (Frame *)frameFromPBFrame:(PBFrame *)pbFrame
//{
//    return [[[self alloc] initWithPBFrame:pbFrame] autorelease];
//}
//
//@end
