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
                                                     otherButtonTitles:NSLS(@"kShare_via_Email"), 
                                   //                                                                                NSLS(@"kShare_via_Sina_weibo"),
                                   //                                                                                NSLS(@"kShare_via_tencent_weibo"),
                                   //                                                                                NSLS(@"kShare_via_Facebook"),
                                   nil];
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
    
//    shareOptions.tag = SHARE_AS_PHOTO_OPTION;
    self.superViewController = superViewController;
    [shareOptions showInView:superViewController.view];
    [shareOptions release];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {                
        switch (buttonIndex) {
                
            case SHARE_VIA_ALBUM:
                // TODO save image to album
                break;
                
            case SHARE_VIA_EMAIL:
                // TODO send by email
                break;
                
            default: 
            {
                NSString* text = nil;
                if (_isDrawByMe){
                    text = [NSString stringWithFormat:NSLS(@"kShareOtherText"), _drawWord];
                }
                else{
                    text = [NSString stringWithFormat:NSLS(@"kShareMeText"), _drawWord];
                }
                ShareEditController* controller = [[ShareEditController alloc] initWithImageFile:_imageFilePath
                                                                                            text:text];
                [self.superViewController.navigationController pushViewController:controller animated:YES];
                [controller release];
                
//                MyPaint* myPaint = [self.paints objectAtIndex:_currentSelectedPaint];
//                NSData* imageData = [NSData dataWithContentsOfFile:myPaint.image];
//                UIImage* myImage = [UIImage imageWithData:imageData];
//                ShareEditController* controller = [[ShareEditController alloc] initWithImage:myImage];
//                [self.navigationController pushViewController:controller animated:YES];
//                [controller release];
            } 
                break;
        }
    }    
    else{
        PPDebug(@"<ShareAction> Click Cancel");
    }
}


@end
