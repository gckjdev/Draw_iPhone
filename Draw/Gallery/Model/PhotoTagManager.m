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

@interface PhotoTagManager ()

@property (retain, nonatomic) PPSmartUpdateData* smartData;

@end

@implementation PhotoTagManager

- (id)init
{
    
    self = [super init];
    if (self) {
        NSString* smartDataFile = [LocaleUtils isChinese]?[GameApp photoTagsCn]:[GameApp photoTagsEn];
        self.smartData = [[[PPSmartUpdateData alloc] initWithName:smartDataFile type:SMART_UPDATE_DATA_TYPE_TXT bundlePath:smartDataFile initDataVersion:@"1.0"] autorelease];
        
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
