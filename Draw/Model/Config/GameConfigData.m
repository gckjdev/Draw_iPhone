//
//  GameConfigData.m
//  Draw
//
//  Created by qqn_pipi on 12-11-30.
//
//

#import "GameConfigData.h"
#import "PPSmartUpdateData.h"
#import "PPSmartUpdateDataUtils.h"

@interface GameConfigData()
{
    PPSmartUpdateData*  _smartData;
}

@end

@implementation GameConfigData

- (id)initWithName:(NSString*)bundleName
{
    self = [super init];
    
    // init smart data here and set config data here
    NSString* versionFileName = [PPSmartUpdateDataUtils getVersionFileName:bundleName];
    NSString* versionFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:versionFileName];
    NSError* error = nil;
    NSString* version = [NSString stringWithContentsOfFile:versionFilePath encoding:NSUTF8StringEncoding error:&error];
    if (version == nil || error != nil){
        PPDebug(@"[WARN] Init config data %@ but version file not found!!!", bundleName);
    }
    
    _smartData = [[PPSmartUpdateData alloc] initWithName:bundleName
                                                    type:SMART_UPDATE_DATA_TYPE_PB
                                              bundlePath:bundleName
                                         initDataVersion:version];
    
    // read data from file
    [self readConfigData];    
    return self;
}

- (void)dealloc
{
    [_config release];
    [_smartData release];
    [super dealloc];
}

- (void)readConfigData
{
    NSString* dataPath = [_smartData dataFilePath];
    @try {
        NSData* data = [NSData dataWithContentsOfFile:dataPath];
        if (data != nil){
            self.config = [PBConfig parseFromData:data];
            PPDebug(@"<readConfigData> parse config data %@ successfully", _smartData.name);
            PPDebug(@"test value = %d", _config.diceConfig.betAnteHighRoom);
        }
        else{
            PPDebug(@"[WARN] Init config data %@ data file empty", dataPath);
        }
    }
    @catch (NSException *exception) {
        PPDebug(@"[ERROR] Fail to read/parse %@ config data from path %@", _smartData.name, dataPath);
        self.config = nil;
    }
    @finally {
    }
}

- (void)autoUpdate
{
    [_smartData checkUpdateAndDownload:^(BOOL isAlreadyExisted, NSString *dataFilePath) {
        if (!isAlreadyExisted){
            [self readConfigData];
        }
    } failureBlock:^(NSError *error) {
        PPDebug(@"<autoUpdate> failure due to error(%@)", [error description]);
    }];
}



@end
