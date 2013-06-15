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
    PBSingOpus_Builder *builder = [PBSingOpus builderWithPrototype:self.pbOpusBuilder.sing];
    [builder setSong:song];
    [self.pbOpusBuilder setSing:[builder build]];
}

- (void)setVoiceType:(PBVoiceType)voiceType{
    PBSingOpus_Builder *builder = [PBSingOpus builderWithPrototype:self.pbOpusBuilder.sing];
    [builder setVoiceType:voiceType];
    [self.pbOpusBuilder setSing:[builder build]];
}

- (void)setDuration:(float)duration{
    PBSingOpus_Builder *builder = [PBSingOpus builderWithPrototype:self.pbOpusBuilder.sing];
    [builder setDuration:duration];
    [self.pbOpusBuilder setSing:[builder build]];
}

- (void)setPitch:(float)pitch{
    PBSingOpus_Builder *builder = [PBSingOpus builderWithPrototype:self.pbOpusBuilder.sing];
    [builder setPitch:pitch];
    [self.pbOpusBuilder setSing:[builder build]];
}

- (void)setFormant:(float)formant{
    PBSingOpus_Builder *builder = [PBSingOpus builderWithPrototype:self.pbOpusBuilder.sing];
    [builder setFormant:formant];
    [self.pbOpusBuilder setSing:[builder build]];
}

@end
