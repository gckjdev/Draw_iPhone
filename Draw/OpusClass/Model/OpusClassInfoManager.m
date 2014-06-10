//
//  OpusClassInfoManager.m
//  Draw
//
//  Created by qqn_pipi on 14-6-5.
//
//

#import "OpusClassInfoManager.h"
#import "PPSmartUpdateData.h"
#import "JSON.h"
#import "OpusClassInfo.h"

static OpusClassInfoManager* _defaultOpusClassInfoManager;

@implementation OpusClassInfoManager

+ (OpusClassInfoManager*)defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultOpusClassInfoManager = [[OpusClassInfoManager alloc] init];
    });
    
    return _defaultOpusClassInfoManager;
}

- (id)init
{
    self = [super init];
    [self loadData:[OpusClassInfoManager appTaskDefaultConfigFileName]];
    return self;
}

+ (NSString*)appTaskDefaultConfigFileName
{
    return @"opusclass.json";
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
                                                    type:SMART_UPDATE_DATA_TYPE_TXT
                                              bundlePath:bundleName
                                         initDataVersion:version];
    
    _opusClassList = [[NSMutableArray alloc] init];
    
    // read data from file
    [self readConfigData];
    return;
}

- (void)dealloc
{
    [_smartData release];
    [super dealloc];
}

- (OpusClassInfo*)getOpusClassInfoById:(NSString*)classId inList:(NSArray*)opusInfoArray
{
    if ([classId length] == 0 || [opusInfoArray count] == 0){
        return nil;
    }
    
    for (OpusClassInfo* classInfo in opusInfoArray){
        if ([[classInfo classId] isEqualToString:classId]){
            return classInfo;
        }
    }
    
    return nil;
}

- (void)setParentAndSubclass:(NSMutableArray*)classList
{
    NSArray* list = classList;
    for (OpusClassInfo* classInfo in classList){

        [classInfo clearSubClasses];
        
        // add sub class
        NSArray* subClasses = classInfo.pbOpusClassBuilder.subClassesList;
        for (int i=0; i<subClasses.count; i++){
            PBClass* subClass = [subClasses objectAtIndex:i];
            OpusClassInfo* subClassFound = [self getOpusClassInfoById:subClass.classId inList:list];
            if (subClassFound){
                [classInfo.subClassList addObject:subClassFound];
                PPDebug(@"add sub class %@ for class %@", subClassFound.classId, classInfo.classId);
            }
        }

        // set parent class
        OpusClassInfo* parentClassFound = [self getOpusClassInfoById:classInfo.pbOpusClassBuilder.parentClass.classId inList:list];
        if (parentClassFound){
            [classInfo setParentClassInfo:parentClassFound];
            PPDebug(@"set parent class %@ for class %@", parentClassFound.classId, classInfo.classId);
        }
    }
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
            [self.opusClassList removeAllObjects];
        }
        
        if (data != nil){
            
            data = [data stringByReplacingOccurrencesOfString:@"\t" withString:@""];
            data = [data stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            
            NSArray* jsonArray = [data JSONValue];
            for (NSDictionary* dict in jsonArray){
                OpusClassInfo* classInfo = [OpusClassInfo objectWithDictionary:dict];
                if (classInfo){
                    [_opusClassList addObject:classInfo];
                }
            }
            
            [self setParentAndSubclass:_opusClassList];
            
            PPDebug(@"<readConfigData> parse data %@ successfully, total %d opus classes added", _smartData.name, [_opusClassList count]);
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
