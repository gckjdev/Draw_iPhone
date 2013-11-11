//
//  SingOpusManager.m
//  Draw
//
//  Created by 王 小涛 on 13-10-17.
//
//

#import "SingOpusManager.h"
#import "SingOpus.h"
#import "DrawUtils.h"
#import "DrawColor.h"

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
    
    // set desc label info
    
    [singOpus setStrokeLabelWithXRatio:0.5
                                yRatio:0.5
                             textColor:[DrawUtils compressColor8:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]]
                       textStrokeColor:[DrawUtils compressColor8:[UIColor colorWithRed:0 green:0 blue:0 alpha:1]]];
    
    return singOpus;
}

@end
