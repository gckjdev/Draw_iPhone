//
//  BillboardManager.m
//  Draw
//
//  Created by ChaoSo on 14-7-16.
//
//

#import "BillboardManager.h"
#import "PPSmartUpdateData.h"
#import "JSON.h"
#import "Billboard.h"

static BillboardManager* _defaultBillboardManager;

@implementation BillboardManager

+ (BillboardManager*)defaultManager
{
    static dispatch_once_t bbOnceToken;
    dispatch_once(&bbOnceToken, ^{
        _defaultBillboardManager = [[BillboardManager alloc] init];
    });
    
    return _defaultBillboardManager;
}

- (id)init
{
    self = [super init];
    self.bbList = [NSMutableArray array];
    [self loadData:[BillboardManager defaultConfigFileName]];
    return self;
}

+ (NSString*)defaultConfigFileName
{
    return @"home_bb.json";
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
    
    self.bbList = [[[NSMutableArray alloc] init] autorelease];

    // read data from file
    [self readConfigData];
    return;
}

- (void)dealloc
{
    PPRelease(_bbList);
    PPRelease(_smartData);
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
            [self.bbList removeAllObjects];
        }
        
        if (data != nil){
            
            data = [data stringByReplacingOccurrencesOfString:@"\t" withString:@""];
            data = [data stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            
            NSArray* jsonArray = [[data JSONValue] objectForKey:@"bb_list"];
            if ([jsonArray count] > 0){
                for (NSDictionary* dict in jsonArray){
                    Billboard* bb = [Billboard objectWithDictionary:dict];
                    if (bb){
                        [_bbList addObject:bb];
                    }
                }
                
                PPDebug(@"<readConfigData> parse data %@ successfully, total %d opus classes added", _smartData.name, [_bbList count]);
            }
            else{
                PPDebug(@"<readConfigData> parse JSON data %@ error", _smartData.name);
            }
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
        PPDebug(@"<autoUpdate> update billboard failure due to error(%@)", [error description]);
    }];
}

@end
