//
//  Opus.m
//  Draw
//
//  Created by 王 小涛 on 13-6-3.
//
//

#import "Opus.h"
#import "StringUtil.h"
#import "SingOpus.h"

@interface Opus()
@property (copy, nonatomic) NSString *opusKey;

@end


@implementation Opus

- (void)dealloc
{
    [_opusKey release];
    [_pbOpusBuilder release];
    [super dealloc];
}

- (id)init{
    if (self = [super init]) {
        self.pbOpusBuilder = [[[PBOpus_Builder alloc] init] autorelease];
//        [self.pbOpusBuilder setOpusId:[NSString GetUUID]];
        [self.pbOpusBuilder setOpusId:@"2"];
        self.opusKey = _pbOpusBuilder.opusId;
    }
    
    return self;
}

+ (id)opusWithType:(OpusType)type{
    Opus *opus = nil;
    switch (type) {
        case OpusTypeSing:
            opus = [[[SingOpus alloc] init] autorelease];
            break;
            
        default:
            break;
    }
    
    return opus;
}

+ (id)opusWithPBOpus:(PBOpus *)pbOpus{
    Opus *opus = [[[Opus alloc] init] autorelease];
    opus.pbOpusBuilder = [PBOpus builderWithPrototype:pbOpus];
    opus.opusKey = opus.pbOpusBuilder.opusId;
    return opus;
}

- (void)setAim:(PBOpusAim)aim{
    [_pbOpusBuilder setAim:aim];
}

- (void)setName:(NSString *)name{
    [_pbOpusBuilder setName:name];
}

- (void)setDesc:(NSString *)desc{
    [_pbOpusBuilder setDesc:desc];
}

- (void)setTargetUser:(PBGameUser *)user{
    [self setTargetUser:user];
    
    if (user == nil) {
        [_pbOpusBuilder setAim:PBOpusAimSing];
    }else{
        [_pbOpusBuilder setAim:PBOpusAimSingToUser];
    }
}

- (PBOpus *)pbOpus{
    PBOpus *opus = [_pbOpusBuilder build];
    self.pbOpusBuilder = [PBOpus builderWithPrototype:opus];

    return opus;
}

#define ENCODE_OPUS_DATA        @"opusData"
#define ENCODE_OPUS_KEY         @"opusKey"

+ (NSDictionary *)buriProperties{
    return @{
             BURI_KEY: ENCODE_OPUS_KEY, // make sure it's in Opus.h
             };
}



- (id)initWithCoder:(NSCoder *)decoder
{
	if ((self = [super init])) {
        NSString *opusKey = [decoder decodeObjectForKey:ENCODE_OPUS_KEY];
		NSData *data = [decoder decodeObjectForKey:ENCODE_OPUS_DATA];
        
        self.opusKey = opusKey;
        self.pbOpusBuilder = [PBOpus builderWithPrototype:[PBOpus parseFromData:data]];
	}
    
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_opusKey forKey:ENCODE_OPUS_KEY];
    [encoder encodeObject:[[self pbOpus] data] forKey:ENCODE_OPUS_DATA];
}

@end
