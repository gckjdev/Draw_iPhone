//
//  SingOpusManager.m
//  Draw
//
//  Created by 王 小涛 on 13-10-17.
//
//

#import "SingOpusManager.h"
#import "SingOpus.h"

@implementation SingOpusManager

// left for subclass to implementation
- (Class)opusClass{
    
    return [SingOpus class];
}

//- (SingOpus*)createDraftSingOpus:(PBSong*)song
//{
//    SingOpus* singOpus = [[[SingOpus alloc] init] autorelease];
//
//    // set basic info
//    [self setDraftOpusId:singOpus extension:SING_FILE_EXTENSION];
//    [self setCommonOpusInfo:singOpus];
//
//    // set type and category
//    [singOpus setType:PBOpusTypeSing];
//    [singOpus setCategory:PBOpusCategoryTypeSingCategory];
//    [singOpus setName:[song name]];
//
//    // init song info
//    [singOpus setSong:song];
//    [singOpus setVoiceType:PBVoiceTypeVoiceTypeOrigin];
//    [singOpus setLocalNativeDataUrl:SING_FILE_EXTENSION];
//
//    return singOpus;
//}

- (Opus*)createDraftWithName:(NSString*)name{
    
    SingOpus* singOpus = [[[SingOpus alloc] init] autorelease];
    
    // set basic info
    [self setDraftOpusId:singOpus extension:SING_FILE_EXTENSION];
    [self setCommonOpusInfo:singOpus];
    
    // set type and category
    [singOpus setType:PBOpusTypeSing];
    [singOpus setCategory:PBOpusCategoryTypeSingCategory];
    [singOpus setName:name];
    
    // init song info
    [singOpus setVoiceType:PBVoiceTypeVoiceTypeOrigin];
    [singOpus setLocalNativeDataUrl:SING_FILE_EXTENSION];
    [singOpus setLocalImageDataUrl:SING_IMAGE_EXTENSION];
    
    [singOpus setTags:@[@"唱歌"]];
    
    return singOpus;
}

@end