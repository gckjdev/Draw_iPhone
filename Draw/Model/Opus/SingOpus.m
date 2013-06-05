//
//  SingOpus.m
//  Draw
//
//  Created by 王 小涛 on 13-6-3.
//
//

#import "Opus.h"
#import "SingOpus.h"

@implementation SingOpus

- (void)setSong:(PBSong *)song{
    PBSingOpus_Builder *builder = [PBSingOpus builderWithPrototype:self.pbOpusBuilder.singOpus];
    [builder setSong:song];
    [self.pbOpusBuilder setSingOpus:[builder build]];
}

- (void)setVoiceType:(PBVoiceType)voiceType{
    PBSingOpus_Builder *builder = [PBSingOpus builderWithPrototype:self.pbOpusBuilder.singOpus];
    [builder setVoiceType:voiceType];
    [self.pbOpusBuilder setSingOpus:[builder build]];
}

- (void)setDuration:(float)duration{
    PBSingOpus_Builder *builder = [PBSingOpus builderWithPrototype:self.pbOpusBuilder.singOpus];
    [builder setDuration:duration];
    [self.pbOpusBuilder setSingOpus:[builder build]];
}

- (void)setPitch:(float)pitch{
    PBSingOpus_Builder *builder = [PBSingOpus builderWithPrototype:self.pbOpusBuilder.singOpus];
    [builder setPitch:pitch];
    [self.pbOpusBuilder setSingOpus:[builder build]];
}

@end
