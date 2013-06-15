//
//  OpusManager.m
//  Draw
//
//  Created by 王 小涛 on 13-6-3.
//
//

#import "OpusManager.h"
#import "BuriManager.h"
#import "SingOpus.h"
#import "DrawOpus.h"
#import "UserManager.h"
#import "AskPs.h"
#import "StringUtil.h"
#import "Opus.h"
#import "SingOpus.h"

static OpusManager* globalSingOpusManager;
static OpusManager* globalDrawOpusManager;
static OpusManager* globalAskPsManager;

@interface OpusManager()
@property (assign, nonatomic) Class aClass;
@property (assign, nonatomic) UserManager* userManager;

@end

@implementation OpusManager

- (void)dealloc{
    [super dealloc];
}

+ (id)singOpusManager{
    
    static dispatch_once_t singOpusManagerOnceToken;
    dispatch_once(&singOpusManagerOnceToken, ^{
        if (globalSingOpusManager == nil){
            globalSingOpusManager = [[OpusManager alloc] initWithClass:[SingOpus class]];
        }
    });
    
    return globalSingOpusManager;
}

+ (id)drawOpusManager{
    
    static dispatch_once_t drawOpusManagerOnceToken;
    dispatch_once(&drawOpusManagerOnceToken, ^{
        if (globalDrawOpusManager == nil){
            globalDrawOpusManager = [[OpusManager alloc] initWithClass:[DrawOpus class]];
        }
    });
    
    return globalSingOpusManager;
}

+ (id)askPsManager{
    
    static dispatch_once_t askPsManagerOnceToken;
    dispatch_once(&askPsManagerOnceToken, ^{
        if (globalAskPsManager == nil){
            globalAskPsManager = [[OpusManager alloc] initWithClass:[AskPs class]];
        }
    });
    
    return globalAskPsManager;
}

- (id)initWithClass:(Class)class{
    if (self = [super init]) {
        self.aClass = class;
        self.userManager = [UserManager defaultManager];
    }
    
    return self;
}


- (id)opusWithOpusId:(NSString *)opusId{

    Opus *opus = [BuriBucket(_aClass) fetchObjectForKey:opusId];
    return opus;
}

- (void)saveOpus:(Opus*)opus
{
    if ([opus class] != _aClass) {
        PPDebug(@"ERROR: the object type you are trying to store, should be of the %@ class", NSStringFromClass(_aClass));
        return;
    }
    
    PPDebug(@"SAVE LOCAL OPUS=%@", [opus description]);
    [BuriBucket(_aClass) storeObject:opus];
}

- (void)deleteOpus:(NSString *)opusId{
    PPDebug(@"DELETE LOCAL OPUS KEY=%@", opusId);
    [BuriBucket(_aClass) deleteObjectForKey:opusId];
}

+ (PBOpus *)createTestOpus{
    PBOpus_Builder *builder = [[[PBOpus_Builder alloc] init] autorelease];
    
    [builder setOpusId:@"2"];

    [builder setType:PBOpusTypeSingToUser];
    [builder setName:@"我的作品"];
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
    
    PBGameUser_Builder *toUserBuilder = [[[PBGameUser_Builder alloc] init] autorelease];
    [toUserBuilder setUserId:@"xxx"];
    [toUserBuilder setNickName:@"甘米"];
    [builder setTargetUser:[toUserBuilder build]];
    
    return [builder build];
}

- (void)setDraftOpusId:(Opus*)opus
{
    NSString* tempOpusId = [NSString GetUUID];
    [opus setOpusId:tempOpusId];
    [opus setStorageType:PBOpusStoreTypeDraftOpus];
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

- (SingOpus*)createDraftSingOpus:(PBSong*)song
{
    SingOpus* singOpus = [[[SingOpus alloc] init] autorelease];
    
    // set basic info
    [self setDraftOpusId:singOpus];
    [self setCommonOpusInfo:singOpus];

    // set type and category
    [singOpus setType:PBOpusTypeSing];
    [singOpus setCategory:PBOpusCategoryTypeSingCategory];
    [singOpus setName:[song name]];
    
    // init song info
    [singOpus setSong:song];
    [singOpus setVoiceType:PBVoiceTypeVoiceTypeOrigin];
    [singOpus setDuration:1];
    [singOpus setPitch:1];
    [singOpus setFormant:1];
    
    return singOpus;
    
    /*
     required string opusId = 1;                   // 作品Id
     optional PBOpusType type = 2;                 // 作品类型
     optional string name = 3;                     // 作品名称
     optional string desc = 4;                     // 作品描述
     optional string image = 5;                    // 作品图片
     optional string thumbImage = 6;               // 作品缩略图
     optional string dataUrl = 9;                  // 作品数据远程URL
     
     optional PBLanguage language = 10;            // 作品语言
     optional PBOpusCategoryType category = 11;    // 作品大分类
     
     optional int32 createDate = 15;               // 作品创建时间
     optional int32 status = 20;                   // 作品状态，0表示正常，1表示已删除。
     
     // 创建来源信息，如来自哪些设备、应用
     optional int32  deviceType = 25;               // deviceType : (1:iPhone/iPod Touch, 2:iPad, 3:Android Phone)
     optional string deviceName = 26;               // 设备名称，如 iPhone4, New iPad, iPhone5, 三星Galaxy 等等
     optional string appId = 28;                    // 来自哪个应用创作的
     
     optional PBGameUser author = 35;              // 作者基本信息
     
     optional PBGameUser targetUser = 41;          // 作品是给谁的
     optional string contestId = 42;               // 参与的比赛的Id
     */
}

@end
