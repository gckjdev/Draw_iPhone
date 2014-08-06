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
    self.userDisplayClassList = [NSMutableArray array];
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
    
    self.opusClassList = [[[NSMutableArray alloc] init] autorelease];
    self.homeDisplayClassList = [[[NSMutableArray alloc] init] autorelease];
    self.defaultUserSetList = [[[NSMutableArray alloc] init] autorelease];
    
    // read data from file
    [self readConfigData];
    return;
}

- (void)dealloc
{
    PPRelease(_defaultUserSetList);
    PPRelease(_homeDisplayClassList);
    PPRelease(_opusClassList);
    PPRelease(_smartData);
    PPRelease(_userDisplayClassList);
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

- (void)writeList:(NSMutableArray*)sourceList dest:(NSMutableArray*)destList fromDictionary:(NSDictionary*)dictionary forKey:(NSString*)key
{
    [destList removeAllObjects];
    NSArray* stringList = [dictionary objectForKey:key];
    for (NSString* classId in stringList){
        OpusClassInfo* info = [self getOpusClassInfoById:classId inList:sourceList];
        if (info){
            [destList addObject:info];
        }
    }
    PPDebug(@"total %d classes added for key(%@)", [destList count], key);
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
            
            NSArray* jsonArray = [[data JSONValue] objectForKey:@"class_list"];
            if ([jsonArray count] > 0){
                for (NSDictionary* dict in jsonArray){
                    OpusClassInfo* classInfo = [OpusClassInfo objectWithDictionary:dict];
                    if (classInfo){
                        [_opusClassList addObject:classInfo];
                    }
                }
                
                [self setParentAndSubclass:_opusClassList];
                
                PPDebug(@"<readConfigData> parse data %@ successfully, total %d opus classes added", _smartData.name, [_opusClassList count]);
                
//                [self.homeDisplayClassList removeAllObjects];
//                NSArray* displayStringList = [[data JSONValue] objectForKey:@"home_list"];
//                for (NSString* classId in displayStringList){
//                    OpusClassInfo* info = [self getOpusClassInfoById:classId inList:self.opusClassList];
//                    if (info){
//                        [self.homeDisplayClassList addObject:info];
//                    }
//                }
//                PPDebug(@"total %d opus home display classes added", [_homeDisplayClassList count]);

                NSDictionary* dict = [data JSONValue];
                
                // read home display
                [self writeList:self.opusClassList
                           dest:self.homeDisplayClassList
                 fromDictionary:dict
                         forKey:@"home_list"];
                
                // init default user set
                [self writeList:self.opusClassList
                           dest:self.defaultUserSetList
                 fromDictionary:dict
                         forKey:@"user_set_list"];
                
                [self loadUserDisplayList];
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
        PPDebug(@"<autoUpdate> failure due to error(%@)", [error description]);
    }];
}

- (NSString*)userDisplayListKey
{
    return @"USER_DISPLAY_OPUS_CLASS_KEY";
}

- (void)saveUserDisplayList:(NSArray*)opusInfoClassList
{
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    NSMutableArray* list = [NSMutableArray array];
    for (OpusClassInfo* opusClassInfo in opusInfoClassList){
        if (opusClassInfo.classId){
            [list addObject:opusClassInfo.classId];
        }
    }
    [ud setObject:list forKey:[self userDisplayListKey]];
    [ud synchronize];
    
    if (opusInfoClassList){
        [self.userDisplayClassList removeAllObjects];
        [self.userDisplayClassList addObjectsFromArray:opusInfoClassList];
    }
}

- (void)loadUserDisplayList
{
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    NSArray* list = [ud objectForKey:[self userDisplayListKey]];
    if (list){
        [self.userDisplayClassList removeAllObjects];
        for (NSString* classId in list){
            OpusClassInfo* info = [self getOpusClassInfoById:classId inList:self.opusClassList];
            if (info){
                [self.userDisplayClassList addObject:info];
                PPDebug(@"<loadUserDisplayList> add %@,%@", info.classId, info.name);
            }
        }
    }
    else{
        // use default
        [self.userDisplayClassList removeAllObjects];
        [self.userDisplayClassList addObjectsFromArray:self.homeDisplayClassList];
        PPDebug(@"<loadUserDisplayList> use default");
    }
}

- (OpusClassInfo*)findOpusClassInfo:(NSString*)opusClassId
{
    if ([opusClassId length] == 0){
        return nil;
    }
    
    for (OpusClassInfo* opusClassInfo in _opusClassList){
        if ([opusClassInfo.classId isEqualToString:opusClassId]){
            return opusClassInfo;
        }
    }
    
    return nil;
}

@end
