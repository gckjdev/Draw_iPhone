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

@end


@implementation Opus

- (id)init{
    if (self = [super init]) {
        self.pbOpusBuilder = [[[PBOpus_Builder alloc] init] autorelease];
//        [self.pbOpusBuilder setOpusId:[NSString GetUUID]];
        [self.pbOpusBuilder setOpusId:@"2"];
        self.opusKey = [self opusKeyWithOpusId:_pbOpusBuilder.opusId];
    }
    
    return self;
}

- (void)dealloc
{
    [_opusKey release];
    [_pbOpusBuilder release];
    [super dealloc];
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


- (NSString *)opusKeyWithOpusId:(NSString *)opusId
{
    NSString *className = NSStringFromClass([self class]);
    NSString *key = [NSString stringWithFormat:@"%@_%@",className, opusId];
    return key;
}

+ (Class)classForOpusKey:(NSString *)opusKey {
    NSRange range = [opusKey rangeOfString:@"_"];
    if (range.location == NSNotFound) {
        return nil;
    }
    
    NSString *className = [opusKey substringToIndex:range.location];
    Class class = NSClassFromString(className);
    
    return class;
}

+ (NSDictionary *)buriProperties{
    return @{
             BURI_KEY: @"opusKey",
             };
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if ((self = [super init])) {
    
		NSData *data = [decoder decodeObjectForKey:@"opusData"];
        NSString *key = [decoder decodeObjectForKey:@"opusKey"];

        self.opusKey = key;
        self.pbOpusBuilder = [PBOpus builderWithPrototype:[PBOpus parseFromData:data]];
	}
    
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:[self opusKey] forKey:@"opusKey"];
    [encoder encodeObject:[[self pbOpus] data] forKey:@"opusData"];
}

@end

