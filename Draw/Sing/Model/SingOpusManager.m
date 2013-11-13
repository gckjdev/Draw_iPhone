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
#import "FileUtil.h"

@implementation SingOpusManager

// left for subclass to implementation
- (Class)opusClass{
    
    return [SingOpus class];
}

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
    [singOpus setLocalThumbImageDataUrl:SING_IMAGE_EXTENSION];
    
    [singOpus setTags:@[@"唱歌"]];
    
    // set desc label info
    NSUInteger textColor = [[DrawColor whiteColor] toBetterCompressColor];
    float textFont = (ISIPAD ? 26 : 13);
    int style = 0;
    NSUInteger textStrokeColor = [[DrawColor blackColor] toBetterCompressColor];
    float textStrokeWidth = (ISIPAD ? 2 : 1);
    
    [singOpus setLabelInfoWithFrame:CGRectZero
                          textColor:textColor
                           textFont:textFont
                              style:style
                    textStrokeColor:textStrokeColor
                    textStrokeWidth:textStrokeWidth];
    
    return singOpus;
}

- (void)deleteOpus:(Opus *)opus{
    
    [super deleteOpus:opus];
    [FileUtil removeFile:opus.pbOpus.sing.localNativeDataUrl];
}

@end
