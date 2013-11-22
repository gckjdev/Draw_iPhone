//
//  OpusManager.m
//  Draw
//
//  Created by 王 小涛 on 13-6-3.
//
//

#import "OpusManager.h"
#import "UserManager.h"
#import "StringUtil.h"
#import "Opus.h"
#import "FileUtil.h"
#import "LevelDBManager.h"

@interface OpusManager()
@property (assign, nonatomic) Class aClass;
@property (assign, nonatomic) UserManager* userManager;
@property (nonatomic, retain) NSString* dbName;
@property (nonatomic, retain) APLevelDB* db;

@end

@implementation OpusManager

- (void)dealloc{
    
    PPRelease(_db);
    PPRelease(_dbName);
    [super dealloc];
}

- (id)initWihtDbName:(NSString *)dbName{
    if (self = [super init]) {
        self.aClass = [self opusClass];
        self.dbName = dbName;
        self.userManager = [UserManager defaultManager];
        
        [FileUtil createDir:[FileUtil filePathInAppDocument:[self.aClass localDataDir]]];
        
        self.db = [[LevelDBManager defaultManager] db:dbName];
    }
    
    return self;
}

// left for subclass to implementation
- (Class)opusClass{
    
    return NULL;
}

- (Opus*)opusWithOpusId:(NSString *)opusId{
    Opus* opus = [_db objectForKey:opusId];
    return opus;
}

- (void)saveOpus:(Opus*)opus
{
    PPDebug(@"SAVE LOCAL OPUS=%@", [opus description]);
    [_db setObject:opus forKey:[opus opusKey]];
    
    [self printAllOpus];
}

- (void)deleteOpus:(Opus *)opus
{
    // remove local file
    [FileUtil removeFile:opus.pbOpus.localDataUrl];
    [FileUtil removeFile:opus.pbOpus.localImageUrl];
    [FileUtil removeFile:opus.pbOpus.localThumbImageUrl];
    
    PPDebug(@"DELETE LOCAL OPUS KEY=%@", opus.pbOpus.opusId);
    [_db removeKey:opus.pbOpus.opusId];
    
    [self printAllOpus];    
}

+ (PBOpus *)createTestOpus{
    PBOpus_Builder *builder = [[[PBOpus_Builder alloc] init] autorelease];
    
    [builder setOpusId:@"512c971de4b02d50d0d20376"];
    [builder setCategory:PBOpusCategoryTypeSingCategory];
    [builder setType:PBOpusTypeSingToUser];
    [builder setName:@"我的作品"];
    [builder setDataUrl:@"http://58.254.132.169/90115000/fulltrack_dl/MP3_128_44_Stero/2012060802/481874.mp3"];
    [builder setDesc:@"详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述详细描述"];
    [builder setThumbImage:@"http://pic.rouding.com/uploadfile/201202/19/50223649544.jpg"];
    [builder setImage:@"http://www.lockonfiles.com/modules/Downloads/imageuploads/Su-34%20x2048.jpg"];
    [builder setCreateDate:[[NSDate date] timeIntervalSince1970]];
    [builder setStatus:0];
    
    
    PBGameUser_Builder *authorBuilder = [[[PBGameUser_Builder alloc] init] autorelease];
    [authorBuilder setUserId:@"xxx"];
    [authorBuilder setNickName:@"老老头"];
    [authorBuilder setAvatar:@"http://h.hiphotos.baidu.com/album/w%3D1280%3Bcrop%3D0%2C0%2C1280%2C800/sign=84bd2cae4e4a20a4311e38c5a862a341/728da9773912b31b77fab9958718367adbb4e1fc.jpg"];
    [authorBuilder setGender:YES];
    [authorBuilder setSignature:@"这是我的个人签名"];
    [builder setAuthor:[authorBuilder build]];
    
    [builder addAllFeedTimes:[self feedTimesList]];
    
    PBGameUser_Builder *toUserBuilder = [[[PBGameUser_Builder alloc] init] autorelease];
    [toUserBuilder setUserId:@"xxx"];
    [toUserBuilder setNickName:@"甘米"];
    [builder setTargetUser:[toUserBuilder build]];
    
    return [builder build];
}


+ (NSArray *)feedTimesList{
    PBFeedTimes *t1 = [self feedTimesWithType:PBFeedTimesTypeFeedTimesTypeComment value:16];
    PBFeedTimes *t2 = [self feedTimesWithType:PBFeedTimesTypeFeedTimesTypeGuess value:21];
    PBFeedTimes *t3 = [self feedTimesWithType:PBFeedTimesTypeFeedTimesTypeFlower value:10];
    PBFeedTimes *t4 = [self feedTimesWithType:PBFeedTimesTypeFeedTimesTypeSave value:2];

    return [NSArray arrayWithObjects:t1, t2, t3, t4, nil];
}

+ (PBFeedTimes *)feedTimesWithType:(PBFeedTimesType)type value:(int)value{
    PBFeedTimes_Builder *builder = [[[PBFeedTimes_Builder alloc] init] autorelease];
    [builder setType:type];
    [builder setValue:value];

    return  [builder build];
}

//+ (NSArray *)actionTimes{
//    PBActionTimes *t1 = [self actionTimesWithType:PBOpusActionTypeOpusActionTypeComment name:@"评论" value:16];
//    PBActionTimes *t2 = [self actionTimesWithType:PBOpusActionTypeOpusActionTypeGuess name:@"猜画" value:10];
//    PBActionTimes *t3 = [self actionTimesWithType:PBOpusActionTypeOpusActionTypeFlower name:@"鲜花" value:21];
//    PBActionTimes *t4 = [self actionTimesWithType:PBOpusActionTypeOpusActionTypeSave name:@"收藏" value:1];
//    
//    return [NSArray arrayWithObjects:t1, t2, t3, t4, nil];
//
//}
//
//+ (PBActionTimes *)actionTimesWithType:(PBOpusActionType)type name:(NSString *)name value:(int)value{
//    PBActionTimes_Builder *builder = [[[PBActionTimes_Builder alloc] init] autorelease];
//    [builder setType:type];
//    [builder setName:name];
//    [builder setValue:value];
//    
//    return  [builder build];
//}

- (void)setDraftOpusId:(Opus*)opus extension:(NSString*)fileNameExtension
{
    NSString* tempOpusId = [NSString stringWithFormat:@"draft-%010ld-%@", time(0), [NSString GetUUID]];
    [opus setOpusId:tempOpusId];
    [opus setAsDraft];
    [opus setLocalDataUrl:fileNameExtension];
}

- (void)setCommonOpusInfo:(Opus*)opus
{
    [opus setLanguage:[_userManager getLanguageType]];
    [opus setCreateDate:time(0)];
    [opus setDeviceType:[_userManager deviceType]];
    [opus setDeviceName:[_userManager deviceModel]];
    [opus setAppId:[GameApp appId]];
    
    // set author information
    PBGameUser_Builder* userBuilder = [[PBGameUser_Builder alloc] init];
    [userBuilder setUserId:[_userManager userId]];
    [userBuilder setNickName:[_userManager nickName]];
    [userBuilder setAvatar:[_userManager avatarURL]];
    [userBuilder setSignature:[_userManager signature]];
    [userBuilder setGender:[_userManager gender]];
    
    [opus setAuthor:[userBuilder build]];
    [userBuilder release];
}

- (NSArray*)reverseSubArray:(NSArray*)array offset:(int)offset limit:(int)limit
{
    if (array == nil || [array count] == 0){
        return nil;
    }
    
    int count = [array count];

    int startIndex = count - 1 - offset;
    int endIndex = count - 1 - offset - limit;

    if (startIndex < 0){
        return nil;
    }

    if (endIndex < 0)
        endIndex = 0;

    NSRange range;
    range.length = (startIndex - endIndex);
    range.location = endIndex;

    NSMutableArray* retArray = [NSMutableArray array];
    for (int i=startIndex; i>=endIndex; i--){
        [retArray addObject:[array objectAtIndex:i]];
    }
    
    return retArray;
}

- (NSArray*)findAll
{
    return [_db allObjects];
}

- (NSArray*)findAllOpusWithOffset:(int)offset limit:(int)limit
{
    NSArray* opusArray = [self findAll];
    return [self reverseSubArray:opusArray offset:offset limit:limit];
}

- (void)deleteOpusInArray:(NSArray*)opusArray
{
    for (Opus* opus in opusArray){
        [_db removeKey:[opus opusKey]];
    }
}

- (void)deleteAllOpus
{
    NSArray* opusArray = [self findAll];
    [self deleteOpusInArray:opusArray];
}

- (int)allOpusCount
{
    return [[self findAll] count];
}

- (int)recoveryOpusCount
{
    int count = 0;
    
    NSArray* opusArray = [self findAll];
    for (Opus* opus in opusArray){
        if ([opus.pbOpusBuilder isRecovery]){
            count ++;
        }
    }
    
    return count;
}

/*
// 草稿作品
- (NSArray*)findAllDrafts
{
    return [BuriBucket(_aClass) fetchObjectsForNumericIndex:BURI_INDEX_STORE_TYPE
                                                       value:@(PBOpusStoreTypeDraftOpus)];
}

- (NSArray*)findAllDraftsWithOffset:(int)offset limit:(int)limit
{
    NSArray* drafts = [self findAllDrafts];
    return [self reverseSubArray:drafts offset:offset limit:limit];
}

// 已经提交的所有作品
- (NSArray*)findAllSubmitOpus
{
    return [BuriBucket(_aClass) fetchObjectsForNumericIndex:BURI_INDEX_STORE_TYPE
                                                       value:@(PBOpusStoreTypeSubmitOpus)];
}

- (NSArray*)findAllSubmitOpusWithOffset:(int)offset limit:(int)limit
{
    NSArray* drafts = [self findAllSubmitOpus];
    return [self reverseSubArray:drafts offset:offset limit:limit];
}

// 保存到本地的所有作品
- (NSArray*)findAllSavedOpus
{
    return [BuriBucket(_aClass) fetchObjectsForNumericIndex:BURI_INDEX_STORE_TYPE
                                                       value:@(PBOpusStoreTypeSavedOpus)];
}

- (NSArray*)findAllSavedOpusWithOffset:(int)offset limit:(int)limit
{
    NSArray* drafts = [self findAllSavedOpus];
    return [self reverseSubArray:drafts offset:offset limit:limit];
}



- (NSArray*)findAllWithOffset:(int)offset limit:(int)limit
{
    NSArray* drafts = [self findAll];
    return [self reverseSubArray:drafts offset:offset limit:limit];
}


- (void)deleteAllDrafts
{
    NSArray* opusArray = [self findAllDrafts];
    [self deleteOpusInArray:opusArray];
}

- (void)deleteAllSubmitOpus
{
    NSArray* opusArray = [self findAllSubmitOpus];
    [self deleteOpusInArray:opusArray];
}

- (void)deleteAllSavedOpus
{
    NSArray* opusArray = [self findAllSavedOpus];
    [self deleteOpusInArray:opusArray];
}


- (int)draftOpusCount
{
    return [[self findAllDrafts] count];
}

- (int)submitOpusCount
{
    return [[self findAllSubmitOpus] count];
}

- (int)savedOpusCount
{
    return [[self findAllSavedOpus] count];
}

- (int)recoveryOpusCount
{
    int count = 0;
    
    NSArray* opusArray = [self findAll];
    for (Opus* opus in opusArray){
        if ([opus.pbOpusBuilder isRecovery]){
            count ++;
        }
    }
    
    return count;
}
*/

- (void)printAllOpus
{
#ifdef DEBUG
    NSArray* opuses = [self findAllOpusWithOffset:0 limit:100];
    PPDebug(@"==== total %d opus ====", [opuses count]);
    for (Opus* opus in opuses){
        PPDebug(@"opus = %@", [opus description]);
    }
#endif
}

- (Opus*)createDraftWithName:(NSString*)name{
    
    PPDebug(@"<%s> is not Implemented in sub-class", __FUNCTION__);
    return nil;
}

@end
