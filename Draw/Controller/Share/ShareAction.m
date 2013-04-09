//
//  ShareAction.m
//  Draw
//
//  Created by  on 12-4-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShareAction.h"
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

@interface ShareAction ()
{
    NSInteger buttonIndexAlbum;
    NSInteger buttonIndexEmail;
    NSInteger buttonIndexWeixinTimeline;
    NSInteger buttonIndexWeixinFriend;
    NSInteger buttonIndexSinaWeibo;
    NSInteger buttonIndexQQWeibo;
    NSInteger buttonIndexFacebook;
    NSInteger buttonIndexFavorite;
    NSInteger buttonIndexUseAsAvatar;
    NSInteger buttonIndexUseAsContactAvatar;

    CustomActionSheet* _customActionSheet;
}
@end

@implementation ShareAction

@synthesize drawWord = _drawWord;
@synthesize imageFilePath = _imageFilePath;
@synthesize isDrawByMe = _isDrawByMe;
@synthesize superViewController = _superViewController;
@synthesize isGIF = _isGIF;
@synthesize drawUserId = _drawUserId;

- (void)dealloc
{
    PPDebug(@"%@ dealloc", [self description]);
    PPRelease(_superViewController);
    [_drawWord release];
    [_imageFilePath release];
    [_drawUserId release];
    [_image release];
    [_feed release];
    PPRelease(_customActionSheet);
    [super dealloc];
}

- (id)initWithDrawImageFile:(NSString*)imageFilePath isGIF:(BOOL)isGIF drawWord:(NSString*)drawWord isMe:(BOOL)isMe
{
    self = [super init];
    if (drawWord == nil)
        self.drawWord = @"";
    else 
        self.drawWord = drawWord;
    self.imageFilePath = imageFilePath;
    self.isDrawByMe = isMe;
    self.isGIF = isGIF;
    
    return self;    
}

- (id)initWithDrawImageFile:(NSString*)imageFilePath 
                      isGIF:(BOOL)isGIF 
                   drawWord:(NSString*)drawWord 
                 drawUserId:(NSString*)drawUserId
{
    self = [super init];
    if (drawWord == nil)
        self.drawWord = @"";
    else 
        self.drawWord = drawWord;
    
    self.isDrawByMe = ([[UserManager defaultManager].userId isEqualToString:drawUserId]);
    self.isGIF = isGIF;
    self.drawUserId = drawUserId;
    self.imageFilePath = imageFilePath;
    return self; 
}

- (id)initWithFeed:(DrawFeed*)feed
             image:(UIImage*)image
{
    self= [super init];
    if (self) {
        self.isDrawByMe = ([[UserManager defaultManager] isMe:feed.author.userId]);
        self.isGIF = NO;
        self.drawUserId = feed.author.userId;
        
        NSString* path = [NSString stringWithFormat:@"%@/%@.jpg", NSTemporaryDirectory(), [NSString GetUUID]];
        BOOL result=[[image data] writeToFile:path atomically:YES];
        if (result) {
            self.imageFilePath = path;
        }
        else{
            PPDebug(@"<initWithFeed> fail to create image file at %@", path);
        }
        self.feed = feed;
        self.image = image;
    }
    return self;
}

- (void)displayWithViewController:(PPViewController<UserServiceDelegate>*)superViewController;
{
    buttonIndexAlbum = -1;
    buttonIndexEmail = -1;
    buttonIndexWeixinTimeline = -1;
    buttonIndexWeixinFriend = -1;
    buttonIndexSinaWeibo = -1;
    buttonIndexQQWeibo = -1;
    buttonIndexFacebook = -1;
    
    UIActionSheet* shareOptions = [[UIActionSheet alloc] initWithTitle:NSLS(@"kShare_Options")
                                                              delegate:self
                                                     cancelButtonTitle:nil
                                                destructiveButtonTitle:NSLS(@"kSave_to_album")
                                                     otherButtonTitles:NSLS(@"kShare_via_Email"), nil];
    buttonIndexAlbum = 0;
    buttonIndexEmail = 1;
    
    int buttonIndex = buttonIndexEmail;
    if (self.isGIF == NO) {
        buttonIndex ++;
        [shareOptions addButtonWithTitle:NSLS(@"kShare_via_Weixin_Timeline")];
        buttonIndexWeixinTimeline = buttonIndex;
        
        buttonIndex ++;
        [shareOptions addButtonWithTitle:NSLS(@"kShare_via_Weixin_Friend")];
        buttonIndexWeixinFriend = buttonIndex;
        
    }
    
    if ([[UserManager defaultManager] hasBindSinaWeibo]){
        buttonIndex ++;
        [shareOptions addButtonWithTitle:NSLS(@"kShare_via_Sina_weibo")];
        buttonIndexSinaWeibo = buttonIndex;
    }
    
    if ([[UserManager defaultManager] hasBindQQWeibo]){
        buttonIndex ++;
        [shareOptions addButtonWithTitle:NSLS(@"kShare_via_tencent_weibo")];
        buttonIndexQQWeibo = buttonIndex;
    }
    
    if ([[UserManager defaultManager] hasBindFacebook]){
        buttonIndex ++;
        [shareOptions addButtonWithTitle:NSLS(@"kShare_via_Facebook")];
        buttonIndexFacebook = buttonIndex;
    }
    
    buttonIndex ++;
    [shareOptions addButtonWithTitle:NSLS(@"kCancel")];
    [shareOptions setCancelButtonIndex:buttonIndex];
    
    self.superViewController = superViewController;
    [shareOptions showInView:superViewController.view];
    [shareOptions release];
}


- (void)displayWithViewController:(PPViewController<UserServiceDelegate>*)superViewController onView:(UIView*)view
{
    
    
    CommonImageManager* imageManager = [CommonImageManager defaultManager];
    
    if (_customActionSheet == nil) {
        
        buttonIndexSinaWeibo = 0;
        buttonIndexQQWeibo = 1;
        buttonIndexFacebook = 2;
        buttonIndexWeixinFriend = 3;
        buttonIndexWeixinTimeline = 4;
        buttonIndexEmail = 5;
        buttonIndexAlbum = 6;
        buttonIndexFavorite = 7;
//        buttonIndexUseAsAvatar = 8;
//        buttonIndexUseAsContactAvatar = 9;
        
        _customActionSheet = [[CustomActionSheet alloc] initWithTitle:NSLS(@"kShareTo")
                                                             delegate:self
                                                         buttonTitles:nil];
        
        [_customActionSheet addButtonWithTitle:NSLS(@"kSinaWeibo") image:imageManager.sinaImage];
        [_customActionSheet addButtonWithTitle:NSLS(@"kTencentWeibo") image:imageManager.qqWeiboImage];
        [_customActionSheet addButtonWithTitle:NSLS(@"kFacebook") image:imageManager.facebookImage];
        [_customActionSheet addButtonWithTitle:NSLS(@"kWeChatTimeline") image:imageManager.wechatImage];
        [_customActionSheet addButtonWithTitle:NSLS(@"kWeChatFriends") image:imageManager.wechatFriendsImage];
        [_customActionSheet addButtonWithTitle:NSLS(@"kEmail") image:imageManager.emailImage];
//        
//        [_customActionSheet setImage:imageManager.albumImage forTitle:NSLS(@"kAlbum")];
//        [_customActionSheet setImage:imageManager.emailImage forTitle:NSLS(@"kEmail")];
        [_customActionSheet addButtonWithTitle:NSLS(@"kAlbum") image:imageManager.albumImage];
        [_customActionSheet addButtonWithTitle:NSLS(@"kFavorite") image:imageManager.favoriteImage];
        
        //TODO: finish it later, still need icon , use as contact not start.
//        [_customActionSheet addButtonWithTitle:NSLS(@"kUseAsAvatar") image:nil];
//        [_customActionSheet addButtonWithTitle:NSLS(@"kUseAsContact") image:nil];

    }
    
    self.superViewController = superViewController;
    if (!_customActionSheet.isVisable) {
        [_customActionSheet showInView:superViewController.view onView:view];
    } else {
        [_customActionSheet hideActionSheet];
    }
    
}

- (void)reportActionToServer:(NSString*)actionName
{
    if (![[UserManager defaultManager] isMe:_feed.author.userId]) {
        [[FeedService defaultService] actionSaveOpus:_feed.feedId
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
    NSString* snsOfficialNick = [GameSNSService snsOfficialNick:type];
    NSString* text = nil;
    if (self.feed != nil) {
        if (_isDrawByMe){
            _drawWord = self.feed.wordText;            
        }
        else{
            _drawWord = [self.feed hasGuessed]?self.feed.wordText:@"";
        }        
    }
    if (_isDrawByMe){
        if (_isGIF){
            text = [NSString stringWithFormat:NSLS(@"kShareGIFMeText"), _drawWord];
        }
        else{
            text = [NSString stringWithFormat:NSLS(@"kShareMeText"), snsOfficialNick, _drawWord];
        }
    }
    else{
        if (_isGIF){
            text = [NSString stringWithFormat:NSLS(@"kShareGIFOtherText"), _drawWord];            
        }
        else{
            text = [NSString stringWithFormat:NSLS(@"kShareOtherText"), snsOfficialNick];
        }
    }
    // removed by Benson 2013-4-5
//    NSArray* array = [[WordManager defaultManager] randGuessWordList:(rand()%10 == 0)?nil:self.feed.wordText];
//    if (array.count >= 4) {
//        text = self.feed.opusDesc;
//        if (text == nil || text.length == 0) {
//            text = [NSString stringWithFormat:NSLS(@"kWeiboShareMessage"), snsOfficialNick, ((Word*)[array objectAtIndex:0]).text, ((Word*)[array objectAtIndex:1]).text, ((Word*)[array objectAtIndex:2]).text, ((Word*)[array objectAtIndex:3]).text];
//        }
//    }
    ShareEditController* controller = [[ShareEditController alloc] initWithImageFile:_imageFilePath
                                                                                text:text drawUserId:self.drawUserId snsType:type];
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
        message.title = _drawWord;
        UIImage *image = [UIImage imageWithContentsOfFile:_imageFilePath];
        
        CGFloat width = 250.f;
        CGFloat height = 250.f;
        CGFloat thumbRate = MAX(250.0f/image.size.width, 250.f/image.size.height);
        width = 250.0f*thumbRate;
        height = 250.f*thumbRate;
        
        PPDebug(@"<shareViaWeixin> thumb image widht=%f, height=%f", width, height);
        UIImage *thumbImage = [UIImage shrinkImage:image withRate:thumbRate];
        //[image imageByScalingAndCroppingForSize:CGSizeMake(250, 250)];        
        
        // compress image if it's too big, otherwize it will NOT be shared
        UIImage *compressImage = image;
        NSData  *shareData = nil;
        if (image.size.width > MAX_WEIXIN_IMAGE_WIDTH){
            // compress image
            CGFloat width = (CGFloat)MAX_WEIXIN_IMAGE_WIDTH;
            CGFloat height = (CGFloat)MAX_WEIXIN_IMAGE_WIDTH;
            CGFloat compressRate = MAX(width/image.size.width, width/image.size.height);
            
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

- (void)saveToLocal
{
    [self.superViewController showActivityWithText:NSLS(@"kSaving")];
    if (self.feed.pbDrawData) {
        [[DrawDataService defaultService] savePaintWithPBDraw:self.feed
                                                   pbDrawData:self.feed.pbDrawData
                                                        image:self.image
                                                     delegate:self];
        [self.superViewController hideActivity];
    }else{
        __block ShareAction *cp = self;
        [self.superViewController showProgressViewWithMessage:NSLS(@"kLoading")];
        [[FeedService defaultService] getPBDrawByFeed:cp.feed handler:^(int resultCode, NSData *pbDrawData, DrawFeed *feed, BOOL fromCache) {
            
            if (resultCode == 0 && pbDrawData != nil) {
                [[DrawDataService defaultService] savePaintWithPBDraw:feed
                                                           pbDrawData:pbDrawData
                                                                image:cp.image
                                                             delegate:cp];
            }else{
                PPDebug(@"Save Failed!!");
                [cp.superViewController popupUnhappyMessage:NSLS(@"kFailLoad") title:nil];
            }

            [cp.superViewController hideActivity];
            [cp.superViewController hideProgressView];
        }
         downloadDelegate:self];
    }
}

- (void)favorite
{
    __block PPViewController* vc = self.superViewController;
    __block ShareAction* ac = self;
    [vc showActivityWithText:NSLS(@"kFavoriting")];
    [[FeedService defaultService] addOpusIntoFavorite:self.feed.feedId resultBlock:^(int resultCode) {
        [vc hideActivity];
        CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"KSaveToLocalTitle") message:NSLS(@"kSaveToLocalMsg") style:CommonDialogStyleDoubleButton delegate:nil clickOkBlock:^{
            [ac saveToLocal];
        } clickCancelBlock:^{
            //
        }];
        [dialog.backButton setTitle:NSLS(@"kDonotSave") forState:UIControlStateNormal];
        [dialog.oKButton setTitle:NSLS(@"kSave") forState:UIControlStateNormal];
        [dialog showInView:vc.view];
    }];
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
    if (buttonIndex == buttonIndexAlbum){
        [[AnalyticsManager sharedAnalyticsManager] reportShareActionClicks:SHARE_ACTION_ALBUM];
        [[MyPaintManager defaultManager] savePhoto:_imageFilePath delegate:self];
        [self.superViewController showActivityWithText:NSLS(@"kSaving")];
    }
    else if (buttonIndex == buttonIndexEmail) {
        [[AnalyticsManager sharedAnalyticsManager] reportShareActionClicks:SHARE_ACTION_EMAIL];
        [self shareViaEmail];
    }
    else if (buttonIndex == buttonIndexWeixinTimeline){
        [[AnalyticsManager sharedAnalyticsManager] reportShareActionClicks:SHARE_ACTION_WEIXIN_TIMELINE];
        [self shareViaWeixin:WXSceneTimeline];
    }
    else if (buttonIndex == buttonIndexWeixinFriend){
        [[AnalyticsManager sharedAnalyticsManager] reportShareActionClicks:SHARE_ACTION_WEIXIN_FRIEND];
        [self shareViaWeixin:WXSceneSession];
    }
    else if (buttonIndex == buttonIndexSinaWeibo)
    {
        [[AnalyticsManager sharedAnalyticsManager] reportShareActionClicks:SHARE_ACTION_SINA];
        [self actionOnShareSina];
    } else if (buttonIndex == buttonIndexQQWeibo) {
        [[AnalyticsManager sharedAnalyticsManager] reportShareActionClicks:SHARE_ACTION_QQ];
        if ([[UserManager defaultManager] hasBindQQWeibo] == NO || [[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_QQ] isAuthorizeExpired]){
            [self bindQQWeibo];
        } else {
            [self shareViaSNS:TYPE_QQ];
        }
    } else if (buttonIndex == buttonIndexFacebook) {
        [[AnalyticsManager sharedAnalyticsManager] reportShareActionClicks:SHARE_ACTION_FACEBOOK];
        if ([[UserManager defaultManager] hasBindFacebook] == NO || [[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_FACEBOOK] isAuthorizeExpired]){
            [self bindFacebook];
        } else {
            [self shareViaSNS:TYPE_FACEBOOK];
        }
    } else if (buttonIndex == buttonIndexFavorite) {
        [[AnalyticsManager sharedAnalyticsManager] reportShareActionClicks:SHARE_ACTION_SAVE];
        [self favorite];
    }else if (buttonIndex == buttonIndexUseAsAvatar) {
        [[AnalyticsManager sharedAnalyticsManager] reportShareActionClicks:SHARE_ACTION_MY_AVATAR];
        [[UserService defaultService] updateUserAvatar:self.image nickName:[UserManager defaultManager].nickName gender:[UserManager defaultManager].gender viewController:self.superViewController];
        
    } else if (buttonIndex == buttonIndexUseAsContactAvatar) {
        [[AnalyticsManager sharedAnalyticsManager] reportShareActionClicks:SHARE_ACTION_CONTACT_AVATAR];
        
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
    if (succ) {
         [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kSaveToLocalSuccess") delayTime:2 isHappy:YES];
        [self reportActionToServer:DB_FIELD_ACTION_SAVE_TIMES];
    }
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
