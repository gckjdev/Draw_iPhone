//
//  OpusManager.m
//  Draw
//
//  Created by 王 小涛 on 13-6-3.
//
//

#import "OpusManager.h"
#import "SynthesizeSingleton.h"
#import "BuriManager.h"

@interface OpusManager()

@end

@implementation OpusManager

SYNTHESIZE_SINGLETON_FOR_CLASS(OpusManager);

- (void)dealloc{
    [super dealloc];
}

- (id)init{
    if (self = [super init]) {
    }
    
    return self;
}


- (id)opusWithOpusKey:(NSString *)opusKey{

    Class class = [Opus classForOpusKey:opusKey];
    Opus *opus = [BuriBucket(class) fetchObjectForKey:opusKey];
    
    return opus;
}

- (void)saveOpus:(Opus*)opus
{
    PPDebug(@"SAVE LOCAL OPUS=%@", [opus description]);
    [BuriBucket([opus class]) storeObject:opus];
}

- (void)deleteOpus:(NSString *)opusKey{

    PPDebug(@"DELETE LOCAL OPUS KEY=%@", opusKey);
    Class class = [Opus classForOpusKey:opusKey];
    [BuriBucket(class) deleteObjectForKey:opusKey];
}

@end
