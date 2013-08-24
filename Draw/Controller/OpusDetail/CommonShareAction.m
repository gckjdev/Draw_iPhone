//
//  CommonShareAction.m
//  Draw
//
//  Created by  on 12-4-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SDWebImageManager.h"
#import "CommonShareAction.h"
#import "LocaleUtils.h"
#import "UserManager.h"
#import "PPDebug.h"
#import "MyPaintManager.h"
#import "WXApi.h"
#import "UIImageExt.h"
#import "MyPaintManager.h"
#import "PPDebug.h"
#import "DrawFeed.h"
#import "StringUtil.h"
#import "CustomActionSheet.h"
#import "CommonImageManager.h"
#import "PPSNSIntegerationService.h"
#import "PPSNSConstants.h"
#import "GameSNSService.h"
#import "CommonMessageCenter.h"
#import "FeedService.h"
#import "PPViewController.h"
#import "AnalyticsManager.h"
#import "StorageManager.h"
#import "WordManager.h"
#import "ConfigManager.h"
#import "UIImageUtil.h"
#import "StringUtil.h"
#import "TimeUtils.h"
#import "Opus.h"





@interface CommonShareAction ()
{
    CustomActionSheet* _customActionSheet;
    
}

@property (nonatomic, assign) PPViewController* superViewController;

@property (nonatomic, retain) Opus* opus;
@property (nonatomic, retain) UIImage* image;
@property (nonatomic, copy) NSString* imageFilePath;

@property (retain, nonatomic) NSArray *allActions;
@property (retain, nonatomic) NSArray *actionTags;

@end

@implementation CommonShareAction

- (void)dealloc
{
    [_imageFilePath release];
    [_image release];
    [_opus release];
    [_customActionSheet release];
    [_allActions release];
    [_actionTags release];
    [super dealloc];
}

- (id)initWithOpus:(Opus*)opus
{
    if (self = [super init]) {
        
        self.opus = opus;
        
        NSURL *url = [NSURL URLWithString:opus.pbOpus.image];
        
        __block typeof (self)bself = self;
        
        [[SDWebImageManager sharedManager] downloadWithURL:url delegate:self options:0 success:^(UIImage *image, BOOL cached) {
            
            bself.image = image;
            NSString* path = [NSString stringWithFormat:@"%@/%@.jpg", NSTemporaryDirectory(), [NSString GetUUID]];
            
            BOOL result=[[image data] writeToFile:path atomically:YES];
            if (result) {
                self.imageFilePath = path;
            }
            else{
                PPDebug(@"<initWithFeed> fail to create image file at %@", path);
            }
            
        } failure:NULL];
            
        CommonImageManager *manager = [CommonImageManager defaultManager];
                
        self.allActions = @[@[@(ShareActionTagAlbum), NSLS(@"kAlbum"), manager.albumImage],
                            @[@(ShareActionTagEmail), NSLS(@"kEmail"), manager.emailImage],
                            @[@(ShareActionTagWxTimeline), NSLS(@"kWeChatTimeline"), manager.wechatImage],
                            @[@(ShareActionTagWxFriend), NSLS(@"kWeChatFriends"), manager.wechatFriendsImage],
                            @[@(ShareActionTagSinaWeibo), NSLS(@"kSinaWeibo"), manager.sinaImage],
                            @[@(ShareActionTagQQWeibo), NSLS(@"kTencentWeibo"), manager.qqWeiboImage],
                            @[@(ShareActionTagFacebook), NSLS(@"kFacebook"), manager.facebookImage],
                            @[@(ShareActionTagFavorite), NSLS(@"kFavorite"), manager.favoriteImage]];
    }
    
    return self;
}

- (NSArray *)actionWithTag:(ShareActionTag)tag{
    
    for (NSArray *action in _allActions) {
        
        ShareActionTag actionTag = [[action objectAtIndex:0] intValue];
        if (actionTag == tag) {
            return action;
        }
    }
    
    return nil;
}

- (void)displayWithViewController:(PPViewController*)viewController
                           onView:(UIView*)onView{
    
    NSArray *tags = @[@(ShareActionTagSinaWeibo), @(ShareActionTagQQWeibo), @(ShareActionTagFacebook), @(ShareActionTagWxTimeline), @(ShareActionTagWxFriend), @(ShareActionTagEmail), @(ShareActionTagAlbum), @(ShareActionTagFavorite)];
    [self displayActionTags:tags
             viewController:viewController
                     onView:onView];
}

- (void)displayActionTags:(NSArray *)actionTags
           viewController:(PPViewController *)viewController
                   onView:(UIView *)onView{
        
    if (_customActionSheet == nil) {
        
        _customActionSheet = [[CustomActionSheet alloc] initWithTitle:NSLS(@"kShareTo")
                                                             delegate:self
                                                         buttonTitles:nil];
        
        for (NSNumber *nstag in actionTags) {
            
            ShareActionTag tag = [nstag intValue];
            
            NSArray *action = [self actionWithTag:tag];
            NSString *title = [action objectAtIndex:1];
            UIImage *image = [action objectAtIndex:2];
            [_customActionSheet addButtonWithTitle:title
                                             image:image];
        }
    }
    
    self.actionTags = actionTags;
    
    self.superViewController = viewController;

    if (!_customActionSheet.isVisable) {
        [_customActionSheet showInView:viewController.view onView:onView];
    } else {
        [_customActionSheet hideActionSheet];
    }
}

- (void)reportActionToServer:(NSString*)actionName
{
    if (![[UserManager defaultManager] isMe:_opus.pbOpus.author.userId]) {
        [[FeedService defaultService] actionSaveOpus:_opus.pbOpus.opusId
                                          actionName:actionName];
    }
}

- (void)shareViaEmail
{
    if ([MFMailComposeViewController canSendMail] == NO){
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kNotBindMailMessage") delayTime:2.5];
        return;
    }
    
    NSString* appName = NSLocalizedStringFromTable(@"CFBundleDisplayName", @"InfoPlist", @"");
    
    MFMailComposeViewController * compose = [[MFMailComposeViewController alloc] init];
    NSString* subject = [NSString stringWithFormat:NSLS(@"kSharePhotoEmailSubject"), appName];
    NSString* body = [NSString stringWithFormat:NSLS(@"kSharePhotoEmailBody"), appName];
    
    NSString* mime = nil;
    if ([_imageFilePath hasSuffix:@"gif"]){
        mime = @"image/gif";
    }
    else{
        mime = @"image/png";        
    }
    
    NSString* fileName = [_imageFilePath lastPathComponent];
                         
    [compose setSubject:subject];
    [compose setMessageBody:body
                     isHTML:NO];
    [compose addAttachmentData:[NSData dataWithContentsOfFile:_imageFilePath]
                      mimeType:mime
                      fileName:fileName];
    [compose setMailComposeDelegate:self];
    
    if ([DeviceDetection isOS6]){
        [self.superViewController presentViewController:compose animated:YES completion:^{
            
        }];
    }
    else{
        [self.superViewController presentModalViewController:compose animated:YES];
    }
    [compose release];
}

- (void)shareViaSNS:(SnsType)type
{
    ShareEditController* controller = [[ShareEditController alloc] initWithImageFile:_imageFilePath
                                                                                text:[_opus shareTextWithSNSType:type]
                                                                          drawUserId:_opus.pbOpus.author.userId
                                                                             snsType:type];
    controller.delegate = self;
    [self.superViewController.navigationController pushViewController:controller animated:YES];
    [controller release];    
}

#define MAX_WEIXIN_IMAGE_WIDTH          ([ConfigManager maxWeixinImageWidth])

- (void)shareViaWeixin:(int)scene
{
    if ([WXApi isWXAppInstalled] == NO || [WXApi isWXAppSupportApi] == NO)
    {
        [UIUtils alert:NSLS(@"kWeixinNotInstall")];
    }else {
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = _opus.pbOpus.opusId;
        UIImage *image = [UIImage imageWithContentsOfFile:_imageFilePath];
        
        CGFloat width = 250.f;
        CGFloat height = 250.f;
        CGFloat thumbRate = MAX(250.0f/image.size.width, 250.f/image.size.height);
        width = image.size.width*thumbRate;
        height = image.size.height*thumbRate;
        
        PPDebug(@"<shareViaWeixin> thumb image widht=%f, height=%f", width, height);
        UIImage *thumbImage = [image imageByScalingAndCroppingForSize:CGSizeMake(width, height)];;
        //[image imageByScalingAndCroppingForSize:CGSizeMake(250, 250)];        
        
        // compress image if it's too big, otherwize it will NOT be shared
        UIImage *compressImage = image;
        NSData  *shareData = nil;
        if (image.size.width > MAX_WEIXIN_IMAGE_WIDTH){
            // compress image
            CGFloat width = (CGFloat)MAX_WEIXIN_IMAGE_WIDTH;
            CGFloat height = (CGFloat)MAX_WEIXIN_IMAGE_WIDTH;
            CGFloat compressRate = MIN(width/image.size.width, width/image.size.height);
            
            width = image.size.width * compressRate;
            height = image.size.height * compressRate;

            PPDebug(@"<shareViaWeixin> compress image widht=%f, height=%f", width, height);
            compressImage = [image imageByScalingAndCroppingForSize:CGSizeMake(width, height)];
            shareData = UIImageJPEGRepresentation(compressImage, 1.0f);
        }
        else{
            PPDebug(@"<shareViaWeixin> no compress image");
            shareData = [NSData dataWithContentsOfFile:_imageFilePath];
        }
        
        [message setThumbImage:thumbImage];
        WXImageObject *ext = [WXImageObject object];
        ext.imageData = shareData;
        
        message.mediaObject = ext;
        
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = scene;
        
        [WXApi sendReq:req];
        [req release];
    }
}

- (void)setProgress:(CGFloat)progress
{
    if (progress == 1.0f){
        // make this because after uploading data, it takes server sometime to process
        progress = 0.99;
    }

    NSString* progressText = [NSString stringWithFormat:NSLS(@"kLoadingProgress"), progress*100];
    [self.superViewController.progressView setLabelText:progressText];

    [self.superViewController.progressView setProgress:progress];
}

- (void)bindSNS:(int)snsType
{
    PPViewController* viewController = nil;    
    if ([self.superViewController isKindOfClass:[PPViewController class]]){
        viewController = (PPViewController*)self.superViewController;
    }
    
    PPSNSCommonService* service = [[PPSNSIntegerationService defaultService] snsServiceByType:snsType];
    NSString* name = [service snsName];
    
    [service logout];
    
    [service login:^(NSDictionary *userInfo) {
        PPDebug(@"%@ Login Success", name);
        
        [viewController showActivityWithText:NSLS(@"Loading")];
        
        [service readMyUserInfo:^(NSDictionary *userInfo) {
            [viewController hideActivity];
            PPDebug(@"%@ readMyUserInfo Success, userInfo=%@", name, [userInfo description]);
            UserManager* userManager = [UserManager defaultManager];
            [[UserService defaultService] updateUserWithSNSUserInfo:[userManager userId]
                                                           userInfo:userInfo
                                                     viewController:nil];
            
            // share weibo here
            [self shareViaSNS:snsType];
            
        } failureBlock:^(NSError *error) {
            [viewController hideActivity];
            PPDebug(@"%@ readMyUserInfo Failure", name);
        }];
        
        // follow weibo if NOT followed
        if ([GameSNSService hasFollowOfficialWeibo:service] == NO){            
            [service followUser:[service officialWeiboId]
                         userId:[service officialWeiboId]
                   successBlock:^(NSDictionary *userInfo) {
                [GameSNSService updateFollowOfficialWeibo:service];
            } failureBlock:^(NSError *error) {
                PPDebug(@"follow weibo but error=%@", [error description]);
            }];            
        }
     
    } failureBlock:^(NSError *error) {
        PPDebug(@"%@ Login Failure", name);
        [viewController popupMessage:NSLS(@"kUserBindFail") title:nil];
    }];
}

- (void)bindSinaWeibo
{
    [self bindSNS:TYPE_SINA];
}

- (void)bindQQWeibo
{
    [self bindSNS:TYPE_QQ];
}

- (void)bindFacebook
{
    [self bindSNS:TYPE_FACEBOOK];
}

- (void)actionOnShareSina
{
    if ([[UserManager defaultManager] hasBindSinaWeibo] == NO ||
        [[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_SINA] isAuthorizeExpired]){
        [self bindSinaWeibo];
    } else {
        [self shareViaSNS:SINA_WEIBO];
    }
}

- (void)actionByButtonIndex:(NSInteger)buttonIndex
{
    ShareActionTag tag = [[_actionTags objectAtIndex:buttonIndex] intValue];
    
    if (tag == ShareActionTagAlbum){
        [[AnalyticsManager sharedAnalyticsManager] reportShareActionClicks:SHARE_ACTION_ALBUM];
        [[MyPaintManager defaultManager] savePhoto:_imageFilePath delegate:self];
        [self.superViewController showActivityWithText:NSLS(@"kSaving")];
    }
    else if (tag == ShareActionTagEmail) {
        [[AnalyticsManager sharedAnalyticsManager] reportShareActionClicks:SHARE_ACTION_EMAIL];
        [self shareViaEmail];
    }
    else if (tag == ShareActionTagWxTimeline){
        [[AnalyticsManager sharedAnalyticsManager] reportShareActionClicks:SHARE_ACTION_WEIXIN_TIMELINE];
        [self shareViaWeixin:WXSceneTimeline];
    }
    else if (tag == ShareActionTagWxFriend){
        [[AnalyticsManager sharedAnalyticsManager] reportShareActionClicks:SHARE_ACTION_WEIXIN_FRIEND];
        [self shareViaWeixin:WXSceneSession];
    }
    else if (tag == ShareActionTagSinaWeibo)
    {
        [[AnalyticsManager sharedAnalyticsManager] reportShareActionClicks:SHARE_ACTION_SINA];
        [self actionOnShareSina];
    } else if (tag == ShareActionTagQQWeibo) {
        [[AnalyticsManager sharedAnalyticsManager] reportShareActionClicks:SHARE_ACTION_QQ];
        if ([[UserManager defaultManager] hasBindQQWeibo] == NO || [[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_QQ] isAuthorizeExpired]){
            [self bindQQWeibo];
        } else {
            [self shareViaSNS:TYPE_QQ];
        }
    } else if (tag == ShareActionTagFacebook) {
        [[AnalyticsManager sharedAnalyticsManager] reportShareActionClicks:SHARE_ACTION_FACEBOOK];
        if ([[UserManager defaultManager] hasBindFacebook] == NO || [[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_FACEBOOK] isAuthorizeExpired]){
            [self bindFacebook];
        } else {
            [self shareViaSNS:TYPE_FACEBOOK];
        }
    } else if (tag == ShareActionTagFavorite) {
        [[AnalyticsManager sharedAnalyticsManager] reportShareActionClicks:SHARE_ACTION_SAVE];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        PPDebug(@"<ShareAction> Click Cancel");
        return;
    }    
    else {
        [self actionByButtonIndex:buttonIndex];
    }
}

- (void)customActionSheet:(CustomActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self actionByButtonIndex:buttonIndex];
}

#pragma shareEditController delegate
- (void)didPublishSnsMessage:(int)snsType
{
    switch (snsType) {
        case SINA_WEIBO: {
            [self reportActionToServer:DB_FIELD_ACTION_SHARE_SINA];
        } break;
        case QQ_WEIBO: {
            [self reportActionToServer:DB_FIELD_ACTION_SHARE_QQ];
        } break;
        case FACEBOOK: {
            [self reportActionToServer:DB_FIELD_ACTION_SHARE_FACEBOOK];
        } break;
        default:
            break;
    }
}

#pragma mark - DrawDataService delegate
- (void)didSaveOpus:(BOOL)succ
{
    [self.superViewController hideActivity];
}

#pragma mark - MyPaintManager delegater
- (void)didSaveToAlbumSuccess:(BOOL)succ
{
    [self.superViewController hideActivity];
    if (succ) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kSaveToAlbumSuccess") delayTime:1.5 isHappy:YES];
        [self reportActionToServer:DB_FIELD_ACTION_SAVE_ALBUM];
    }
}

#pragma mark - mail compose delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [self.superViewController hideActivity];
	[self.superViewController dismissModalViewControllerAnimated:YES];
    if (error == nil && result == MFMailComposeResultSent) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kShareByEmailSuccess") delayTime:1.5 isHappy:YES];
        [self reportActionToServer:DB_FIELD_ACTION_SHARE_EMAIL];
    }
    
}

@end
