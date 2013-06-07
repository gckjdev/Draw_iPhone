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

static OpusManager* globalSingOpusManager;

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

@end
