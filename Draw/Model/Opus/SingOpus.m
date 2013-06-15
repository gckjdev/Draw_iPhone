//
//  SingOpus.m
//  Draw
//
//  Created by 王 小涛 on 13-6-3.
//
//

#import "Opus.h"
#import "SingOpus.h"
#import "FileUtil.h"

@implementation SingOpus


- (void)setSong:(PBSong *)song{
    PBSingOpus_Builder *builder = [PBSingOpus builderWithPrototype:self.pbOpusBuilder.sing];
    [builder setSong:song];
    [self.pbOpusBuilder setSing:[builder build]];
}

- (void)setVoiceType:(PBVoiceType)voiceType{
    PBSingOpus_Builder *builder = [PBSingOpus builderWithPrototype:self.pbOpusBuilder.sing];
    [builder setVoiceType:voiceType];
    
    switch (voiceType) {
        case PBVoiceTypeVoiceTypeOrigin:
            [builder setDuration:1];
            [builder setPitch:1];
            [builder setFormant:1];
            break;
            
        case PBVoiceTypeVoiceTypeTomCat:
            [builder setDuration:0.5];
            [builder setPitch:1.f/0.5];
            [builder setFormant:1];
            break;
            
        case PBVoiceTypeVoiceTypeDuck:
            [builder setDuration:0.5];
            [builder setPitch:1.f/0.5];
            [builder setFormant:1];
            break;
            
        case PBVoiceTypeVoiceTypeMale:
            [builder setDuration:1];
            [builder setPitch:0.8];
            [builder setFormant:0.5];
            break;
            
        case PBVoiceTypeVoiceTypeChild:
            [builder setDuration:0.5];
            [builder setPitch:1.f/0.5];
            [builder setFormant:1];
            break;
            
        case PBVoiceTypeVoiceTypeFemale:
            [builder setDuration:1];
            [builder setPitch:1.2];
            [builder setFormant:1];
            break;
            
        default:
            break;
    }
    
    [self.pbOpusBuilder setSing:[builder build]];
}

#pragma data & native data URL handling

- (NSURL*)localNativeDataURL
{
    return  [NSURL fileURLWithPath:[self.pbOpusBuilder.sing localNativeDataUrl]];
}

+ (NSString*)localDataDir
{
    return @"SingData";
}

- (void)setLocalNativeDataUrl:(NSString*)extension
{
    NSString* path = [NSString stringWithFormat:@"%@/%@_native.%@", [[self class] localDataDir], [self opusKey], extension];
    NSString* finalPath = [FileUtil filePathInAppDocument:path];
    
    PBSingOpus_Builder *builder = [PBSingOpus builderWithPrototype:self.pbOpusBuilder.sing];
    [builder setLocalNativeDataUrl:finalPath];
    [self.pbOpusBuilder setSing:[builder build]];
}

- (NSString*)dataType
{
    return @"m4a";
}


@end
