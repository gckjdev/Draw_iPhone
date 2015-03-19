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
#import "MFMailComposeViewController+ShareEmailSender.h"
#import "CommonMessageCenter.h"
#import "PPConfigManager.h"
#import "GameSNSService.h"
#import "SingController.h"

@interface SingOpus () <MFMailComposeViewControllerDelegate>


@end

@implementation SingOpus


- (void)setSong:(PBSong *)song{
    PBSingOpusBuilder *builder = [PBSingOpus builderWithPrototype:self.pbOpusBuilder.sing];
    [builder setSong:song];
    [self.pbOpusBuilder setSing:[builder build]];
}

- (void)setVoiceDuration:(int)fileDuration
{
    PBSingOpusBuilder *builder = [PBSingOpus builderWithPrototype:self.pbOpusBuilder.sing];
    [builder setVoiceDuration:fileDuration];
    [self.pbOpusBuilder setSing:[builder build]];    
}

- (void)setVoiceType:(PBVoiceType)voiceType{
    PBSingOpusBuilder *builder = [PBSingOpus builderWithPrototype:self.pbOpusBuilder.sing];
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
            [builder setFormant:1];
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

- (NSString *)getCurrentVoiceTypeName{
    
    PBVoiceType voiceType = self.pbOpus.sing.voiceType;
    switch (voiceType) {
        case PBVoiceTypeVoiceTypeOrigin:
            return NSLS(@"kVoiceTypeOrigin");
            break;
            
        case PBVoiceTypeVoiceTypeTomCat:
            return NSLS(@"kVoiceTypeTomCat");
            break;
                        
        case PBVoiceTypeVoiceTypeMale:
            return NSLS(@"kVoiceTypeMale");
            break;
            
        case PBVoiceTypeVoiceTypeFemale:
            return NSLS(@"kVoiceTypeFemale");
            break;
            
        default:
            return NSLS(@"kUnkown");
            break;
    }
}

#pragma data & native data URL handling

- (NSString*)localNativeDataURLString
{
    return [self localURLString:[self.pbOpusBuilder.sing localNativeDataUrl]];
}


- (NSURL*)localNativeDataURL
{
    return [NSURL fileURLWithPath:[self localURLString:[self.pbOpusBuilder.sing localNativeDataUrl]]];
    
//    return  [NSURL fileURLWithPath:[self.pbOpusBuilder.sing localNativeDataUrl]];
}

+ (NSString*)localDataDir
{
    return @"SingData";
}

- (void)setLocalNativeDataUrl:(NSString*)extension
{
    NSString* path = [NSString stringWithFormat:@"%@_native.%@", [self opusKey], extension];
//    NSString* path = [NSString stringWithFormat:@"%@/%@_native.%@", [[self class] localDataDir], [self opusKey], extension];
//    NSString* finalPath = [FileUtil filePathInAppDocument:path];
    
    PBSingOpusBuilder *builder = [PBSingOpus builderWithPrototype:self.pbOpusBuilder.sing];
    [builder setLocalNativeDataUrl:path];
    [self.pbOpusBuilder setSing:[builder build]];
}

- (void)setLocalImageDataUrl:(NSString*)extension
{
//    NSString* path = [NSString stringWithFormat:@"%@/%@.%@", [[self class] localDataDir], [self opusKey], extension];
    NSString* path = [NSString stringWithFormat:@"%@.%@", [self opusKey], extension];
//    NSString* finalPath = [FileUtil filePathInAppDocument:path];
    
    [self setLocalImageUrl:path];
}



- (void)setLocalThumbImageDataUrl:(NSString*)extension
{
//    NSString* path = [NSString stringWithFormat:@"%@/%@_thumb.%@", [[self class] localDataDir], [self opusKey], extension];
    NSString* path = [NSString stringWithFormat:@"%@_thumb.%@", [self opusKey], extension];
//    NSString* finalPath = [FileUtil filePathInAppDocument:path];
    
    [self setLocalThumbImageUrl:path];
}

- (NSString*)dataType
{
    return SING_UPLOAD_FILE_EXTENSION;
}

- (NSData *)uploadData{
    
    PBOpusBuilder *builder = [PBOpus builderWithPrototype:self.pbOpus];
    [builder clearImage];
    [builder clearLocalDataUrl];
    [builder clearLocalImageUrl];
    [builder clearLocalThumbImageUrl];
    
    PBSingOpusBuilder *singBuilder = [PBSingOpus builderWithPrototype:builder.sing];
    [singBuilder clearLocalNativeDataUrl];
    PBSingOpus *sing = [singBuilder build];
    [builder setSing:sing];
    
    return [[builder build] data];
}

- (void)replayInController:(UIViewController*)controller
{
    PPDebug(@"<replayInController> no impletement!");
}

enum {
    SHARE_VIA_EMAIL = 0,
    SHARE_VIA_WEIXIN_TIMELINE,
    SHARE_VIA_WEIXIN_FRIEND,
    SHARE_VIA_SINA,
    SHARE_VIA_QQ_WEIBO,
    SHARE_VIA_FACEBOOK,
};

- (NSArray*)shareOptionsTitleArray
{
    return [NSArray arrayWithObjects:NSLS(@"kShare_via_Email"), NSLS(@"kShare_via_Weixin_Timeline"), NSLS(@"kShare_via_Weixin_Friend"), NSLS(@"kShare_via_Sina_weibo"), NSLS(@"kShare_via_qq_space"), NSLS(@"kShare_via_Facebook"), nil];
}

- (void)shareViaEmailFromController:(UIViewController*)controller
{
    NSString* appName = NSLocalizedStringFromTable(@"CFBundleDisplayName", @"InfoPlist", @"");
    
    NSString* subject = [NSString stringWithFormat:NSLS(@"kShareMusicEmailSubject"), appName];
    NSString* body = [NSString stringWithFormat:NSLS(@"kShareMusicEmailBody"), appName];
    
    NSString* mime = @"audio/mp3";
    
    NSString* filePath = @"";
    
    [MFMailComposeViewController shareWithSbuject:subject body:body filePath:filePath mediaType:mime fromController:controller delegate:self];
}

- (void)handleShareOptionAtIndex:(int)index
                  fromController:(UIViewController*)controller
{
    switch (index) {
        case SHARE_VIA_EMAIL: {
            [self shareViaEmailFromController:controller];
        } break;
        case SHARE_VIA_WEIXIN_TIMELINE: {
            PPDebug(@"share via weixin timeline");
        } break;
        case SHARE_VIA_WEIXIN_FRIEND: {
            PPDebug(@"share via weixin friend");
        } break;
        case SHARE_VIA_SINA: {
            PPDebug(@"share via sina");
        } break;
        case SHARE_VIA_QQ_WEIBO: {
            PPDebug(@"share via qq weibo");
        } break;
        case SHARE_VIA_FACEBOOK: {
            PPDebug(@"share via facebook");
        } break;
        default:
            break;
    }
}

- (void)enterEditFromController:(UIViewController *)controller
{
    PPDebug(@"<enterEditFromController> no impletement!");
    SingController *vc = [[[SingController alloc] initWithOpus:self] autorelease];
    [controller.navigationController pushViewController:vc animated:YES];
}


#pragma mark - mail compose delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [controller.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    if (error == nil && result == MFMailComposeResultSent) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kShareByEmailSuccess") delayTime:1.5 isHappy:YES];
//        [self reportActionToServer:DB_FIELD_ACTION_SHARE_EMAIL];
    }
    
}


- (NSString *)shareTextWithSNSType:(int)type{
    NSString* snsOfficialNick = [GameSNSService snsOfficialNick:type];
    
    PBOpus *pbOpus = self.pbOpus;
    
    NSString *text = [NSString stringWithFormat:NSLS(@"kShareMySingOpus"), snsOfficialNick, pbOpus.name, pbOpus.dataUrl, [PPConfigManager getSNSShareSubject], [PPConfigManager getAppItuneLink]];
    
    return text;
}

- (void)setLabelInfoWithFrame:(CGRect)frame
                    textColor:(NSUInteger)textColor
                     textFont:(float)textFont
                        style:(int)style
              textStrokeColor:(NSUInteger)textStrokeColor{
    
    PBLabelInfoBuilder *labelInfoBuilder = [[[PBLabelInfoBuilder alloc] init] autorelease];
    
    if (!CGRectEqualToRect(frame, CGRectZero)) {
        PBRectBuilder *rectBuilder = [[[PBRectBuilder alloc] init] autorelease];
        [rectBuilder setX:frame.origin.x];
        [rectBuilder setY:frame.origin.y];
        [rectBuilder setWidth:frame.size.width];
        [rectBuilder setHeight:frame.size.height];
        PBRect *pbRect = [rectBuilder build];
        [labelInfoBuilder setFrame:pbRect];
    }
    
    [labelInfoBuilder setTextColor:textColor];
    [labelInfoBuilder setTextFont:textFont];
    [labelInfoBuilder setStyle:0];
    [labelInfoBuilder setTextStrokeColor:textStrokeColor];

    PBLabelInfo *labelInfo = [labelInfoBuilder build];
    
    [self.pbOpusBuilder setDescLabelInfo:labelInfo];
}

- (BOOL)hasFileForPlay
{
    if ([FileUtil fileSizeAtPath:[self localNativeDataURLString]] > 0){
        return YES;
    }
    else{
        return NO;
    }
}



@end
