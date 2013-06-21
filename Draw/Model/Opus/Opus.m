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
#import "UserManager.h"

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

- (NSNumber*)opusStoreType
{
    return @([_pbOpusBuilder storeType]);
}

+ (Opus*)opusWithCategory:(PBOpusCategoryType)category{
    Opus *opus = nil;
    switch (category) {
        case PBOpusCategoryTypeSingCategory:
            opus = [[[SingOpus alloc] init] autorelease];
            break;
        case PBOpusCategoryTypeAskPsCategory:
            opus = [[[AskPs alloc] init] autorelease];
            break;
        default:
            break;
    }
    
    return opus;
}

+ (Opus*)opusWithPBOpus:(PBOpus *)pbOpus storeType:(PBOpusStoreType)storeType{
    Opus *opus = [self opusWithCategory:pbOpus.category];
    opus.pbOpusBuilder = [PBOpus builderWithPrototype:pbOpus];
    [opus setStorageType:storeType];
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

- (void)setStorageType:(PBOpusStoreType)value
{
    [_pbOpusBuilder setStoreType:value];
}

- (void)setAsDraft
{
    [_pbOpusBuilder setStoreType:PBOpusStoreTypeDraftOpus];
}

- (void)setAsSubmit
{
    [_pbOpusBuilder setStoreType:PBOpusStoreTypeSubmitOpus];
}

- (void)setAsSaved
{
    [_pbOpusBuilder setStoreType:PBOpusStoreTypeSavedOpus];
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

- (NSString*)description
{
    return [NSString stringWithFormat:@"[id=%@, type=%d, storeType=%d, name=%@]",
            [self opusKey], [self.pbOpusBuilder type], [[self opusStoreType] intValue], [self.pbOpusBuilder name]];
}

#pragma mark - Buri Protocol 

+ (NSDictionary *)buriProperties{
    return @{
             BURI_KEY: ENCODE_OPUS_KEY, // make sure it's in Opus.h
             BURI_NUMERIC_INDEXES: @[BURI_INDEX_STORE_TYPE],
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
    [encoder encodeObject:[self opusKey] forKey:ENCODE_OPUS_KEY];           // useless???
    [encoder encodeObject:[[self pbOpus] data] forKey:ENCODE_OPUS_DATA];
}

- (BOOL)isMyOpus
{
    return [[UserManager defaultManager] isMe:self.pbOpus.author.userId];
}
- (NSString*)name
{
    return self.pbOpus.name;
}
- (NSDate*)createDate
{
    return [NSDate dateWithTimeIntervalSince1970:self.pbOpus.createDate];
}

- (void)replayInController:(UIViewController*)controller
{
    PPDebug(@"<replayInController> no impletement!");
}

- (NSArray*)shareOptionsTitleArray
{
    PPDebug(@"<shareOptionsTitleArray> no impletement!");
    return nil;
}
- (void)handleShareOptionAtIndex:(int)index
                  fromController:(UIViewController*)controller
{
    PPDebug(@"<handleShareOptionAtIndex> no impletement!");
}

- (void)enterEditFromController:(UIViewController *)controller
{
    PPDebug(@"<enterEditFromController> no impletement!");
}

@end

