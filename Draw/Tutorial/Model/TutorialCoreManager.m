//
//  TutorialCoreManager.m
//  Draw
//
//  Created by qqn_pipi on 14-6-26.
//
//

#import "TutorialCoreManager.h"
#import "Tutorial.pb.h"

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
        
        NSData* data = [NSData dataWithContentsOfFile:dataPath];
        if (data != nil){
            
            PBTutorialCore* core = [PBTutorialCore parseFromData:data];
            if (core != nil && core.tutorialsList != nil){
                [_tutorialList removeAllObjects];
                [_tutorialList addObjectsFromArray:core.tutorialsList];
            }
            PPDebug(@"<readConfigData> parse config data %@ successfully, total %d added", _smartData.name, [core.tutorialsList count]);
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



// 创建测试数据
- (void)createTestData
{
//    NSString* root = @"/gitdata/Draw_iPhone/Draw/CommonResource/Config/";
    NSString* root = @"/Users/chaoso/Desktop/gitdata/Draw_iPhone/Draw/Tutorial/Resource/";
    NSString* path = [root stringByAppendingString:[TutorialCoreManager appTaskDefaultConfigFileName]];
    NSString* versionPath = [root stringByAppendingString:[PPSmartUpdateDataUtils getVersionFileName:[TutorialCoreManager appTaskDefaultConfigFileName]]];
    
    PBTutorialCore_Builder* builder = [PBTutorialCore builder];
    
    
    // TODO add test tutorials
    
    //测试数据
    for (int i=0; i<10; i++){
        PBTutorial_Builder* tb = [PBTutorial builder];
        NSString* name = [NSString stringWithFormat:@"教程[%d]", i];
        NSString* tutorialId = [NSString stringWithFormat:@"id-%d", i];
        NSString* desc = [NSString stringWithFormat:@"这是一个教程--%d",i];
        [tb setCnDesc:desc];
        [tb setCnName:name];
        [tb setTutorialId:tutorialId];
        //默认的小图片
        NSString* urlString = @"http://ww1.sinaimg.cn/bmiddle/94a7a958jw1ehzjdqx7fij20c80850tc.jpg";
        [tb setThumbImage:urlString];
        [tb setImage:urlString];
        
        
        //生成stage
        NSMutableArray* stageList = [NSMutableArray array];
        for(int j=0;j<10;j++){
        
            PBStage_Builder* stage = [PBStage builder];
            NSString* name2 = [NSString stringWithFormat:@"关卡[%d]",j];
            NSString* desc2 = [NSString stringWithFormat:@"我是一个关卡---%d",j];

            [stage setStageId:[NSString stringWithFormat: @"stage-%d",j]];
            [stage setCnName:name2];
            [stage setCnDesc:desc2];
            //默认的小图片
            NSString* urlString2 = @"http://ww2.sinaimg.cn/bmiddle/bf9e8c17jw1ehya0z14p1j20e708gweu.jpg";
            [stage setThumbImage:urlString2];
            [stage setImage:urlString2];
            [stageList addObject:[stage build]];
        }
        
        [tb addAllStages:stageList];
        
        PBTutorial* tutorial = [tb build];
        [builder addTutorials:tutorial];
    }
    
    
    
    PBTutorialCore* core = [builder build];
    NSData* data = [core data];
//    NSData* data = [test data];
    
    BOOL result = [data writeToFile:path atomically:YES];
    PPDebug(@"<createTestData> data file result=%d, file=%@", result, path);
    
    NSString* version = @"1.1";
    NSError* error = nil;
    result = [version writeToFile:versionPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    PPDebug(@"<createTestData> version txt file result=%d error=%@ file=%@", result, [error description], versionPath);
}

@end
