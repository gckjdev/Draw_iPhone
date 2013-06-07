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
@property (copy, nonatomic) NSString *opusId;

@end


@implementation Opus

- (void)dealloc
{
    [_opusId release];
    [_pbOpusBuilder release];
    [super dealloc];
}

- (id)init{
    if (self = [super init]) {
        self.pbOpusBuilder = [[[PBOpus_Builder alloc] init] autorelease];
        self.opusId = @"2";
//        [self.pbOpusBuilder setOpusId:[NSString GetUUID]];
        [self.pbOpusBuilder setOpusId:_opusId];
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
    opus.opusId = opus.pbOpusBuilder.opusId;
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

+ (NSDictionary *)buriProperties{
    return @{
             BURI_KEY: @"opusId",
             };
}

- (id)initWithCoder:(NSCoder *)decoder
{
	if ((self = [super init])) {
        NSString *opusId = [decoder decodeObjectForKey:@"opusId"];
		NSData *data = [decoder decodeObjectForKey:@"opusData"];
        
        self.opusId = opusId;
        self.pbOpusBuilder = [PBOpus builderWithPrototype:[PBOpus parseFromData:data]];
	}
    
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:_opusId forKey:@"opusId"];
    [encoder encodeObject:[[self pbOpus] data] forKey:@"opusData"];
}

@end

