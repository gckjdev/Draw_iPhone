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
@property (retain, nonatomic) BuriBucket *bucket;

@end

@implementation OpusManager

SYNTHESIZE_SINGLETON_FOR_CLASS(OpusManager);

- (void)dealloc{
    [_bucket release];
    [super dealloc];
}

- (id)init{
    if (self = [super init]) {
        self.bucket = [[BuriManager defaultManager] createBucketWithObjectClass:[Opus class]];
    }
    
    return self;
}

- (Opus*)opusWithOpusId:(NSString *)opusId{
    
    Opus *opus = [_bucket fetchObjectForKey:opusId];
    return opus;
}

- (void)saveOpus:(Opus*)opus
{
    [_bucket storeObject:opus];
}

- (void)deleteOpus:(NSString*)opusId{
    
    [_bucket deleteObjectForKey:opusId];
}

@end
