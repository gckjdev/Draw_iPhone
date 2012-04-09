//
//  ShareAction.h
//  Draw
//
//  Created by  on 12-4-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

enum{
    
    SHARE_VIA_ALBUM = 0,
    SHARE_VIA_EMAIL,
    SHARE_VIA_SNS    
};

@interface ShareAction : NSObject<UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, retain) UIViewController* superViewController;
@property (nonatomic, copy) NSString* drawWord;
@property (nonatomic, copy) NSString* imageFilePath;
@property (nonatomic, assign) BOOL isDrawByMe;
@property (nonatomic, assign) BOOL isGIF;

- (id)initWithDrawImageFile:(NSString*)imageFilePath isGIF:(BOOL)isGIF drawWord:(NSString*)drawWord isMe:(BOOL)isDrawByMe;
- (void)displayWithViewController:(UIViewController*)superViewController;

@end
