//
//  AppTaskManager.m
//  Draw
//
//  Created by qqn_pipi on 13-11-25.
//
//

#import "AppTaskManager.h"
#import "AppTask.h"
#import "PPSmartUpdateData.h"
#import "JSON.h"

static AppTaskManager* _defaultAppTaskManager;

@implementation AppTaskManager

+ (AppTaskManager*)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultAppTaskManager = [[AppTaskManager alloc] init];
    });
    
    return _defaultAppTaskManager;
}

- (id)init
{
    self = [super init];
    [self loadData:[AppTaskManager appTaskDefaultConfigFileName]];
    return self;
}


+ (NSString*)appTaskDefaultConfigFileName
{    
    NSString* config = [NSString stringWithFormat:@"%@_app_task.json", [GameApp appId]];
    PPDebug(@"appTaskConfigFileName:%@", config);
    return config;
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
                                                    type:SMART_UPDATE_DATA_TYPE_TXT
                                              bundlePath:bundleName
                                         initDataVersion:version];
    
    _taskList = [[NSMutableArray alloc] init];
    
    // read data from file
    [self readConfigData];
    return;
}

- (void)dealloc
{
    [_taskList release];
    [_smartData release];
    [super dealloc];
}

- (void)readConfigData
{
    NSString* dataPath = [_smartData dataFilePath];
    @try {
        NSError* error = nil;
        NSString* data = [NSString stringWithContentsOfFile:dataPath encoding:NSUTF8StringEncoding error:&error];
        if (error != nil){
            PPDebug(@"<readConfigData> but error=%@", [error description]);
        }
        else{
            [self.taskList removeAllObjects];
        }
        
        if (data != nil){
            
            data = [data stringByReplacingOccurrencesOfString:@"\t" withString:@""];
            data = [data stringByReplacingOccurrencesOfString:@"\n" withString:@""];
//            data = [data stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            NSArray* jsonArray = [data JSONValue];
            for (NSDictionary* dict in jsonArray){
                AppTask* task = [AppTask objectWithDictionary:dict];
                if (task){
                    [_taskList addObject:task];
                }
            }
            
            PPDebug(@"<readConfigData> parse data %@ successfully, total %d task added", _smartData.name, [_taskList count]);
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


@end
