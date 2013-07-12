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
#import "ConfigManager.h"
#import "GameSNSService.h"

@interface SingOpus () <MFMailComposeViewControllerDelegate>


@end

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
    return [NSArray arrayWithObjects:NSLS(@"kShare_via_Email"), NSLS(@"kShare_via_Weixin_Timeline"), NSLS(@"kShare_via_Weixin_Friend"), NSLS(@"kShare_via_Sina_weibo"), NSLS(@"kShare_via_tencent_weibo"), NSLS(@"kShare_via_Facebook"), nil];
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
}


#pragma mark - mail compose delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [controller.presentingViewController dismissModalViewControllerAnimated:YES];
    if (error == nil && result == MFMailComposeResultSent) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kShareByEmailSuccess") delayTime:1.5 isHappy:YES];
//        [self reportActionToServer:DB_FIELD_ACTION_SHARE_EMAIL];
    }
    
}


- (NSString *)shareTextWithSNSType:(int)type{
    NSString* snsOfficialNick = [GameSNSService snsOfficialNick:type];
    
    PBOpus *pbOpus = self.pbOpus;
    
    NSString *text = [NSString stringWithFormat:NSLS(@"kShareMySingOpus"), snsOfficialNick, pbOpus.name, pbOpus.dataUrl, [ConfigManager getSNSShareSubject], [ConfigManager getAppItuneLink]];
    
    return text;
}

@end
