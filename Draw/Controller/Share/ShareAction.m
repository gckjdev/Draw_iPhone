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
#import "ShareEditController.h"
#import "MyPaintManager.h"
#import "WXApi.h"
#import "UIImageExt.h"
#import "MyPaintManager.h"
#import "PPDebug.h"
#import "DrawFeed.h"
#import "StringUtil.h"
#import "DrawDataService.h"
#import "CustomActionSheet.h"
#import "CommonImageManager.h"
#import "PPSNSIntegerationService.h"
#import "PPSNSConstants.h"
#import "GameSNSService.h"
#import "CommonMessageCenter.h"

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
        NSString* path = [NSString stringWithFormat:@"%@/%@.png", NSTemporaryDirectory(), [NSString GetUUID]];
        BOOL result=[[image data] writeToFile:path atomically:YES];
        if (result) {
            self.imageFilePath = path;
        }
        self.feed = feed;
        self.image = image;
    }
    return self;
}

- (void)displayWithViewController:(UIViewController*)superViewController;
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


- (void)displayWithViewController:(UIViewController*)superViewController onView:(UIView*)view
{
    
    
    CommonImageManager* imageManager = [CommonImageManager defaultManager];
    
    if (_customActionSheet == nil) {
        
        buttonIndexAlbum = 6;
        buttonIndexEmail = 5;
        buttonIndexWeixinTimeline = 3;
        buttonIndexWeixinFriend = 4;
        buttonIndexSinaWeibo = 0;
        buttonIndexQQWeibo = 1;
        buttonIndexFacebook = 2;
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
//        
//        [_customActionSheet setImage:imageManager.albumImage forTitle:NSLS(@"kAlbum")];
//        [_customActionSheet setImage:imageManager.emailImage forTitle:NSLS(@"kEmail")];
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

- (void)mailComposeController:(MFMailComposeViewController *)controller 
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError *)error 
{
	[self.superViewController dismissModalViewControllerAnimated:YES];
}

- (void)shareViaEmail
{
    if ([MFMailComposeViewController canSendMail] == NO){
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
    NSString* text = nil;
    if (self.feed != nil) {
        _drawWord = [self.feed hasGuessed]?self.feed.wordText:@"";
    }
    if (_isDrawByMe){
        if (_isGIF){
            text = [NSString stringWithFormat:NSLS(@"kShareGIFMeText"), _drawWord];
        }
        else{
            text = [NSString stringWithFormat:NSLS(@"kShareMeText"), _drawWord];            
        }
    }
    else{
        if (_isGIF){
            text = [NSString stringWithFormat:NSLS(@"kShareGIFOtherText"), _drawWord];            
        }
        else{
            text = [NSString stringWithFormat:NSLS(@"kShareOtherText"), _drawWord];
        }
    }
    ShareEditController* controller = [[ShareEditController alloc] initWithImageFile:_imageFilePath
                                                                                text:text drawUserId:self.drawUserId snsType:type];
    [self.superViewController.navigationController pushViewController:controller animated:YES];
    [controller release];    
}

- (void)shareViaWeixin:(int)scene
{
    if ([WXApi isWXAppInstalled] == NO || [WXApi isWXAppSupportApi] == NO)
    {
        [UIUtils alert:NSLS(@"kWeixinNotInstall")];
    }else {
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = _drawWord;
        UIImage *image = [UIImage imageWithContentsOfFile:_imageFilePath];
        UIImage *thumbImage = [image imageByScalingAndCroppingForSize:CGSizeMake(250, 250)];
        [message setThumbImage:thumbImage];
        WXImageObject *ext = [WXImageObject object];
        ext.imageData = [NSData dataWithContentsOfFile:_imageFilePath] ;
        
        message.mediaObject = ext;
        
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = scene;
        
        [WXApi sendReq:req];
        [req release];
    }
}

- (void)favorite
{
    [[DrawDataService defaultService] savePaintWithPBDraw:self.feed.pbDraw
                                                    image:self.image
                                                 delegate:nil];
    [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kSaveToLocalSuccess") delayTime:2 isHappy:YES];
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
            
            // ask follow official weibo account here
            // [GameSNSService askFollow:snsType snsWeiboId:[service officialWeiboId]];

            // share weibo here
            [self shareViaSNS:snsType];
            
        } failureBlock:^(NSError *error) {
            [viewController hideActivity];
            PPDebug(@"%@ readMyUserInfo Failure", name);
        }];
        
    } failureBlock:^(NSError *error) {
        PPDebug(@"%@ Login Failure", name);
        [viewController popupMessage:NSLS(@"kUserBindFail") title:nil];
    }];
}




- (void)bindSinaWeibo
{
    //TODO:bind sina weibo here
    [self bindSNS:TYPE_SINA];
}

- (void)bindQQWeibo
{
    //TODO:bind qq weibo here
    [self bindSNS:TYPE_QQ];
}

- (void)bindFacebook
{
    //TODO:bind facebook here
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
        [[MyPaintManager defaultManager] savePhoto:_imageFilePath];
        [[CommonMessageCenter defaultCenter] postMessageWithText:NSLS(@"kSaveToAlbumSuccess") delayTime:1.5 isHappy:YES];
    }
    else if (buttonIndex == buttonIndexEmail) {
        [self shareViaEmail];
    }
    else if (buttonIndex == buttonIndexWeixinTimeline){
        [self shareViaWeixin:WXSceneTimeline];
    }
    else if (buttonIndex == buttonIndexWeixinFriend){
        [self shareViaWeixin:WXSceneSession];
    }
    else if (buttonIndex == buttonIndexSinaWeibo)
    {
        [self actionOnShareSina];        
    } else if (buttonIndex == buttonIndexQQWeibo) {
        if ([[UserManager defaultManager] hasBindQQWeibo] == NO || [[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_QQ] isAuthorizeExpired]){
            [self bindQQWeibo];
        } else {
            [self shareViaSNS:TYPE_QQ];
        }
    } else if (buttonIndex == buttonIndexFacebook) {
        if ([[UserManager defaultManager] hasBindFacebook] == NO || [[[PPSNSIntegerationService defaultService] snsServiceByType:TYPE_FACEBOOK] isAuthorizeExpired]){
            [self bindFacebook];
        } else {
            [self shareViaSNS:TYPE_FACEBOOK];
        }
    } else if (buttonIndex == buttonIndexFavorite) {
        [self favorite];
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
@end
