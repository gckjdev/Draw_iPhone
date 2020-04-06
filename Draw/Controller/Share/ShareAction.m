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
//#import "WXApi.h"
#import "UIImageExt.h"
#import "MyPaintManager.h"
#import "PPDebug.h"
#import "DrawFeed.h"
#import "StringUtil.h"
#import "CustomActionSheet.h"
#import "CommonImageManager.h"
//#import "PPSNSIntegerationService.h"
#import "PPSNSConstants.h"
#import "GameSNSService.h"
#import "CommonMessageCenter.h"
#import "FeedService.h"
#import "PPViewController.h"
#import "AnalyticsManager.h"
#import "StorageManager.h"
#import "WordManager.h"
#import "PPConfigManager.h"
#import "UIImageUtil.h"
#import "StringUtil.h"
#import "TimeUtils.h"
#import "GameSNSService.h"

#import "SDImageCache.h"
#import "SDWebImageManager.h"
#import "ShareService.h"
#import "Opus.h"

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
        self.drawWord = feed.wordText;
        
        NSString* path = [NSString stringWithFormat:@"%@/%@.jpg", NSTemporaryDirectory(), feed.feedId];
        BOOL result=[[image data] writeToFile:path atomically:YES];
        if (result) {
            self.imageFilePath = path;
            PPDebug(@"<initWithFeed> create image file at %@ for share", path);
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
    
    if ([[UserManager defaultManager] hasBindQQSpace]){
        buttonIndex ++;
        [shareOptions addButtonWithTitle:NSLS(@"kShare_via_qq_space")];
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
        buttonIndexWeixinTimeline = 3;
        buttonIndexWeixinFriend = 4;
        buttonIndexEmail = 5;
        buttonIndexAlbum = 6;
        buttonIndexFavorite = 7;
        
        _customActionSheet = [[CustomActionSheet alloc] initWithTitle:NSLS(@"kShareTo")
                                                             delegate:self
                                                         buttonTitles:nil];
        
        [_customActionSheet addButtonWithTitle:NSLS(@"kSinaWeibo") image:imageManager.sinaImage];
        [_customActionSheet addButtonWithTitle:NSLS(@"kTencentWeibo") image:imageManager.qqWeiboImage];
        [_customActionSheet addButtonWithTitle:NSLS(@"kFacebook") image:imageManager.facebookImage];
        [_customActionSheet addButtonWithTitle:NSLS(@"kWeChatTimeline") image:imageManager.wechatImage];
        [_customActionSheet addButtonWithTitle:NSLS(@"kWeChatFriends") image:imageManager.wechatFriendsImage];
        [_customActionSheet addButtonWithTitle:NSLS(@"kEmail") image:imageManager.emailImage];

        [_customActionSheet addButtonWithTitle:NSLS(@"kAlbum") image:imageManager.albumImage];
        [_customActionSheet addButtonWithTitle:NSLS(@"kFavorite") image:imageManager.favoriteImage];
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
                                           contestId:_feed.contestId
                                          actionName:actionName
                                            category:_feed.categoryType];
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
        [self.superViewController presentViewController:compose animated:YES completion:nil];
    }
    [compose release];
}

+ (NSString*)createFeedImagePath:(DrawFeed*)feed
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    UIImage* image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:feed.drawImageUrl];
    if (image == nil) {
        image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:feed.drawImageUrl];
    }
    
    if (image == nil){
        image = feed.largeImage;
    }
    
    NSString* path = [[[ShareService defaultService] synthesisImageWithImage:image
                                                              waterMarkText:[PPConfigManager getShareImageWaterMark]] retain];
    [pool drain];

    PPDebug(@"<createFeedImagePath> create image file at %@ for share", path);
    return [path autorelease];
}

+ (NSString*)createOpusImagePath:(Opus*)opus
{
    NSString* imageURL = opus.pbOpus.image;
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            
    UIImage* image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:imageURL];
    if (image == nil) {
        image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imageURL];
    }
    
    NSString* path = [[[ShareService defaultService] synthesisImageWithImage:image
                                                               waterMarkText:[PPConfigManager getShareImageWaterMark]] retain];
    [pool drain];
    
    PPDebug(@"<createFeedImagePath> create image file at %@ for share", path);
    return [path autorelease];
    
}

+ (NSString*)createShareText:(NSString*)word
                        desc:(NSString*)desc
                  opusUserId:(NSString*)opusUserId
                  userGender:(BOOL)userGender
                     snsType:(SnsType)type
                      opusId:(NSString*)opusId
{
    return [self createShareText:word
                            desc:desc
                      opusUserId:opusUserId
                      userGender:userGender
                         snsType:type
                          opusId:opusId
                           isGIF:NO];
}

+ (NSString*)createShareText:(NSString*)word
                        desc:(NSString*)desc
                  opusUserId:(NSString*)opusUserId
                  userGender:(BOOL)userGender
                     snsType:(SnsType)type
                      opusId:(NSString*)opusId
                       isGIF:(BOOL)isGIF
{
    NSString* snsOfficialNick = [GameSNSService snsOfficialNick:type];
    NSString* text = @"";
    BOOL isDrawByMe = [[UserManager defaultManager] isMe:opusUserId];

    if ([word length] == 0){
        word = NSLS(@"kUnknownWord");
    }
    
    NSString* link = [PPConfigManager getAppItuneLink];
    if ([PPConfigManager showOpusLinkInShare] && [opusId length] > 0){
        link = [NSString stringWithFormat:[PPConfigManager getShareOpusWebLink], opusId];
    }

    if ([PPConfigManager showLinkInShare] == NO){
        link = @"";
    }
    
    if (isDrawByMe){
        if ([desc length] > 0) {
            text = [NSString stringWithFormat:[GameApp shareMyOpusWithDescText], desc, snsOfficialNick, word, [PPConfigManager getSNSShareSubject], link];
        } else {
            text = [NSString stringWithFormat:[GameApp shareMyOpusWithoutDescText], snsOfficialNick, word, [PPConfigManager getSNSShareSubject], link];
        }
    }
    else{
        NSString* heStr = userGender ? NSLS(@"kHim") : NSLS(@"kHer");
        if ([desc length] > 0) {
            text = [NSString stringWithFormat:[GameApp shareOtherOpusWithDescText], desc, heStr, snsOfficialNick, word, [PPConfigManager getSNSShareSubject], link];
            
        } else {
            text = [NSString stringWithFormat:[GameApp shareOtherOpusWithoutDescText],  heStr, snsOfficialNick, word, [PPConfigManager getSNSShareSubject], link];
        }
    }
    
    if (isGIF){
        text = [text stringByReplacingOccurrencesOfString:NSLS(@"kSNSSubject") withString:NSLS(@"kGIFShareSuffix")];
    }
    
    return text;
}

+ (NSString*)shareTextByOpus:(Opus*)opus snsType:(SnsType)type
{
    NSString* text = @"";
    text = [self createShareText:opus.pbOpus.name
                            desc:opus.pbOpus.desc
                      opusUserId:opus.pbOpus.author.userId
                      userGender:opus.pbOpus.author.gender
                         snsType:type
                          opusId:opus.pbOpus.opusId];
    
    return text;
}


+ (NSString*)shareTextByDrawFeed:(DrawFeed*)feed snsType:(SnsType)type
{
    NSString* text = @"";
    text = [self createShareText:feed.wordText
                            desc:feed.pbFeed.opusDesc
                      opusUserId:feed.author.userId
                      userGender:feed.author.gender
                         snsType:type
                          opusId:feed.feedId];
    
    return text;
}

- (void)shareViaSNS:(SnsType)type
{    
    NSString* text = [ShareAction createShareText:_drawWord
                                             desc:self.feed.pbFeed.opusDesc
                                       opusUserId:_drawUserId
                                       userGender:self.feed.author.gender
                                          snsType:type
                                           opusId:_feed.feedId];

    [[GameSNSService defaultService] publishWeibo:type
                                             text:text
                                    imageFilePath:_imageFilePath
                                           inView:self.superViewController.view
                                       awardCoins:[PPConfigManager getShareWeiboReward]
                                   successMessage:NSLS(@"kShareWeiboSucc")
                                   failureMessage:NSLS(@"kShareWeiboFailure")];
    
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
                POSTMSG(NSLS(@"kFailLoad"));
            }

            [cp.superViewController hideActivity];
            [cp.superViewController hideProgressView];
        }
         downloadDelegate:self];
    }
}

- (void)saveToLocalDraft:(id<DrawDataServiceDelegate>)delegate
{
    
    
    [self.superViewController showActivityWithText:NSLS(@"kSaving")];
    if (self.feed.pbDrawData) {
        [[DrawDataService defaultService] savePaintWithPBDraw:self.feed
                                                   pbDrawData:self.feed.pbDrawData
                                                        image:self.image
                                                      isDraft:YES
                                                     delegate:delegate];
        [self.superViewController hideActivity];
    }else{
        __block ShareAction *cp = self;
        [self.superViewController showProgressViewWithMessage:NSLS(@"kLoading")];
        [[FeedService defaultService] getPBDrawByFeed:cp.feed handler:^(int resultCode, NSData *pbDrawData, DrawFeed *feed, BOOL fromCache) {
            
            if (resultCode == 0 && pbDrawData != nil) {
                [[DrawDataService defaultService] savePaintWithPBDraw:feed
                                                           pbDrawData:pbDrawData
                                                                image:cp.image
                                                              isDraft:YES
                                                             delegate:delegate];
            }else{
                POSTMSG(NSLS(@"kFailLoad"));
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
    [[FeedService defaultService] addOpusIntoFavorite:self.feed.feedId
                                            contestId:self.feed.contestId
                                          resultBlock:^(int resultCode)
    {
        [vc hideActivity];
        
        if ([self.feed isDrawCategory] == NO){
            return;
        }
                                              
        CommonDialog* dialog = [CommonDialog createDialogWithTitle:NSLS(@"KSaveToLocalTitle") message:NSLS(@"kSaveToLocalMsg") style:CommonDialogStyleDoubleButton];
        [dialog setClickOkBlock:^(UILabel *label){
            [ac saveToLocal];
        }];
        
        [dialog.cancelButton setTitle:NSLS(@"kDonotSave") forState:UIControlStateNormal];
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
    [[self superViewController] showProgressViewWithMessage:progressText progress:progress];
    
//    [self.superViewController.progressView setLabelText:progressText];
//
//    [self.superViewController.progressView setProgress:progress];
}

- (void)bindSNS:(int)snsType
{
//    PPViewController* viewController = nil;    
//    if ([self.superViewController isKindOfClass:[PPViewController class]]){
//        viewController = (PPViewController*)self.superViewController;
//    }
//    
//    PPSNSCommonService* service = [[PPSNSIntegerationService defaultService] snsServiceByType:snsType];
//    NSString* name = [service snsName];
//    
//    [service logout];
//    
//    [service login:^(NSDictionary *userInfo) {
//        PPDebug(@"%@ Login Success", name);
//        
//        [viewController showActivityWithText:NSLS(@"Loading")];
//        
//        [service readMyUserInfo:^(NSDictionary *userInfo) {
//            [viewController hideActivity];
//            PPDebug(@"%@ readMyUserInfo Success, userInfo=%@", name, [userInfo description]);
//            UserManager* userManager = [UserManager defaultManager];
//            [[UserService defaultService] updateUserWithSNSUserInfo:[userManager userId]
//                                                           userInfo:userInfo
//                                                     viewController:nil];
//            
//            // share weibo here
//            [self shareViaSNS:snsType];
//            
//        } failureBlock:^(NSError *error) {
//            [viewController hideActivity];
//            PPDebug(@"%@ readMyUserInfo Failure", name);
//        }];
//        
//        // follow weibo if NOT followed
//        if ([GameSNSService hasFollowOfficialWeibo:service] == NO){            
//            [service followUser:[service officialWeiboId]
//                         userId:[service officialWeiboId]
//                   successBlock:^(NSDictionary *userInfo) {
//                [GameSNSService updateFollowOfficialWeibo:service];
//            } failureBlock:^(NSError *error) {
//                PPDebug(@"follow weibo but error=%@", [error description]);
//            }];            
//        }
//     
//    } failureBlock:^(NSError *error) {
//        PPDebug(@"%@ Login Failure", name);
//        POSTMSG(NSLS(@"kUserBindFail"));
//    }];
}

- (void)bindSinaWeibo
{
    [self bindSNS:TYPE_SINA];
}

//- (void)bindQQWeibo
//{
//    [self bindSNS:TYPE_QQ];
//}

- (void)bindQQSpace
{
    [self bindSNS:TYPE_QQSPACE];
}


- (void)bindFacebook
{
    [self bindSNS:TYPE_FACEBOOK];
}

- (void)actionOnShareSina
{
    [self shareViaSNS:SINA_WEIBO];
}

- (void)saveAlbum
{
    [[AnalyticsManager sharedAnalyticsManager] reportShareActionClicks:SHARE_ACTION_ALBUM];
    [[MyPaintManager defaultManager] savePhoto:_imageFilePath delegate:self];
    [self.superViewController showActivityWithText:NSLS(@"kSaving")];
}

- (void)actionByButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == buttonIndexAlbum){
        [self saveAlbum];
    }
    else if (buttonIndex == buttonIndexEmail) {
        [[AnalyticsManager sharedAnalyticsManager] reportShareActionClicks:SHARE_ACTION_EMAIL];
        [self shareViaEmail];
    }
    else if (buttonIndex == buttonIndexWeixinTimeline){
        [[AnalyticsManager sharedAnalyticsManager] reportShareActionClicks:SHARE_ACTION_WEIXIN_TIMELINE];

//        [self shareViaWeixin:WXSceneTimeline];
        
        NSString* audioURL = nil;
        if ([self.feed isSingCategory]){
            audioURL = self.feed.drawDataUrl;
        }
        
        [[GameSNSService defaultService] publishWeibo:TYPE_WEIXIN_TIMELINE
                                                 text:_drawWord
                                        imageFilePath:_imageFilePath
                                             audioURL:audioURL
                                                title:self.feed.pbFeed.opusDesc
                                               inView:self.superViewController.view
                                           awardCoins:[PPConfigManager getShareWeiboReward]
                                       successMessage:NSLS(@"kShareWeiboSucc")
                                       failureMessage:NSLS(@"kShareWeiboFailure")];

    }
    else if (buttonIndex == buttonIndexWeixinFriend){
        [[AnalyticsManager sharedAnalyticsManager] reportShareActionClicks:SHARE_ACTION_WEIXIN_FRIEND];
        
//        [self shareViaWeixin:WXSceneSession];

        NSString* audioURL = nil;
        if ([self.feed isSingCategory]){
            audioURL = self.feed.drawDataUrl;
        }        
        
        [[GameSNSService defaultService] publishWeibo:TYPE_WEIXIN_SESSION
                                                 text:_drawWord
                                        imageFilePath:_imageFilePath
                                             audioURL:audioURL
                                                title:self.feed.pbFeed.opusDesc
                                               inView:self.superViewController.view
                                           awardCoins:[PPConfigManager getShareWeiboReward]
                                       successMessage:NSLS(@"kShareWeiboSucc")
                                       failureMessage:NSLS(@"kShareWeiboFailure")];
    
    }
    else if (buttonIndex == buttonIndexSinaWeibo)
    {
        [[AnalyticsManager sharedAnalyticsManager] reportShareActionClicks:SHARE_ACTION_SINA];
        [self shareViaSNS:TYPE_SINA];
    } else if (buttonIndex == buttonIndexQQWeibo) {
        [[AnalyticsManager sharedAnalyticsManager] reportShareActionClicks:SHARE_ACTION_QQ];
        [self shareViaSNS:TYPE_QQSPACE];
    } else if (buttonIndex == buttonIndexFacebook) {
        [[AnalyticsManager sharedAnalyticsManager] reportShareActionClicks:SHARE_ACTION_FACEBOOK];
        [self shareViaSNS:TYPE_FACEBOOK];

        
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
        case QQ_SPACE: {
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
    /*
    if (succ && !isSimpleDrawApp() ) {
         [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kSaveToLocalSuccess") delayTime:2 isHappy:YES];
        
        // remove due to it's reported now
//        [self reportActionToServer:DB_FIELD_ACTION_SAVE_TIMES];
    }
     */
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
	[self.superViewController dismissViewControllerAnimated:YES completion:nil];
    if (error == nil && result == MFMailComposeResultSent) {
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kShareByEmailSuccess") delayTime:1.5 isHappy:YES];
        [self reportActionToServer:DB_FIELD_ACTION_SHARE_EMAIL];
    }
    
}

@end
