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
    UIActionSheet* shareOptions = [[UIActionSheet alloc] initWithTitle:NSLS(@"kShare_Options") 
                                                              delegate:self 
                                                     cancelButtonTitle:nil 
                                                destructiveButtonTitle:NSLS(@"kSave_to_album") 
                                                     otherButtonTitles:NSLS(@"kShare_via_Email"), nil];

    int buttonIndex = 1;
    if ([[UserManager defaultManager] hasBindSinaWeibo]){
        buttonIndex ++;
        [shareOptions addButtonWithTitle:NSLS(@"kShare_via_Sina_weibo")];
    }
    
    if ([[UserManager defaultManager] hasBindQQWeibo]){
        buttonIndex ++;
        [shareOptions addButtonWithTitle:NSLS(@"kShare_via_tencent_weibo")];
    }
    
    if ([[UserManager defaultManager] hasBindFacebook]){
        buttonIndex ++;
        [shareOptions addButtonWithTitle:NSLS(@"kShare_via_Facebook")];
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

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {                
        switch (buttonIndex) {
                
            case SHARE_VIA_ALBUM:
            {
                [[MyPaintManager defaultManager] savePhoto:_imageFilePath];
                break;
            }
                
            case SHARE_VIA_EMAIL:
            {
                [self shareViaEmail];
                break;
            }
                
            default: 
            {
                [self shareViaSNS];
                break;
            } 
        }
    }    
    else{
        PPDebug(@"<ShareAction> Click Cancel");
    }
}


@end
