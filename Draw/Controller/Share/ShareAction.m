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

@interface ShareAction ()
{
    NSInteger buttonIndexAlbum;
    NSInteger buttonIndexEmail;
    NSInteger buttonIndexWeixin;
    NSInteger buttonIndexSinaWeibo;
    NSInteger buttonIndexQQWeibo;
    NSInteger buttonIndexFacebook;
}
@end

@implementation ShareAction

@synthesize drawWord = _drawWord;
@synthesize imageFilePath = _imageFilePath;
@synthesize isDrawByMe = _isDrawByMe;
@synthesize superViewController = _superViewController;
@synthesize isGIF = _isGIF;

- (void)dealloc
{
    [_drawWord release];
    [_imageFilePath release];
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

- (void)displayWithViewController:(UIViewController*)superViewController;
{
    buttonIndexAlbum = -1;
    buttonIndexEmail = -1;
    buttonIndexWeixin = -1;
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
        [shareOptions addButtonWithTitle:NSLS(@"kShare_via_Weixin")];
        buttonIndexWeixin = buttonIndex;
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

- (void)mailComposeController:(MFMailComposeViewController *)controller 
          didFinishWithResult:(MFMailComposeResult)result 
                        error:(NSError *)error 
{
	[self.superViewController dismissModalViewControllerAnimated:YES];
}

- (void)shareViaEmail
{
    if ([MFMailComposeViewController canSendMail] == NO){
        // TODO 
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
    [self.superViewController presentModalViewController:compose animated:YES];    
    [compose release];
}

- (void)shareViaSNS
{
    NSString* text = nil;
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
                                                                                text:text isDrawByMe:_isDrawByMe];
    [self.superViewController.navigationController pushViewController:controller animated:YES];
    [controller release];    
}

- (void)shareViaWeixin
{
    if ([WXApi isWXAppInstalled] == NO || [WXApi isWXAppSupportApi] == NO)
    {
        [UIUtils alert:NSLS(@"kWeixinNotInstall")];
    }else {
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = _drawWord;
        UIImage *image = [UIImage imageWithContentsOfFile:_imageFilePath];
        UIImage *thumbImage = [image imageByScalingAndCroppingForSize:CGSizeMake(100, 100)];
        [message setThumbImage:thumbImage];
        WXImageObject *ext = [WXImageObject object];
        ext.imageData = [NSData dataWithContentsOfFile:_imageFilePath] ;
        
        message.mediaObject = ext;
        
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        
        [WXApi sendReq:req];
        [req release];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        PPDebug(@"<ShareAction> Click Cancel");
        return;
    }
    
    else if (buttonIndex == buttonIndexAlbum){
        [[MyPaintManager defaultManager] savePhoto:_imageFilePath];
    }
    
    else if (buttonIndex == buttonIndexEmail) {
         [self shareViaEmail];
    }
    
    else if (buttonIndex == buttonIndexWeixin){
        [self shareViaWeixin];
    }
    
    else if (buttonIndex == buttonIndexSinaWeibo 
             || buttonIndex == buttonIndexQQWeibo 
             || buttonIndex == buttonIndexFacebook)
    {
        [self shareViaSNS];
    }
}


@end
