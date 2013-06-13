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
#import "AskPs.h"

static OpusManager* globalSingOpusManager;
static OpusManager* globalDrawOpusManager;
static OpusManager* globalAskPsManager;

@interface OpusManager()
@property (assign, nonatomic) Class aClass;

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
    [builder setDesc:@"详细描述"];
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

@end
