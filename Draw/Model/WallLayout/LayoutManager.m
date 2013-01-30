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


@end
