//
//  LayoutManager.m
//  Draw
//
//  Created by 王 小涛 on 13-1-24.
//
//

#import "LayoutManager.h"
#import "SynthesizeSingleton.h"
#import "PPSmartUpdateData.h"
#import "PPSmartUpdateDataUtils.h"

#define LAYOUT_FILE @"layout.zip"
#define BUNDLE_PATH @"layout.zip"
#define LAYOUT_VERSION_KEY @"1.0"

#define LAYOUT_PB_FILE @"layout.pb"

@interface LayoutManager()
@property (copy, nonatomic) NSString *layoutPath;
@property (retain, nonatomic) NSArray *layouts;
@end

@implementation LayoutManager

SYNTHESIZE_SINGLETON_FOR_CLASS(LayoutManager);

- (void)dealloc
{
    [_layoutPath release];
    [_layouts release];
    [super dealloc];
}

- (id)init
{
    if (self = [super init]) {
        //check and update data
        PPSmartUpdateData *smartData = [[[PPSmartUpdateData alloc] initWithName:LAYOUT_FILE type:SMART_UPDATE_DATA_TYPE_ZIP bundlePath:BUNDLE_PATH initDataVersion:LAYOUT_VERSION_KEY] autorelease];
        
        [smartData checkUpdateAndDownload:^(BOOL isAlreadyExisted, NSString *dataFilePath) {
            PPDebug(@"checkUpdateAndDownload successfully");
            self.layoutPath = dataFilePath;
            NSData *data = [NSData dataWithContentsOfFile:[_layoutPath stringByAppendingPathComponent:LAYOUT_PB_FILE]];
            self.layouts = [[PBLayoutList parseFromData:data] layoutsList];
            
        } failureBlock:^(NSError *error) {
            PPDebug(@"checkUpdateAndDownload failure error=%@", [error description]);
        }];
    }
    
    return self;
}


- (PBLayout *)layoutWithLayoutId:(int)layoutId
{
    for(PBLayout *layout in _layouts)
    {
        if (layout.layoutId == layoutId) {
            return layout;
        }
    }
    
    return nil;
}

+ (PBRect *)pbRectWithX:(int)x y:(int)y width:(int)width height:(int)height
{
    PBRect_Builder *builder = [[[PBRect_Builder alloc] init] autorelease];
    [builder setX:x];
    [builder setY:y];
    [builder setWidth:width];
    [builder setHeight:height];
    return [builder build];
}

+ (PBFrame *)pbFrameWithFrameId:(int)frameId type:(int)type image:(NSString *)image iphoneRect:(PBRect*)iphoneRect ipadRect:(PBRect*)ipadRect opusIphoneRect:(PBRect*)opusIphoneRect opusIpadRect:(PBRect*)opusIpadRect price:(int)price
{
    PBFrame_Builder *builder = [[[PBFrame_Builder alloc] init] autorelease];
    [builder setFrameId:frameId];
    [builder setFrameType:type];
    [builder setImage:image];
    [builder setIPhoneRect:iphoneRect];
    [builder setIPadRect:ipadRect];
    [builder setOpusIphoneRect:opusIphoneRect];
    [builder setOpusIpadRect:ipadRect];
    [builder setPrice:price];
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

+ (PBLayout *)createTestData
{
    PBFrame *frame1 = [self pbFrameWithFrameId:301 type:2 image:@"frame_301.png" iphoneRect:[LayoutManager pbRectWithX:40 y:40 width:110 height:110] ipadRect:nil opusIphoneRect:[LayoutManager pbRectWithX:2 y:2 width:46 height:46] opusIpadRect:nil price:200];
    
    PBFrame *frame2 = [self pbFrameWithFrameId:302 type:2 image:@"frame_302.png" iphoneRect:[LayoutManager pbRectWithX:170 y:40 width:110 height:110] ipadRect:nil opusIphoneRect:[LayoutManager pbRectWithX:2 y:2 width:46 height:46] opusIpadRect:nil price:200];
    
    PBFrame *frame3 = [self pbFrameWithFrameId:303 type:2 image:@"frame_302.png" iphoneRect:[LayoutManager pbRectWithX:40 y:170 width:110 height:110] ipadRect:nil opusIphoneRect:[LayoutManager pbRectWithX:2 y:2 width:46 height:46] opusIpadRect:nil price:200];
    
    PBFrame *frame4 = [self pbFrameWithFrameId:304 type:2 image:@"frame_302.png" iphoneRect:[LayoutManager pbRectWithX:170 y:170 width:110 height:110] ipadRect:nil opusIphoneRect:[LayoutManager pbRectWithX:2 y:2 width:46 height:46] opusIpadRect:nil price:200];
    
    NSArray *frames = [NSArray arrayWithObjects:frame1, frame2, frame3, frame4, nil];

    PBLayout *layout1 = [self pbLayoutWithLayoutId:1000 name:@"默认布局" displayMode:0 coverFlowType:0 frames:frames bgImage:@"default_layout.png" iphoneRect:[LayoutManager pbRectWithX:0 y:0 width:320 height:480] ipadRect:[LayoutManager pbRectWithX:2 y:2 width:768 height:1024] price:1000];
    
//    [[layout1 data] writeToFile:@"/Users/Linruin/layout.pb" atomically:YES];
    
    return layout1;
}

@end
