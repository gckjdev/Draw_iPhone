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
#import "AskPs.h"
#import "FileUtil.h"

@interface Opus()

@end


@implementation Opus

#pragma mark - Init & Dealloc

- (void)dealloc
{
    [_pbOpusBuilder release];
    [super dealloc];
}

- (id)init{
    if (self = [super init]) {        
        self.pbOpusBuilder = [[[PBOpus_Builder alloc] init] autorelease];
    }
    
    return self;
}

- (NSString*)opusKey
{
    return [_pbOpusBuilder opusId];
}

+ (Opus*)opusWithCategory:(OpusCategory)category{
    Opus *opus = nil;
    switch (category) {
        case OpusCategorySing:
            opus = [[[SingOpus alloc] init] autorelease];
            break;
        case OpusCategoryAskPs:
            opus = [[[AskPs alloc] init] autorelease];
            break;
        default:
            break;
    }
    
    return opus;
}



+ (Opus*)opusWithPBOpus:(PBOpus *)pbOpus{
    Opus *opus = [[[Opus alloc] init] autorelease];
    opus.pbOpusBuilder = [PBOpus builderWithPrototype:pbOpus];
    return opus;
}

#pragma mark - Get & Set Methods

- (void)setType:(PBOpusType)type{
    [_pbOpusBuilder setType:type];
}

- (void)setName:(NSString *)name{
    [_pbOpusBuilder setName:name];
}

- (void)setDesc:(NSString *)desc{
    [_pbOpusBuilder setDesc:desc];
}

- (void)setCategory:(int)value{
    [_pbOpusBuilder setCategory:value];
}

- (void)setLanguage:(int)value
{
    [_pbOpusBuilder setLanguage:value];
}

- (void)setOpusId:(NSString *)value
{
    [_pbOpusBuilder setOpusId:value];
}

- (void)setDeviceName:(NSString *)value
{
    [_pbOpusBuilder setDeviceName:value];
}

- (void)setAppId:(NSString *)value
{
    [_pbOpusBuilder setAppId:value];
}

- (void)setAuthor:(PBGameUser *)user
{
    [_pbOpusBuilder setAuthor:user];
}

- (void)setStorageType:(int)value
{
    [_pbOpusBuilder setStoreType:value];
}

- (void)setCreateDate:(int)value
{
    [_pbOpusBuilder setCreateDate:value];
}

- (void)setDeviceType:(int)value
{
    [_pbOpusBuilder setDeviceType:value];
}


- (void)setTargetUser:(PBGameUser *)user{
    [self setTargetUser:user];
    
    if (user == nil) {
        [_pbOpusBuilder setType:PBOpusTypeSing];
    }else{
        [_pbOpusBuilder setType:PBOpusTypeSingToUser];
    }
}

- (void)setLocalDataUrl:(NSString*)extension
{
    NSString* path = [NSString stringWithFormat:@"%@/%@.%@", [[self class] localDataDir], [self opusKey], extension];
    NSString* finalPath = [FileUtil filePathInAppDocument:path];
    [_pbOpusBuilder setLocalDataUrl:finalPath];
}

- (NSURL*)localDataURL
{
    return [NSURL fileURLWithPath:[_pbOpusBuilder localDataUrl]];
}
            
+ (NSString*)localDataDir
{
    PPDebug(@"******************************* localDataDir MUST BE IMPLEMENTED BY SUB CLASS *******************************");
    return nil;
}

- (NSString*)dataType
{
    return @"dat";
}

#pragma mark - Data Generation

- (PBOpus *)pbOpus{
    PBOpus *opus = [_pbOpusBuilder build];
    self.pbOpusBuilder = [PBOpus builderWithPrototype:opus];

    return opus;
}

- (NSData *)data
{    
    NSData* data = nil;
    @try {
        PBOpus* pbOpus = [self pbOpus];
        if (pbOpus == nil)
            return nil;
        
        data = [pbOpus data];
    }
    @catch (NSException *exception) {
        PPDebug(@"create data but catch exception=%@", [exception debugDescription]);
    }
    @finally {
    }
    
    return data;
}

#pragma mark - Buri Handling

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
		NSData *data = [decoder decodeObjectForKey:ENCODE_OPUS_DATA];        
        self.pbOpusBuilder = [PBOpus builderWithPrototype:[PBOpus parseFromData:data]];
	}
    
	return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:[self opusKey] forKey:ENCODE_OPUS_KEY];
    [encoder encodeObject:[[self pbOpus] data] forKey:ENCODE_OPUS_DATA];
}

@end

