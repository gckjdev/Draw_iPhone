//
//  FrameManager.m
//  Draw
//
//  Created by 王 小涛 on 13-1-25.
//
//

#import "FrameManager.h"
#import "SynthesizeSingleton.h"
#import "PPSmartUpdateData.h"
#import "Draw.pb.h"

#define FRAMES_ZIP @"frames.zip"
#define BUNDLE_PATH @"frames.zip"
#define FRAMES_PB @"frames.pb"
#define LAYOUT_VERSION_KEY @"1.0"

@interface FrameManager()
{
    NSArray *_frames;
}
@property (retain, nonatomic) PPSmartUpdateData *smartData;
@end

@implementation FrameManager

SYNTHESIZE_SINGLETON_FOR_CLASS(FrameManager);

- (id)init
{
    if (self = [super init]) {
        //check and update data
        self.smartData = [[[PPSmartUpdateData alloc] initWithName:FRAMES_ZIP type:SMART_UPDATE_DATA_TYPE_ZIP bundlePath:BUNDLE_PATH initDataVersion:LAYOUT_VERSION_KEY] autorelease];
        
        [_smartData checkUpdateAndDownload:^(BOOL isAlreadyExisted, NSString *dataFilePath) {
            PPDebug(@"checkUpdateAndDownload successfully");
            
        } failureBlock:^(NSError *error) {
            PPDebug(@"checkUpdateAndDownload failure error=%@", [error description]);
        }];
    }
    
    return self;
}

- (NSArray *)frames
{
    if (_frames == nil) {
        NSString *framesPbFile = [_smartData.dataFilePath stringByAppendingPathComponent:FRAMES_PB];
        NSData *data = [NSData dataWithContentsOfFile:framesPbFile];
        
        _frames = [[[PBFrameList parseFromData:data] framesList] retain];
    }
    
    return _frames;
}

- (NSArray *)framesOfType:(int)type
{
    NSMutableArray *arr = [NSMutableArray array];
    for (PBFrame *frame in self.frames) {
        if (frame.type == type) {
            [arr addObject:frame];
        }
    }
    
    return arr;
}

- (PBFrame *)frameWithFrameId:(int)frameId
{
    for (PBFrame *frame in self.frames) {
        if (frame.frameId == frameId) {
            return frame;
        }
    }
    
    return nil;
}

@end
