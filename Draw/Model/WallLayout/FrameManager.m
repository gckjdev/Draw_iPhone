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

#define FRAMES_FILE @"frames.pb"
#define BUNDLE_PATH @"frames.pb"
#define LAYOUT_VERSION_KEY @"1.0"

@implementation FrameManager

SYNTHESIZE_SINGLETON_FOR_CLASS(FrameManager);

- (id)init
{
    if (self = [super init]) {
        //check and update data
        PPSmartUpdateData *smartData = [[[PPSmartUpdateData alloc] initWithName:FRAMES_FILE type:SMART_UPDATE_DATA_TYPE_ZIP bundlePath:BUNDLE_PATH initDataVersion:LAYOUT_VERSION_KEY] autorelease];
        
        [smartData checkUpdateAndDownload:^(BOOL isAlreadyExisted, NSString *dataFilePath) {
            PPDebug(@"checkUpdateAndDownload successfully");
        } failureBlock:^(NSError *error) {
            PPDebug(@"checkUpdateAndDownload failure error=%@", [error description]);
        }];
    }
    
    return self;
}



@end
