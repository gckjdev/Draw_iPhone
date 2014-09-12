//
//  TutorialProtoManager.m
//  Draw
//
//  Created by ChaoSo on 14-9-11.
//
//

#import "TutorialProtoManager.h"
#import "TutorialProtoModel.h"
#import "PPSmartUpdateData.h"
#import "JSON.h"

static TutorialProtoManager* _defaultTutorialProtoManager;

#define TUTORIAL_IMAGE_DIR     @"tutorial_image"
@implementation TutorialProtoManager

+ (TutorialProtoManager*)defaultManager
{
    static dispatch_once_t bbOnceToken;
    dispatch_once(&bbOnceToken, ^{
        _defaultTutorialProtoManager = [[TutorialProtoManager alloc] init];
    });
    
    return _defaultTutorialProtoManager;
}

- (id)init
{
    //super
    self = [super init];
    
    self.tutorialList = [NSMutableArray array];
    self.imageManager = [[[StorageManager alloc] initWithStoreType:StorageTypePersistent
                                                     directoryName:TUTORIAL_IMAGE_DIR] autorelease];
    [self loadData:[TutorialProtoManager defaultConfigFileName]];
    return self;
}

+ (NSString*)defaultConfigFileName
{
    return @"tutorialList.json";
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
    
    self.tutorialList = [[[NSMutableArray alloc] init] autorelease];
    
    // read data from file
    [self readConfigData];
    return;
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
        
        if (data != nil){
            
            data = [data stringByReplacingOccurrencesOfString:@"\t" withString:@""];
            data = [data stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            
            NSArray* jsonArray = [[data JSONValue] objectForKey:@"tutorial_list"];
            [self.tutorialList removeAllObjects];
            
            if ([jsonArray count] > 0){
                for (NSDictionary* dict in jsonArray){
                    TutorialProtoModel* tutorial = [TutorialProtoModel objectWithDictionary:dict];
                    if (tutorial){
                        [self.tutorialList addObject:tutorial];
                    }
                }
                
                PPDebug(@"<readConfigData> parse data %@ successfully, total %d opus classes added", _smartData.name, [self.tutorialList count]);
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

- (void)dealloc
{
    PPRelease(_tutorialList);
    PPRelease(_smartData);
    [super dealloc];
}



@end
