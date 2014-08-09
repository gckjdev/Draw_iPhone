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
@property (nonatomic ,retain) NSMutableArray* stepByStepTutorialIdList;
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
                
                //chaoso 2014-07-17
                [_stepByStepTutorialIdList removeAllObjects];
                [_stepByStepTutorialIdList addObjectsFromArray:core.stepByStepTutorialIdList];
                
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
//重写TutorialBuilder
-(PBTutorial *) evaluateTutorialpbName:(NSString *)name WithDesc:(NSString *)desc WithTutorialId:(NSString *)tutorialId WithImage:(NSString *)imageUrl WithCategory:(NSArray *)categoryList WithStage:(NSArray*)stageList{
    
    PBTutorial_Builder* tb = [PBTutorial builder];
    
    //required
    [tb setTutorialId:tutorialId];
    
    //optional
    [tb setCnName:name];
    
    [tb setCnDesc:desc];
    
    [tb setThumbImage:imageUrl];
    [tb setImage:imageUrl];
    
    //repeat
    //难度
    [tb addAllCategories:categoryList];
    //stage
    [tb addAllStages:stageList];
    return [tb build];
}



//重写Stage
-(PBStage*) evaluateStageDataName:(NSString *)name WithDesc:(NSString *)desc WithStageId:(NSString *)stageId WithImage:(NSString *)imageUrl tipList:(NSArray*)tipsList tipsIndex:(int32_t)tipsIndex opusId:(NSString*)opusId chapterList:(NSArray*)chapterList difficulty:(Float32)difficult stageType:(int)stageType{
    
    PBStage_Builder* stageBuilder = [PBStage builder];
    //required
    [stageBuilder setStageId:stageId];
    
    //optional
    [stageBuilder setCnName:name];
    [stageBuilder setEnName:name];
    [stageBuilder setCnDesc:desc];
    [stageBuilder setEnDesc:desc];
    [stageBuilder setStageId:stageId];
    [stageBuilder setThumbImage:imageUrl];
    [stageBuilder setImage:imageUrl];
    [stageBuilder setImageName:@"image.jpg"];                 // image for compare
    [stageBuilder setBgImageName:@"bg_image.png"];            // image for background
    [stageBuilder setOpusName:@"data"];                       // opus data file name
    [stageBuilder setOpusId:opusId];
    if(difficult!=-1){
        [stageBuilder setDifficulty:difficult];
    }
    [stageBuilder setScoreEngine:stageType];
    PPDebug(@"<scoreenginetype> scoreEngineType:%d, stageID:%@", stageType, stageId);
    
    
    //repeated
    [stageBuilder addAllChapter:chapterList];
    
    return [stageBuilder build];
}

//重写Chapter
-(PBChapter *) evalueteChapterDataChapterIndex:(int32_t)chapterIndex tipList:(NSArray*)tipsList chapterStart:(NSArray *)statIdex endIndex:(NSArray *)endIndex{
    PBChapter_Builder *pbChapterBuilder = [PBChapter builder];
    //required
    [pbChapterBuilder setIndex:chapterIndex];
    //optional
    [pbChapterBuilder setImageName:@"image.jpg"];
    // add tips image
    if(tipsList!=nil&&[tipsList count]!=0){
        [pbChapterBuilder addAllTips:tipsList];
    }
    
    
    if(statIdex!=nil&&endIndex!=nil&&statIdex.count!=0&&endIndex.count!=0){
        if(chapterIndex==0){
            [pbChapterBuilder setStartIndex:0];
        }else{
            [pbChapterBuilder setStartIndex:[[statIdex objectAtIndex:chapterIndex-1] intValue]];
        }
        [pbChapterBuilder setEndIndex:[[endIndex objectAtIndex:chapterIndex] intValue]];
    }
    return [pbChapterBuilder build];
}

-(PBTip *) evalueteTipsDataName:(NSString *)tipsName WithIndex:(int32_t)tipsIndex{
    PBTip_Builder *tipBuilder = [PBTip builder];
    [tipBuilder setIndex:tipsIndex];
    PPDebug(@"tipsName =====%@",tipsName);
    [tipBuilder setImageName:tipsName];
    return [tipBuilder build];
}

//赋值PBTutorial_Builder
-(PBTutorial_Builder *) evaluateTutorialTestDataName:(NSString *)name WithDesc:(NSString *)desc WithTutorialId:(NSString *)tutorialId WithImage:(NSString *)imageUrl IsAdd:(BOOL)isAdd WithBuilder:(PBTutorialCore_Builder *)builder WithCategory:(NSArray *)categoryList
{
    PBTutorial_Builder* tb = [PBTutorial builder];
    [tb setCnName:name];
    [tb setCnDesc:desc];
    [tb setTutorialId:tutorialId];
    [tb setThumbImage:imageUrl];
    [tb setImage:imageUrl];
    [tb addAllCategories:categoryList];
    if(isAdd){
        if(builder!=nil){
            PBTutorial* tutorial = [tb build];
            [builder addTutorials:tutorial];
        }
    }
    return tb;
}

//赋值PBStage_Builder
-(void)evaluateStageTestDataName:(NSString *)name WithDesc:(NSString *)desc WithStageId:(NSString *)stageId WithImage:(NSString *)imageUrl WithTutorial:(PBTutorial_Builder*)  WithChapterList:(NSArray*)chapterList WithChapterIndex:(int32_t)chapterIndex tipList:(NSArray*)tipsList tipsIndex:(int32_t)tipsIndex{
    
    PBStage_Builder* pb = [PBStage builder];
    PBChapter_Builder* pbChapterBuilder = [PBChapter builder];
    
    [pb setCnName:name];
    [pb setCnDesc:desc];
    [pb setStageId:stageId];
    [pb setThumbImage:imageUrl];
    [pb setImage:imageUrl];
    
    [pb setImageName:@"image.jpg"];                 // image for compare
    [pb setBgImage:@"bg_image.png"];                // image for background
    [pb setOpusName:@"data"];                       // opus data file name
    [pb setOpusId:[chapterList objectAtIndex:0]];   // opus ID
    
    [pbChapterBuilder setOpusId:[chapterList objectAtIndex:0]];
    [pbChapterBuilder setIndex:chapterIndex];
    [pbChapterBuilder setImageName:@"image.jpg"];
    
    
    
    // add tips image
    
    NSArray *list = [tipsList objectAtIndex:tipsIndex];
    if([list count]>0){
        for(int j=0;j<[list count];j++){
            
            PBTip_Builder* pbTipsBuilder = [PBTip builder];
            NSString *name = [list objectAtIndex:j];
            [pbTipsBuilder setIndex:j];
            [pbTipsBuilder setImageName:name];
            PBTip *tips = [pbTipsBuilder build];
            [pbChapterBuilder addTips:tips];
        }
        
    }
    
    
    
    PBChapter* chapter = [pbChapterBuilder build];
    
    [pb addChapter:chapter];
    //    PBStage* stage = [pb build];
    
}

-(PBTutorial*)findTutorialByTutorialId:(NSString*)tutorialId
{
    if ([tutorialId length] == 0){
        return nil;
    }
    
    NSArray* all = [[TutorialCoreManager defaultManager] allTutorials];
    for (PBTutorial* tutorial in all){
        if ([tutorial.tutorialId isEqualToString:tutorialId]){
            return tutorial;
        }
    }
    
    return nil;
}

- (PBTutorial*)findTutorialByUserTutorialId:(PBUserTutorial*)userTutorial
{
    if (userTutorial==nil){
        return nil;
    }
    
    NSString* userTutorialId = userTutorial.tutorial.tutorialId;
    NSArray* all = [[TutorialCoreManager defaultManager] allTutorials];
    for (PBTutorial* pbTutorial in all){
        if ([pbTutorial.tutorialId isEqualToString:userTutorialId]){
            return pbTutorial;
        }
    }
    
    return nil;
}


//取得tipsInChapter count
-(NSArray *)getTipsInChapterCountTutorialIndex:(int)tutorialIndex stageIndex:(int)stageInedx chapterIndex:(int)chapterIndex list:(NSArray*)list{
    
    NSArray *tutorialTips = [list objectAtIndex:tutorialIndex];
    if(tutorialTips==nil||[tutorialTips count]==0){
        return nil;
    }
    NSArray *stageTips = [tutorialTips  objectAtIndex:stageInedx];
    if(stageTips==nil||[stageTips count]==0){
        return nil;
    }
    NSArray *chapterTips = [stageTips objectAtIndex:chapterIndex];
    if(chapterTips==nil||[chapterTips count]==0){
        return nil;
    }
    return chapterTips;
}

// 创建测试数据
- (void)createTestData
{
    //    NSString* root = @"/gitdata/Draw_iPhone/Draw/Tutorial/Resource/";
    NSString* root = @"/Users/chaoso/Desktop/gitdata/Draw_iPhone/Draw/Tutorial/Resource/";
    //    NSString *root = @"/Users/Linruin/gitdata/Draw_iPhone/Draw/Tutorial/Resource/";
//    NSString *root = @"/Users/jiandan/gitdata/Draw_iPhone/Draw/Tutorial/Resource/";
    NSString* path = [root stringByAppendingString:[TutorialCoreManager appTaskDefaultConfigFileName]];
    
    //    NSString* versionPath = [root stringByAppendingString:[PPSmartUpdateDataUtils getVersionFileName:[TutorialCoreManager appTaskDefaultConfigFileName]]];
    
    PBTutorialCore_Builder* builder = [PBTutorialCore builder];
    
    
    // TODO add test tutorials
    
    
    NSArray* testTutorialName = @[@"初识三次元",
                                  /*@"疯狂的线条",@"识色配图",@"旺星人大集合",@"易容速成",*/@"百态小吉萌翻天",@"爱生活爱运动",@"名建筑大集合",@"一起来运动"];
    
    NSArray* testTutorialDesc = @[@"教你怎么把物体从二次元转换成三次元",/*@"帮助你更好的熟练工具",@"这里将把你打造成用色达人",@"属于旺星人的趴",@"你想易容成什么人",*/@"小吉闪亮登场，速来围观",@"童鞋们，一起来运动吧",@"你认识这些建筑吗？",@"燃烧你的卡路里吧"];
    
    
    NSArray* tutorialImageUrl = @[@"http://58.215.160.100:8080/app_res/tutorial/image/title-0.png",
                                  //                                  @"http://58.215.184.18:8080/tutorial/image/2-titlenew.png",
                                  //                                  @"http://58.215.184.18:8080/tutorial/image/3-titlenew.png",
                                  //                                  @"http://58.215.184.18:8080/tutorial/image/4-titlenew.png",
                                  //                                  @"http://58.215.184.18:8080/tutorial/image/5-titlenew.png",
                                  //                                  @"http://58.215.184.18:8080/tutorial/image/6-titlenew.png",
                                  @"http://58.215.160.100:8080/app_res/tutorial/image/title-6.png",
                                  @"http://58.215.160.100:8080/app_res/tutorial/image/title-7.png",
                                  @"http://58.215.160.100:8080/app_res/tutorial/image/title-8.png",
                                  @"http://58.215.160.100:8080/app_res/tutorial/image/title-4.png"
                                  ];
    NSArray* tutorialCategory =
    @[
      @[@(2)],
      //                                  @[@(0)],
      //                                  @[@(1)],
      //                                  @[@(0)],
      //                                  @[@(0)],
      //                                  @[@(1)],
      @[@(0)],
      @[@(0)],
      @[@(0)],
      @[@(1)]
      ];
    
    NSArray* testStageName = @[
                               
                               @[@"正方体",@"牛奶盒",@"六棱柱",@"铅笔",@"圆柱",@"纸筒", @"苹果"],
                               //                               @[@"整齐的直线",@"横纵直线",@"巧画直线条",@"很浪的波浪线",@"巧画波浪线",@"几何形", @"圈圈君",@"实践测试"],
                               //                               @[@"十二色环",@"二十四色环",@"互补色色环",@"渐变色",@"经典互补色",@"渐变构成", @"冷暖对比",@"同色系渐变构成"],
                               //                               @[@"比熊先生",@"博美小姐",@"马尔济斯绅士",@"哈士奇骑士",@"约克夏伯爵",@"吉娃娃公主", @"泰迪女王",@"萨摩王子"],
                               //                               @[@"花样滑冰",@"艺术体操",@"赛马",@"高尔夫",@"体操",@"击剑",@"滑雪",@"足球"],
                               //                               @[@"美少女奈儿",@"美少女纪子",@"小妹妹",@"帅哥",@"小毛孩",@"经理",@"妇女",@"老者"],
                               @[@"放松",@"微笑",@"惊恐",@"鄙视",@"纠结",@"开心",@"奸笑",@"无奈",@"享受",@"可爱"],
                               @[@"射箭",@"拳击",@"铁人三项",@"跆拳道",@"射击",@"棒球",@"游泳",@"跳水",@"皮划艇",@"柔道"],
                               @[@"埃及金字塔",@"埃菲尔铁塔",@"赵州桥",@"卢浮宫艺术馆",@"古希腊神庙",@"美国白宫",@"雷峰塔",@"江南小镇"],
                               @[@"花样滑冰",@"艺术体操",@"赛马",@"高尔夫",@"体操",@"击剑",@"滑雪",@"足球"],
                               ];
    
    NSArray* testStageDesc = @[@[@"初步认识传说中的五调子（亮、灰、暗、反光、投影）",@"学会了正方体，现在你可以尝试画下生活中类似的物体",@"怎样把物体画的更有立体感",@"结合前面的六棱柱，试试画一只铅笔",@"学习怎么让物体的明暗过渡的更加自然",@"运用前面学习的知识，试着画一个圆柱形纸筒", @"你是我的小呀小苹果······综合所学知识画个最流行的小苹果吧"],
                               //                               @[@"整齐的直线",@"横纵直线",@"巧画直线条",@"很浪的波浪线",@"巧画波浪线",@"几何形", @"圈圈君",@"实践测试"],
                               //                               @[@"十二色环",@"二十四色环",@"互补色色环",@"渐变色",@"经典互补色",@"渐变构成", @"冷暖对比",@"同色系渐变构成"],
                               //                               @[@"比熊先生",@"博美小姐",@"马尔济斯绅士",@"哈士奇骑士",@"约克夏伯爵",@"吉娃娃公主", @"泰迪女王",@"萨摩王子"],
                               //                               @[@"没有翅膀也一样可以飞翔",@"展现身体的柔性美",@"人与动物最佳拍档",@"在运动中享受大自然的乐趣",@"干净利落的身姿",@"协调性与灵活性的考验",@"像鸟一样在雪地里飞舞",@"只为射门那一刻的欢呼"],
                               //                               @[@"美少女奈儿",@"美少女纪子",@"小妹妹",@"帅哥",@"小毛孩",@"经理",@"妇女",@"老者"],
                               @[@"终于下课了",@"做好事受表扬",@"上厕所忘记带纸",@"看见行人闯红灯",@"我到底是男还是女",@"作品上榜了",@"想到坏点子",@"澡堂洗澡肥皂掉地上",@"雪地泡温泉",@"和帅哥打招呼"],
                               @[@"后羿射日，弓开得胜",@"一秒钟变猪头",@"游、跑、骑三部曲",@"再也不怕色狼了",@"要不要再来一发",@"米国人四大运动之一",@"旱鸭子一边去",@"森碟老爸是冠军",@"你的手臂够粗吗",@"据说是小孩子把戏"],
                               @[@"听说法老躺这里",@"土豪玩浪漫的约会圣地",@"没有比TA更老的古桥了",@"亮瞎你眼睛的玻璃建筑",@"住着美女雅典娜",@"爱爸妈发号施令的基地",@"法海不懂爱",@"文艺小资青年的挚爱"],
                               @[@"没有翅膀也一样可以飞翔",@"展现身体的柔性美",@"人与动物最佳拍档",@"在运动中享受大自然的乐趣",@"干净利落的身姿",@"协调性与灵活性的考验",@"像鸟一样在雪地里飞舞",@"只为射门那一刻的欢呼"]
                               ];
    
    NSArray* stageImageUrl = @[
                               @[
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/0-2.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/0-1.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/0-3.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/0-4.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/0-5.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/0-6.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/0-7.jpg"
                                   ],
                               /* @[
                                @"http://58.215.184.18:8080/tutorial/image/2-1.png",
                                @"http://58.215.184.18:8080/tutorial/image/2-2.png",
                                @"http://58.215.184.18:8080/tutorial/image/2-3.png",
                                @"http://58.215.184.18:8080/tutorial/image/2-4.png",
                                @"http://58.215.184.18:8080/tutorial/image/2-5.png",
                                @"http://58.215.184.18:8080/tutorial/image/2-6.png",
                                @"http://58.215.184.18:8080/tutorial/image/2-7.png",
                                @"http://58.215.184.18:8080/tutorial/image/2-8.png"
                                ],
                                @[
                                @"http://58.215.184.18:8080/tutorial/image/3-1.png",
                                @"http://58.215.184.18:8080/tutorial/image/3-2.png",
                                @"http://58.215.184.18:8080/tutorial/image/3-3.png",
                                @"http://58.215.184.18:8080/tutorial/image/3-4.png",
                                @"http://58.215.184.18:8080/tutorial/image/3-5.png",
                                @"http://58.215.184.18:8080/tutorial/image/3-6.png",
                                @"http://58.215.184.18:8080/tutorial/image/3-7.png",
                                @"http://58.215.184.18:8080/tutorial/image/3-8.png"
                                ],
                                @[
                                @"http://58.215.184.18:8080/tutorial/image/4-1.png",
                                @"http://58.215.184.18:8080/tutorial/image/4-2.png",
                                @"http://58.215.184.18:8080/tutorial/image/4-3.png",
                                @"http://58.215.184.18:8080/tutorial/image/4-4.png",
                                @"http://58.215.184.18:8080/tutorial/image/4-5.png",
                                @"http://58.215.184.18:8080/tutorial/image/4-6.png",
                                @"http://58.215.184.18:8080/tutorial/image/4-7.png",
                                @"http://58.215.184.18:8080/tutorial/image/4-8.png"
                                ],
                                
                                
                                @[
                                @"http://58.215.184.18:8080/tutorial/image/5-1.png",
                                @"http://58.215.184.18:8080/tutorial/image/5-2.png",
                                @"http://58.215.184.18:8080/tutorial/image/5-3.png",
                                @"http://58.215.184.18:8080/tutorial/image/5-4.png",
                                @"http://58.215.184.18:8080/tutorial/image/5-5.png",
                                @"http://58.215.184.18:8080/tutorial/image/5-6.png",
                                @"http://58.215.184.18:8080/tutorial/image/5-7.png",
                                @"http://58.215.184.18:8080/tutorial/image/5-8.png"
                                ],
                                
                                @[
                                @"http://58.215.184.18:8080/tutorial/image/6-1.png",
                                @"http://58.215.184.18:8080/tutorial/image/6-2.png",
                                @"http://58.215.184.18:8080/tutorial/image/6-3.png",
                                @"http://58.215.184.18:8080/tutorial/image/6-4.png",
                                @"http://58.215.184.18:8080/tutorial/image/6-5.png",
                                @"http://58.215.184.18:8080/tutorial/image/6-6.png",
                                @"http://58.215.184.18:8080/tutorial/image/6-7.png",
                                @"http://58.215.184.18:8080/tutorial/image/6-8.png"
                                ],*/
                               @[
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/6-1.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/6-2.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/6-3.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/6-4.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/6-5.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/6-6.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/6-7.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/6-8.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/6-9.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/6-10.jpg"
                                   ],
                               @[
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/7-2.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/7-8.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/7-4.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/7-6.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/7-5.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/7-3.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/7-7.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/7-9.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/7-1.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/7-10.jpg"
                                   ],
                               @[
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/8-8.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/8-6.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/8-7.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/8-2.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/8-5.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/8-4.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/8-3.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/8-1.jpg"
                                   ],
                               @[
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/4-1.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/4-2.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/4-3.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/4-4.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/4-5.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/4-6.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/4-7.jpg",
                                   @"http://58.215.160.100:8080/app_res/tutorial/image/4-8.jpg"
                                   ]
                               
                               ];
    
    /*
     http://58.215.184.18:8080/draw_data/20140716/f0262460-0c86-11e4-9049-00163e017d23.zip
     http://58.215.184.18:8080/draw_image/20140716/f01bc420-0c86-11e4-9049-00163e017d23.jpg
     tutorialId-7__stageId-7-0
     */
    //tutorial0chapter
    NSArray *tutorial6_chapterList =@[
                                      @[
                                          @"51564194e4b0d84d3151da6b"
                                          
                                          ],
                                      @[
                                          @"53cbd1b8e4b06d2c3a123cdc",
                                          @"53cbd1b8e4b06d2c3a123cdc",
                                          @"53cbd1b8e4b06d2c3a123cdc",
                                          @"53cbd1b8e4b06d2c3a123cdc"
                                          
                                          ],
                                      @[
                                          @"53cbd889e4b06d2c3a124080"
                                          ],
                                      @[
                                          @"53cbd889e4b06d2c3a124080",
                                          @"53cbd889e4b06d2c3a124080",
                                          @"53cbd889e4b06d2c3a124080",
                                          @"53cbd889e4b06d2c3a124080"
                                          
                                          
                                          ],
                                      @[
                                          @"53c770dae4b07ab22e742bf6"
                                          
                                          ],
                                      @[
                                          @"53c770a7e4b07ab22e742bf4",
                                          @"53cbd889e4b06d2c3a124080",
                                          @"53cbd889e4b06d2c3a124080",
                                          @"53cbd889e4b06d2c3a124080"
                                          
                                          ],
                                      @[
                                          @"53c770e8e4b07ab22e742bf7",
                                          @"53cbd889e4b06d2c3a124080"
                                          ]
                                      ];
    
    
    NSArray *chapterOpusIdList = @[
                                   @[
                                       @"51564194e4b0d84d3151da6b"
                                       
                                       ],
                                   @[
                                       @"53cbd1b8e4b06d2c3a123cdc"
                                       
                                       
                                       ],
                                   @[
                                       @"53cbd889e4b06d2c3a124080"
                                       
                                       ],
                                   @[
                                       @"53cbd889e4b06d2c3a124080"
                                       
                                       ],
                                   @[
                                       @"53c770dae4b07ab22e742bf6"
                                       
                                       ],
                                   @[
                                       @"53c770a7e4b07ab22e742bf4"
                                       
                                       
                                       ],
                                   @[
                                       @"53c770e8e4b07ab22e742bf7"
                                       
                                       ],
                                   @[
                                       @"53c770c1e4b07ab22e742bf5"
                                       ],
                                   @[
                                       @"53c77079e4b07ab22e742bf3"
                                       ],
                                   @[
                                       @"53c77079e4b07ab22e742bf3"
                                       ],
                                   ];
    
    
    //tutorial6
    NSArray *stageTips = @[@[@"tips1.png"],@[@"tips1.png"]];
    NSArray *stage6Tips = @[@[@"tips1.png"]];
    NSArray *stage7Tips = @[@[@"tips1.png",@"tips2.png"]];
    NSArray *stage8Tips = @[@[@"tips1.png",@"tips2.png",@"tips3.png"]];
    
    //tutorial0 的stage
    NSArray *stage1Tips_tutorial0 = @[@[@"tips1.png"]];
    NSArray *stage2Tips_tutorial0 = @[@[@"tips1.png"],@[@"tips2.png",@"tips3.png",@"tips4.png"],@[@"tips5.png",@"tips6.png",@"tips7.png",@"tips8.png"],@[@"tips9.png",@"tips10.png"]];
    NSArray *stage3Tips_tutorial0 = @[@[@"tips1.png"]];
    NSArray *stage4Tips_tutorial0 = @[@[@"tips1.png"],@[@"tips2.png"],@[@"tips3.png",@"tips4.png",@"tips5.png",@"tips6.png"],@[@"tips7.png"]];
    NSArray *stage5Tips_tutorial0 = @[@[@"tips1.png"]];
    NSArray *stage6Tips_tutorial0 = @[@[@"tips1.png"],@[@"tips2.png"],@[@"tips3.png",@"tips4.png",@"tips5.png",@"tips6.png"],@[@"tips7.png"]];
    NSArray *stage7Tips_tutorial0 =@[@[@"tips1.png",@"tips2.png"],@[@"tips3.png",@"tips4.png",@"tips5.png",@"tips6.png",@"tips7.png",@"tips8.png",@"tips9.png"]];
    
    //tutorial4（运动无极限）
    NSArray *stage4Tips_turoial4 = @[@[@"tips1.png",@"tips2.png"]];
    
    //stageTipsList
    NSArray *tutorial0Tips = @[stage1Tips_tutorial0,stage2Tips_tutorial0,stage3Tips_tutorial0,stage4Tips_tutorial0,stage5Tips_tutorial0,stage6Tips_tutorial0,stage7Tips_tutorial0];
    
    NSArray *tutorial6Tips = @[stageTips,@[],@[],@[],stage6Tips,stage7Tips,stage8Tips,@[],@[],@[]];
    NSArray *tutorial7Tips = @[@[],@[],@[],@[],@[],@[],@[],@[],@[],@[]];
    NSArray *tutorial8Tips = @[@[],@[],@[],@[],@[],@[],@[],@[],@[],@[]];
    NSArray *tutorial4Tips = @[stage4Tips_turoial4,@[],@[],@[],@[],@[],@[],@[]];
    
    
    //tutorialTipsList
    NSArray *tipsList = @[
                          tutorial0Tips,
                          //                          @[],
                          //                          @[],
                          //                          @[],
                          //                          @[],
                          //                          @[],
                          tutorial6Tips,
                          tutorial7Tips,
                          tutorial8Tips,
                          tutorial4Tips
                          ];
    
    NSArray *difficultyList = @[
                                @[],
                                @[],
                                @[],
                                @[],
                                @[],
                                @[],
                                @[],
                                @[],
                                @[]
                                ];
    
    //画的类型
    NSArray *stageTypeList = @[
                               @[@2,@2,@2,@2,@2,@2,@2,@2,@2,@2],
                               
                               //                                @[],
                               
                               //                                @[],
                               
                               //                                @[],
                               
                               //                                @[],
                               
                               
                               @[@0,@0,@0,@0,@0,@0,@0,@0,@0,@0],
                               @[@1,@1,@1,@1,@1,@1,@1,@1,@1,@1],
                               @[@1,@1,@1,@1,@1,@1,@1,@1,@1,@1],
                               @[@1,@1,@1,@1,@1,@1,@1,@1,@1,@1]
                               ];
    
    //三次元关卡stage的start Index
    NSArray *tutorial6_startIndex =@[
                                     @[],
                                     @[
                                         @132,
                                         @281,
                                         @720,
                                         @2443
                                         ],
                                     @[],
                                     @[@61,@430,@1827,@2621],
                                     @[],
                                     @[@61,@360,@1500,@2562],
                                     @[@500,@999]
                                     ];
    
    
    //模拟测试数据
    //    for(int i=0;i<testTutorialName.count;i++){
    //        NSString* ID = [NSString stringWithFormat:@"tutorialId-%d",i];
    //        PPDebug(@"tutorial count==%d",[testTutorialName count]);
    //
    //      PBTutorial_Builder* tb = [self evaluateTutorialTestDataName:[testTutorialName objectAtIndex:i]
    //                                  WithDesc:[testTutorialDesc objectAtIndex:i]
    //                            WithTutorialId:ID
    //                                 WithImage:[tutorialImageUrl objectAtIndex:i]
    //                                     IsAdd:NO
    //                               WithBuilder:nil
    //                                WithCategory:[tutorialCategory objectAtIndex:i]];
    //        for(int j=0;j<[[testStageName objectAtIndex:i]  count];j++){
    //            //TODO chapter
    //
    //            NSString* stageID = [NSString stringWithFormat:@"stageId-%d-%d",j,j];
    //            if(i==6){
    //            PPDebug(@"stageList count==%d",[[testStageName objectAtIndex:i]  count]);
    //            }
    //            [self evaluateStageTestDataName:[[testStageName objectAtIndex:i] objectAtIndex:j]
    //                                   WithDesc:[[testStageDesc objectAtIndex:i] objectAtIndex:j]
    //                                   WithStageId:stageID
    //                                   WithImage:[[stageImageUrl objectAtIndex:i]objectAtIndex:j]
    //                                   WithTutorial:tb
    //                                   WithIndex:i
    //                                   WithChapterList:[chapterOpusIdList objectAtIndex:j]
    //                                   WithChapterIndex:i
    //                                   tipList:tipsList
    //                                   tipsIndex:j];
    //        }
    //
    //        PBTutorial* tutorial = [tb build];
    //        [builder addTutorials:tutorial];
    //
    //    }
    
    NSMutableArray *tutorialList = [[NSMutableArray alloc] init];
    
    NSString* stageID = @"";
    //外层为tuturoial
    for(int tutorialSum=0;tutorialSum<[testTutorialName count];tutorialSum++){
        //中层为stage
        NSMutableArray *stageList = [[NSMutableArray alloc] init];
        for(int stageSum=0;stageSum<[[testStageName objectAtIndex:tutorialSum] count];stageSum++){
            
            NSMutableArray *chapterList = [[NSMutableArray alloc] init];
            //记录上一个chapter的start
            NSInteger endIndex = 0;
            //内层为chapter
            if(tutorialSum!=0){
                for(int chapterSum=0;chapterSum<[[chapterOpusIdList objectAtIndex:stageSum] count];chapterSum++){
                    
                    
                    
                    NSArray *tipsInChapter = [self getTipsInChapterCountTutorialIndex:tutorialSum stageIndex:stageSum chapterIndex:chapterSum list:tipsList];
                    NSMutableArray *tipsArray = [[NSMutableArray alloc] init];
                    if(tipsInChapter!=nil){
                        for(int tipsSum=0;tipsSum<[tipsInChapter count];tipsSum++){
                            PBTip *tip = [self evalueteTipsDataName:[tipsInChapter objectAtIndex:tipsSum] WithIndex:tipsSum];
                            [tipsArray addObject:tip];
                        }
                        
                    }
                    // 添加chapter
                    PBChapter *chapter = [self evalueteChapterDataChapterIndex:chapterSum tipList:tipsArray chapterStart:nil endIndex:nil];
                    [chapterList addObject:chapter];
                    stageID = [NSString stringWithFormat:@"stageId-%d-%d",stageSum,chapterSum];
                    
                    
                }
                
            }
            if(tutorialSum==0){
                
                for(int chapterSum=0;chapterSum<[[tutorial6_chapterList objectAtIndex:stageSum] count];chapterSum++){
                    NSArray *tipsInChapter = [self getTipsInChapterCountTutorialIndex:tutorialSum stageIndex:stageSum chapterIndex:chapterSum list:tipsList];
                    NSMutableArray *tipsArray = [[NSMutableArray alloc] init];
                    if(tipsInChapter!=nil){
                        for(int tipsSum=0;tipsSum<[tipsInChapter count];tipsSum++){
                            PBTip *tip = [self evalueteTipsDataName:[tipsInChapter objectAtIndex:tipsSum] WithIndex:tipsSum];
                            [tipsArray addObject:tip];
                        }
                    }
                    // 添加chapter
                    PBChapter *chapter = [self evalueteChapterDataChapterIndex:chapterSum tipList:tipsArray chapterStart:[tutorial6_startIndex objectAtIndex:stageSum] endIndex:[tutorial6_startIndex objectAtIndex:stageSum]];
                    [chapterList addObject:chapter];
                    //hard code
                    stageID = [NSString stringWithFormat:@"stageId-%d-%d",stageSum,0];
                }
                
                
            }
            Float32 difficulty = -1;
            if(difficulty < [[difficultyList objectAtIndex:tutorialSum] count]){
                if([[difficultyList objectAtIndex:tutorialSum] count]!=0&&[difficultyList objectAtIndex:tutorialSum]!=nil){
                    difficulty = [[[difficultyList objectAtIndex:tutorialSum] objectAtIndex:stageSum] floatValue];
                }
            }
            NSInteger stageType = 0;
            if(stageSum < [[stageTypeList objectAtIndex:tutorialSum] count]){
                if([[stageTypeList objectAtIndex:tutorialSum] count]!=0&&[stageTypeList objectAtIndex:tutorialSum]!=nil){
                    stageType = [[[stageTypeList objectAtIndex:tutorialSum] objectAtIndex:stageSum] integerValue];
                    
                }
                
                
            }
            //添加stage
            PBStage *stage = [self evaluateStageDataName:
                              [[testStageName objectAtIndex:tutorialSum] objectAtIndex:stageSum]
                                                WithDesc:[[testStageDesc objectAtIndex:tutorialSum] objectAtIndex:stageSum]
                                             WithStageId:stageID
                                               WithImage:[[stageImageUrl objectAtIndex:tutorialSum]objectAtIndex:stageSum]
                                                 tipList:tipsList
                                               tipsIndex:stageSum
                                                  opusId:[[chapterOpusIdList objectAtIndex:stageSum] objectAtIndex:0]
                                             chapterList:chapterList
                                              difficulty:difficulty
                                               stageType:stageType
                              ];
            
            [stageList addObject:stage];
        }
        
        NSString* ID = [NSString stringWithFormat:@"tutorialId-%d",tutorialSum];
        PBTutorial *tutorial = [self evaluateTutorialpbName:[testTutorialName objectAtIndex:tutorialSum]
                                                   WithDesc:[testTutorialDesc objectAtIndex:tutorialSum]
                                             WithTutorialId:ID
                                                  WithImage:[tutorialImageUrl objectAtIndex:tutorialSum]
                                               WithCategory:[tutorialCategory objectAtIndex:tutorialSum]
                                                  WithStage:stageList];
        
        [tutorialList addObject:tutorial];
        PPDebug(@"cnName:%@; enName:%@,tcnName:%@",tutorial.cnName,tutorial.enName,tutorial.tcnName);
        PPDebug(@"tutorialID: %@",tutorial.tutorialId);
    }
    [builder addAllTutorials:tutorialList];
    PBTutorialCore* core = [builder build];
    NSData* data = [core data];
    //    NSData* data = [test data];
    
    BOOL result = [data writeToFile:path atomically:YES];
    PPDebug(@"<createTestData> data file result=%d, file=%@", result, path);
    
    //    NSString* version = @"1.1";
    //    NSError* error = nil;
    //    result = [version writeToFile:versionPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    //    PPDebug(@"<createTestData> version txt file result=%d error=%@ file=%@", result, [error description], versionPath);
}

#define GET_THE_DEFAULT_NUM 0
-(PBTutorial*)defaultFirstTutorial
{
#ifdef DEBUG
    
    NSString *stepId = @"tutorialId-1";
    [self.stepByStepTutorialIdList addObject:stepId];
    return [self findTutorialByTutorialId:stepId];
    
#endif
    if([self.stepByStepTutorialIdList count]>0 && self.stepByStepTutorialIdList !=nil){
        //先取第一个元素,以后根据需求需要修改 TODO
        NSString *stepId = [self.stepByStepTutorialIdList objectAtIndex:GET_THE_DEFAULT_NUM];
        return [self findTutorialByTutorialId:stepId];
    }
    PPDebug(@"<defaultFirstTutorial> but the stepByStepTutorialIdList is nil or empty");
    return nil;
}

@end

