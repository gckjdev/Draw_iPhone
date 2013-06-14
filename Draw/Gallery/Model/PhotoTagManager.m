//
//  PhotoTagManager.m
//  Draw
//
//  Created by Kira on 13-6-14.
//
//

#import "PhotoTagManager.h"
#import "SynthesizeSingleton.h"
#import "PPSmartUpdateData.h"
#import "TagPackage.h"

#define PHOTO_TAG_FILE  ([LocaleUtils isChinese]?@"photo_tags.txt":@"photo_tags_en.txt")
#define BUNDLE_FILE     ([LocaleUtils isChinese]?@"photo_tags.txt":@"photo_tags_en.txt")
#define INIT_VER    @"1.0"

@interface PhotoTagManager ()

@property (retain, nonatomic) PPSmartUpdateData* smartData;

@end

@implementation PhotoTagManager

- (id)init
{
    
    self = [super init];
    if (self) {
        self.smartData = [[[PPSmartUpdateData alloc] initWithName:PHOTO_TAG_FILE type:SMART_UPDATE_DATA_TYPE_TXT bundlePath:BUNDLE_FILE initDataVersion:INIT_VER] autorelease];
        
        [_smartData checkUpdateAndDownload:^(BOOL isAlreadyExisted, NSString *dataFilePath) {
            PPDebug(@"checkUpdateAndDownload successfully");
        } failureBlock:^(NSError *error) {
            PPDebug(@"checkUpdateAndDownload failure error=%@", [error description]);
        }];
    }
    return self;
}

SYNTHESIZE_SINGLETON_FOR_CLASS(PhotoTagManager)

- (NSArray*)tagPackageArray
{
    NSError* err;
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8);
    NSString* tagsFileStr = [NSString stringWithContentsOfFile:_smartData.dataFilePath encoding:enc error:&err];
    return [TagPackage createPackageArrayFromString:tagsFileStr];
}

@end
