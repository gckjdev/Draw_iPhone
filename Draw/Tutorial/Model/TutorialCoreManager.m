//
//  TutorialCoreManager.m
//  Draw
//
//  Created by qqn_pipi on 14-6-26.
//
//

#import "TutorialCoreManager.h"

@interface TutorialCoreManager()

@property (nonatomic, retain) PPSmartUpdateData* smartData;
@property (nonatomic, retain) NSMutableArray* tutorialList;

@end

static TutorialCoreManager* _defaultTutorialCoreManager;

@implementation TutorialCoreManager

+ (TutorialCoreManager*)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultTutorialCoreManager = [[TutorialCoreManager alloc] init];
    });
    
    return _defaultTutorialCoreManager;
}

- (id)init
{
    self = [super init];
    [self loadData:[TutorialCoreManager appTaskDefaultConfigFileName]];
    return self;
}

+ (NSString*)appTaskDefaultConfigFileName
{
    return @"tutorial_core.pb";
    //    NSString* config = [NSString stringWithFormat:@"opus_class.json", [GameApp appId]];
    //    PPDebug(@"appTaskConfigFileName:%@", config);
    //    return config;
}

- (void)loadData:(NSString*)bundleName
{
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
    return;
}

- (void)dealloc
{
    PPRelease(_tutorialList);
    PPRelease(_smartData);
    [super dealloc];
}

- (void)readConfigData
{
    if (_tutorialList == nil){
        _tutorialList = [[NSMutableArray alloc] init];
    }
    
    NSString* dataPath = [_smartData dataFilePath];
    @try {
        NSError* error = nil;
        NSString* data = [NSString stringWithContentsOfFile:dataPath encoding:NSUTF8StringEncoding error:&error];
        if (error != nil){
            PPDebug(@"<readConfigData> but error=%@", [error description]);
        }
        else{
        }
        
        if (data != nil){
            [_tutorialList removeAllObjects];
        }
        else{
            PPDebug(@"[WARN] Init config data %@ data file empty", dataPath);
        }
    }
    @catch (NSException *exception) {
        PPDebug(@"[ERROR] Fail to read/parse %@ config data from path %@", _smartData.name, dataPath);
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

- (NSArray*)allTutorials
{
    if (self.tutorialList != nil){
        return self.tutorialList;
    }
    
    [self readConfigData];
    return self.tutorialList;
}

- (void)cleanData
{
    self.tutorialList = nil;
}

@end
